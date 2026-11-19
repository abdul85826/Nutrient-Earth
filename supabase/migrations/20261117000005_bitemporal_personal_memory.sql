-- ==============================================================================
-- Migration: 20261117000005_bitemporal_personal_memory.sql
-- Description: 10-Year Bitemporal Personal Memory Engine.
--              Maintains two independent temporal dimensions:
--              1. Valid Time: [valid_from, valid_to] (When the fact was true in reality)
--              2. Transaction/System Time: [recorded_at, superseded_at] (When the fact was known to the system)
--
-- Capabilities:
--   - Non-destructive history: Updates supersede prior versions without destroying records
--   - As-of Point-in-Time queries (What did the system know at time T_sys?)
--   - As-was Point-in-Time queries (What was the user's reality at time T_valid?)
--   - Dual Bitemporal slices (What did the system believe at T_sys about reality at T_valid?)
--   - Multi-tenant isolation with strict Row Level Security (RLS)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Canonical Personal Facts Header
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.bitemporal_personal_facts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    category TEXT NOT NULL CHECK (
        category IN (
            'preference',
            'routine',
            'allergy_and_intolerance',
            'medical_history',
            'medication_and_supplement',
            'biological_baseline',
            'life_event',
            'environmental_sensitivity',
            'goal'
        )
    ),
    fact_key TEXT NOT NULL,
    title TEXT NOT NULL,
    current_value JSONB NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_bitemporal_facts UNIQUE (user_id, category, fact_key)
);

CREATE INDEX IF NOT EXISTS idx_bitemporal_facts_user_cat
    ON public.bitemporal_personal_facts (user_id, category, is_active);

-- Enable RLS
ALTER TABLE public.bitemporal_personal_facts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own bitemporal facts"
    ON public.bitemporal_personal_facts FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can insert own bitemporal facts"
    ON public.bitemporal_personal_facts FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can update own bitemporal facts"
    ON public.bitemporal_personal_facts FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can delete own bitemporal facts"
    ON public.bitemporal_personal_facts FOR DELETE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

-- ------------------------------------------------------------------------------
-- 2. Bitemporal Fact Versions (The Immutable Bitemporal Ledger)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.bitemporal_fact_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fact_id UUID NOT NULL REFERENCES public.bitemporal_personal_facts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    version_number INT NOT NULL,
    fact_value JSONB NOT NULL,
    -- Valid Time (Real-world validity)
    valid_from TIMESTAMPTZ NOT NULL,
    valid_to TIMESTAMPTZ, -- NULL means open-ended into future
    -- Transaction Time (System knowledge)
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    superseded_at TIMESTAMPTZ, -- NULL means currently active belief in system
    -- Provenance and Verification
    confidence NUMERIC(3,2) NOT NULL DEFAULT 1.00 CHECK (confidence BETWEEN 0.00 AND 1.00),
    provenance TEXT NOT NULL CHECK (
        provenance IN (
            'user_explicit',
            'clinician_verified',
            'wearable_inferred',
            'ai_conversation_inferred',
            'document_extracted'
        )
    ),
    source_reference JSONB,
    verification_status TEXT NOT NULL DEFAULT 'unverified' CHECK (
        verification_status IN (
            'unverified',
            'user_confirmed',
            'clinician_approved',
            'rejected'
        )
    ),
    change_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Compound index for fast Point-in-Time queries
CREATE INDEX IF NOT EXISTS idx_bitemporal_versions_valid_range
    ON public.bitemporal_fact_versions (fact_id, valid_from, valid_to);

CREATE INDEX IF NOT EXISTS idx_bitemporal_versions_system_range
    ON public.bitemporal_fact_versions (fact_id, recorded_at, superseded_at);

CREATE INDEX IF NOT EXISTS idx_bitemporal_versions_user_active
    ON public.bitemporal_fact_versions (user_id, superseded_at)
    WHERE superseded_at IS NULL;

-- Enable RLS
ALTER TABLE public.bitemporal_fact_versions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own fact versions"
    ON public.bitemporal_fact_versions FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can insert own fact versions"
    ON public.bitemporal_fact_versions FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can update own fact versions"
    ON public.bitemporal_fact_versions FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- ------------------------------------------------------------------------------
-- 3. Stored Procedure: Record Bitemporal Fact (Atomic Upsert & Supersession)
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.record_bitemporal_fact(
    p_user_id UUID,
    p_category TEXT,
    p_fact_key TEXT,
    p_title TEXT,
    p_fact_value JSONB,
    p_valid_from TIMESTAMPTZ,
    p_valid_to TIMESTAMPTZ DEFAULT NULL,
    p_provenance TEXT DEFAULT 'user_explicit',
    p_confidence NUMERIC DEFAULT 1.00,
    p_verification_status TEXT DEFAULT 'user_confirmed',
    p_source_reference JSONB DEFAULT NULL,
    p_change_reason TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_fact_id UUID;
    v_next_version INT;
    v_now TIMESTAMPTZ := timezone('utc'::text, now());
BEGIN
    -- Verify calling user matches p_user_id
    IF auth.uid() != p_user_id THEN
        RAISE EXCEPTION 'Access denied. You can only record facts for your own profile.';
    END IF;

    -- Ensure header fact exists or retrieve ID
    INSERT INTO public.bitemporal_personal_facts (
        user_id, category, fact_key, title, current_value, is_active, updated_at
    )
    VALUES (
        p_user_id, p_category, p_fact_key, p_title, p_fact_value, true, v_now
    )
    ON CONFLICT (user_id, category, fact_key)
    DO UPDATE SET
        title = EXCLUDED.title,
        current_value = EXCLUDED.current_value,
        is_active = true,
        updated_at = v_now
    RETURNING id INTO v_fact_id;

    -- Determine next version number
    SELECT COALESCE(MAX(version_number), 0) + 1
    INTO v_next_version
    FROM public.bitemporal_fact_versions
    WHERE fact_id = v_fact_id;

    -- Supersede active versions that overlap with the new valid interval or are being replaced
    UPDATE public.bitemporal_fact_versions
    SET superseded_at = v_now
    WHERE fact_id = v_fact_id
      AND superseded_at IS NULL
      AND (
          -- If new fact is open-ended or overlapping
          (p_valid_to IS NULL AND (valid_to IS NULL OR valid_to >= p_valid_from))
          OR
          (p_valid_to IS NOT NULL AND valid_from <= p_valid_to AND (valid_to IS NULL OR valid_to >= p_valid_from))
      );

    -- Insert new immutable version
    INSERT INTO public.bitemporal_fact_versions (
        fact_id,
        user_id,
        version_number,
        fact_value,
        valid_from,
        valid_to,
        recorded_at,
        superseded_at,
        confidence,
        provenance,
        source_reference,
        verification_status,
        change_reason
    )
    VALUES (
        v_fact_id,
        p_user_id,
        v_next_version,
        p_fact_value,
        p_valid_from,
        p_valid_to,
        v_now,
        NULL,
        p_confidence,
        p_provenance,
        p_source_reference,
        p_verification_status,
        p_change_reason
    );

    RETURN v_fact_id;
END;
$$;
