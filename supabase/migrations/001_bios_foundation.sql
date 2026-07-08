-- =============================================================================
-- Nutrient Earth BIOS — Production Database Migration
-- Version: 001
-- Description: Full foundational schema for biological intelligence OS
--
-- Tables:
--   user_profiles         — core biological profile per user
--   biological_history    — time-series biological state snapshots
--   recommendations       — generated protocol recommendations
--   user_outcomes         — feedback/adherence tracking (learning loop)
--   audit_log             — immutable HIPAA-aligned audit trail
--   wearable_readings     — ingested biometric data from all providers
--   knowledge_chunks      — RAG document store with vector embeddings
--   ml_predictions        — model prediction lineage
--   experiment_runs       — ML experiment tracking
--
-- Security:
--   Row Level Security (RLS) enabled on all user-data tables
--   Users can only access their own rows
-- =============================================================================

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
-- pgvector for RAG semantic search (install separately if not available)
-- CREATE EXTENSION IF NOT EXISTS "vector";

-- =============================================================================
-- TABLE: user_profiles
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.user_profiles (
  id                    UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id               UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Demographics
  full_name             TEXT,
  date_of_birth         DATE,
  biological_sex        TEXT CHECK (biological_sex IN ('male','female','intersex','prefer_not_to_say')),
  location_country      TEXT,
  location_city         TEXT,
  timezone              TEXT,

  -- Anthropometrics
  weight_kg             NUMERIC(5,2),
  height_cm             NUMERIC(5,1),
  body_fat_percentage   NUMERIC(4,1),

  -- Goals & Lifestyle
  primary_goal          TEXT,
  activity_level        TEXT,
  dietary_pattern       TEXT,
  sleep_target_hours    NUMERIC(3,1),
  hydration_target_L    NUMERIC(4,2),
  stress_management     TEXT,

  -- Health Context
  chronic_conditions    TEXT[] DEFAULT '{}',
  medications           TEXT[] DEFAULT '{}',
  allergies             TEXT[] DEFAULT '{}',
  supplements           TEXT[] DEFAULT '{}',

  -- Onboarding State
  onboarding_step       INTEGER DEFAULT 0,
  onboarding_completed  BOOLEAN DEFAULT FALSE,
  profile_completed_at  TIMESTAMPTZ,

  -- Biological Intelligence Score (latest)
  latest_bis_score      NUMERIC(5,2),
  latest_bis_grade      TEXT,
  latest_bis_at         TIMESTAMPTZ,

  -- Subscription
  subscription_tier     TEXT DEFAULT 'free' CHECK (subscription_tier IN ('free','pro','clinical')),
  subscription_expires_at TIMESTAMPTZ,

  -- Metadata
  created_at            TIMESTAMPTZ DEFAULT NOW(),
  updated_at            TIMESTAMPTZ DEFAULT NOW()
);

-- RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users access own profile" ON public.user_profiles
  FOR ALL USING (auth.uid() = user_id);

-- Index
CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON public.user_profiles(user_id);

-- =============================================================================
-- TABLE: biological_history
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.biological_history (
  id                    UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id               UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- BIS Snapshot
  bis_score             NUMERIC(5,2),
  bis_grade             TEXT,
  hydration_score       NUMERIC(5,2),
  sleep_score           NUMERIC(5,2),
  stress_score          NUMERIC(5,2),
  recovery_score        NUMERIC(5,2),
  activity_score        NUMERIC(5,2),
  nutrition_score       NUMERIC(5,2),

  -- Raw Inputs (denormalized for ML feature extraction)
  actual_hydration_L    NUMERIC(4,2),
  actual_sleep_hours    NUMERIC(3,1),
  sleep_quality         TEXT,
  stress_level          NUMERIC(3,2),
  activity_completion   NUMERIC(3,2),
  nutrition_adherence   NUMERIC(3,2),

  -- Environmental Context
  temperature_c         NUMERIC(4,1),
  humidity_pct          NUMERIC(4,1),
  aqi                   INTEGER,
  aqi_category          TEXT,
  env_strain_modifier   NUMERIC(3,2),

  -- Primary Constraint
  primary_constraint    TEXT,

  -- Source
  source                TEXT DEFAULT 'bios_engine',
  recorded_at           TIMESTAMPTZ DEFAULT NOW(),
  created_at            TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.biological_history ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users access own history" ON public.biological_history
  FOR ALL USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_bio_history_user_id_time ON public.biological_history(user_id, recorded_at DESC);

-- =============================================================================
-- TABLE: recommendations
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.recommendations (
  id                    UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id               UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  recommendation_id     TEXT NOT NULL,
  title                 TEXT NOT NULL,
  description           TEXT,
  rationale             TEXT,
  category              TEXT,
  urgency               TEXT,
  confidence_score      NUMERIC(3,2),
  action_label          TEXT,
  was_dismissed         BOOLEAN DEFAULT FALSE,
  was_completed         BOOLEAN DEFAULT FALSE,
  dismissed_at          TIMESTAMPTZ,
  completed_at          TIMESTAMPTZ,
  metadata              JSONB DEFAULT '{}',
  generated_at          TIMESTAMPTZ DEFAULT NOW(),
  expires_at            TIMESTAMPTZ DEFAULT NOW() + INTERVAL '24 hours'
);

ALTER TABLE public.recommendations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users access own recommendations" ON public.recommendations
  FOR ALL USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_recommendations_user_active ON public.recommendations(user_id, generated_at DESC) WHERE NOT was_dismissed;

-- =============================================================================
-- TABLE: user_outcomes
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.user_outcomes (
  id                    UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id               UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  recommendation_id     TEXT NOT NULL,
  adherence_rate        NUMERIC(3,2) NOT NULL,
  perceived_impact      NUMERIC(3,2),
  reported_symptoms     TEXT[] DEFAULT '{}',
  energy_after          NUMERIC(3,1),
  user_note             TEXT,
  outcome_quality_score NUMERIC(3,2),
  recorded_at           TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.user_outcomes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users access own outcomes" ON public.user_outcomes
  FOR ALL USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_outcomes_user_id ON public.user_outcomes(user_id, recorded_at DESC);

-- =============================================================================
-- TABLE: wearable_readings
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.wearable_readings (
  id                    UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id               UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  source                TEXT NOT NULL,
  metric_type           TEXT NOT NULL,
  value                 NUMERIC(10,4) NOT NULL,
  unit                  TEXT,
  confidence_score      NUMERIC(3,2),
  raw_metadata          JSONB DEFAULT '{}',
  recorded_at           TIMESTAMPTZ NOT NULL,
  ingested_at           TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.wearable_readings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users access own readings" ON public.wearable_readings
  FOR ALL USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_wearable_user_metric_time ON public.wearable_readings(user_id, metric_type, recorded_at DESC);

-- =============================================================================
-- TABLE: audit_log (immutable — no RLS UPDATE/DELETE)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.audit_log (
  id                    UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  actor_id              UUID NOT NULL,
  action                TEXT NOT NULL,
  resource_type         TEXT NOT NULL,
  resource_id           TEXT NOT NULL,
  metadata              JSONB DEFAULT '{}',
  ip_address            INET,
  performed_at          TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.audit_log ENABLE ROW LEVEL SECURITY;
-- Admins only — no user-level access to audit logs
CREATE POLICY "No user audit access" ON public.audit_log FOR ALL USING (FALSE);

CREATE INDEX IF NOT EXISTS idx_audit_actor ON public.audit_log(actor_id, performed_at DESC);

-- =============================================================================
-- TABLE: knowledge_chunks (RAG document store)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.knowledge_chunks (
  id                    TEXT PRIMARY KEY,
  content               TEXT NOT NULL,
  source_title          TEXT NOT NULL,
  source_category       TEXT NOT NULL,
  -- embedding          vector(1536),  -- Uncomment when pgvector is available
  metadata              JSONB DEFAULT '{}',
  indexed_at            TIMESTAMPTZ DEFAULT NOW(),
  updated_at            TIMESTAMPTZ DEFAULT NOW()
);

-- No RLS — knowledge base is read-only global content
CREATE INDEX IF NOT EXISTS idx_knowledge_category ON public.knowledge_chunks(source_category);

-- =============================================================================
-- TABLE: ml_predictions (prediction lineage)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.ml_predictions (
  id                    TEXT PRIMARY KEY,
  model_id              TEXT NOT NULL,
  model_version         TEXT NOT NULL,
  user_id               UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  input_features        JSONB NOT NULL,
  prediction            NUMERIC(6,4) NOT NULL,
  confidence            NUMERIC(3,2),
  actual_outcome        NUMERIC(6,4),
  predicted_at          TIMESTAMPTZ DEFAULT NOW(),
  outcome_recorded_at   TIMESTAMPTZ
);

ALTER TABLE public.ml_predictions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users access own predictions" ON public.ml_predictions
  FOR ALL USING (auth.uid() = user_id);

-- =============================================================================
-- FUNCTION: update_updated_at trigger
-- =============================================================================
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_user_profiles_updated_at
  BEFORE UPDATE ON public.user_profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- =============================================================================
-- FUNCTION: new user profile bootstrap
-- =============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (user_id, full_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email)
  )
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
