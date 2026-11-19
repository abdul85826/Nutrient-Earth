-- ==============================================================================
-- Migration: 20261117000003_personal_body_intelligence_foundation.sql
-- Description: Personal Body Intelligence Foundation:
--   1. Granular User Consents (user_consents)
--   2. Canonical Personal Observations (personal_observations)
--   3. Individual Personal Baselines (personal_baselines)
--   4. Contextual Personal State Snapshots (personal_state_snapshots)
--   5. Deterministic State Change Detection (personal_state_changes)
--
-- Security & Integrity Rules:
--   - Non-Elevation Constraint: AI pipeline can NEVER produce provenance_type = 'observed'
--   - Temporal Provenance: observed_at (happened) vs recorded_at (learned) strictly preserved
--   - Multi-tenant Isolation: RLS with (SELECT auth.uid()) = user_id on all tables
--   - Idempotency & Deduplication: Unique indexes on external_record_id and idempotency_key
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Granular User Consents
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.user_consents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    scope TEXT NOT NULL CHECK (
        scope IN (
            'health_read',
            'environment_read',
            'activity_track',
            'nutrition_log',
            'ai_personalization',
            'biomarker_read',
            'memory_storage'
        )
    ),
    is_granted BOOLEAN NOT NULL DEFAULT true,
    granted_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    revoked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_user_consents_user_scope UNIQUE (user_id, scope)
);

CREATE INDEX IF NOT EXISTS idx_user_consents_lookup
    ON public.user_consents (user_id, scope, is_granted);

ALTER TABLE public.user_consents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own consents"
    ON public.user_consents FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can manage own consents"
    ON public.user_consents FOR ALL
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- ------------------------------------------------------------------------------
-- 2. Canonical Personal Observations
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.personal_observations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    observation_type TEXT NOT NULL,
    numeric_value NUMERIC,
    text_value TEXT,
    structured_payload JSONB DEFAULT '{}'::jsonb,
    unit TEXT,
    source_provider TEXT NOT NULL CHECK (
        source_provider IN (
            'android_health_connect',
            'apple_healthkit',
            'open_meteo',
            'user_input',
            'device_sensor',
            'clinical_lab',
            'ai_pipeline'
        )
    ),
    device_model TEXT,
    external_record_id TEXT,
    idempotency_key TEXT,
    observed_at TIMESTAMPTZ NOT NULL,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    timezone TEXT NOT NULL DEFAULT 'UTC',
    quality_status TEXT NOT NULL DEFAULT 'validated' CHECK (
        quality_status IN ('validated', 'provisional', 'suspect', 'corrected', 'deleted')
    ),
    provenance_type TEXT NOT NULL CHECK (
        provenance_type IN ('observed', 'derived', 'inferred', 'unknown')
    ),
    consent_scope TEXT NOT NULL DEFAULT 'health_read',
    schema_version INT NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),

    -- Non-Elevation Rule: AI pipeline can NEVER produce an observed record directly
    CONSTRAINT chk_obs_ai_never_observed
        CHECK (NOT (provenance_type = 'observed' AND source_provider = 'ai_pipeline'))
);

-- Deduplication index for external records from Apple HealthKit or Android Health Connect
CREATE UNIQUE INDEX IF NOT EXISTS idx_personal_obs_external_dedup
    ON public.personal_observations (user_id, source_provider, external_record_id)
    WHERE external_record_id IS NOT NULL;

-- Idempotency index for API operations
CREATE UNIQUE INDEX IF NOT EXISTS idx_personal_obs_idempotency
    ON public.personal_observations (user_id, idempotency_key)
    WHERE idempotency_key IS NOT NULL;

-- Timeline queries for baselines and analytics
CREATE INDEX IF NOT EXISTS idx_personal_obs_timeline
    ON public.personal_observations (user_id, observation_type, observed_at DESC);

ALTER TABLE public.personal_observations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own observations"
    ON public.personal_observations FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can insert own observations"
    ON public.personal_observations FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can update own observations"
    ON public.personal_observations FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can delete own observations"
    ON public.personal_observations FOR DELETE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

-- ------------------------------------------------------------------------------
-- 3. Individual Personal Baselines
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.personal_baselines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    metric_name TEXT NOT NULL,
    baseline_value NUMERIC NOT NULL,
    baseline_min NUMERIC,
    baseline_max NUMERIC,
    standard_deviation NUMERIC,
    unit TEXT NOT NULL,
    sample_count INT NOT NULL DEFAULT 1,
    window_days INT NOT NULL DEFAULT 14,
    window_start TIMESTAMPTZ NOT NULL,
    window_end TIMESTAMPTZ NOT NULL,
    is_weekend_specific BOOLEAN NOT NULL DEFAULT false,
    confidence_score NUMERIC(3,2) NOT NULL DEFAULT 0.50 CHECK (confidence_score BETWEEN 0.00 AND 1.00),
    status TEXT NOT NULL DEFAULT 'provisional' CHECK (
        status IN ('provisional', 'established', 'stale', 'insufficient_data')
    ),
    algorithm_version INT NOT NULL DEFAULT 1,
    calculated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_personal_baselines_unique UNIQUE (user_id, metric_name, is_weekend_specific, algorithm_version)
);

CREATE INDEX IF NOT EXISTS idx_personal_baselines_user
    ON public.personal_baselines (user_id, metric_name, status);

ALTER TABLE public.personal_baselines ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own baselines"
    ON public.personal_baselines FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can manage own baselines"
    ON public.personal_baselines FOR ALL
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- ------------------------------------------------------------------------------
-- 4. Contextual Personal State Snapshots
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.personal_state_snapshots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    snapshot_date DATE NOT NULL,
    circadian_phase TEXT NOT NULL CHECK (
        circadian_phase IN ('dawn', 'morning', 'midday', 'afternoon', 'golden_hour', 'dusk', 'night')
    ),
    activity_status TEXT NOT NULL DEFAULT 'nominal' CHECK (
        activity_status IN ('rest', 'light', 'moderate', 'intense', 'recovery_needed', 'nominal')
    ),
    sleep_hours NUMERIC(4,2),
    steps_count INT,
    environmental_aqi INT,
    weather_condition TEXT,
    readiness_score NUMERIC(3,2) CHECK (readiness_score BETWEEN 0.00 AND 1.00),
    active_constraints TEXT[] NOT NULL DEFAULT '{}',
    willingness_tier TEXT NOT NULL DEFAULT 'moderate' CHECK (
        willingness_tier IN ('low', 'moderate', 'high', 'unreceptive')
    ),
    known_facts JSONB NOT NULL DEFAULT '{}'::jsonb,
    unknowns TEXT[] NOT NULL DEFAULT '{}',
    confidence_score NUMERIC(3,2) NOT NULL DEFAULT 0.80 CHECK (confidence_score BETWEEN 0.00 AND 1.00),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_personal_state_snapshots UNIQUE (user_id, snapshot_date, circadian_phase)
);

CREATE INDEX IF NOT EXISTS idx_personal_state_snapshots_timeline
    ON public.personal_state_snapshots (user_id, snapshot_date DESC, circadian_phase);

ALTER TABLE public.personal_state_snapshots ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own state snapshots"
    ON public.personal_state_snapshots FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can manage own state snapshots"
    ON public.personal_state_snapshots FOR ALL
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- ------------------------------------------------------------------------------
-- 5. Deterministic State Change Detection
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.personal_state_changes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    metric_name TEXT NOT NULL,
    classification TEXT NOT NULL CHECK (
        classification IN ('normal_variation', 'possible_change', 'sustained_change', 'data_quality_issue', 'insufficient_data')
    ),
    baseline_reference NUMERIC,
    observed_value NUMERIC NOT NULL,
    deviation_percent NUMERIC(5,2),
    direction TEXT NOT NULL CHECK (direction IN ('increased', 'decreased', 'unchanged', 'divergent')),
    explanation TEXT,
    detected_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_personal_state_changes_timeline
    ON public.personal_state_changes (user_id, metric_name, detected_at DESC);

ALTER TABLE public.personal_state_changes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own state changes"
    ON public.personal_state_changes FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can insert own state changes"
    ON public.personal_state_changes FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);
