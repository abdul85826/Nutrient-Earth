-- Nutrient Earth Biological Intelligence OS Database Migration
-- Target: Supabase (PostgreSQL 15+)
-- Enabled Extensions: pgvector, uuid-ossp, moddatetime

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "vector";

-- ─── AUDIT LOGGING INFRASTRUCTURE ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_name VARCHAR(100) NOT NULL,
    action VARCHAR(20) NOT NULL, -- INSERT, UPDATE, DELETE
    record_id UUID NOT NULL,
    old_data JSONB,
    new_data JSONB,
    performed_by UUID, -- linked to auth.users
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE OR REPLACE FUNCTION audit_log_trigger_fn()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_logs (table_name, action, record_id, old_data, new_data, performed_by)
    VALUES (
        TG_TABLE_NAME,
        TG_OP,
        COALESCE(NEW.id, OLD.id),
        CASE WHEN TG_OP IN ('UPDATE', 'DELETE') THEN to_jsonb(OLD) ELSE NULL END,
        CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN to_jsonb(NEW) ELSE NULL END,
        auth.uid()
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── CORE USER & SUBSCRIPTION SCHEMA ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) UNIQUE NOT NULL,
    subscription_tier VARCHAR(50) DEFAULT 'free' NOT NULL,
    onboarding_step INT DEFAULT 0 NOT NULL,
    profile_completed BOOLEAN DEFAULT FALSE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- ─── HUMAN BIOLOGICAL MODEL SCHEMA ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    activity_level VARCHAR(50) NOT NULL,
    primary_goal VARCHAR(100) NOT NULL,
    secondary_goals TEXT[] DEFAULT '{}'::TEXT[] NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS biological_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    gender VARCHAR(50) NOT NULL,
    weight_kg DECIMAL(5,2) NOT NULL,
    height_cm DECIMAL(5,2) NOT NULL,
    date_of_birth DATE NOT NULL,
    has_diabetes BOOLEAN DEFAULT FALSE NOT NULL,
    digestion_rating VARCHAR(50) DEFAULT 'good' NOT NULL,
    bowel_pattern VARCHAR(50) DEFAULT 'normal' NOT NULL,
    hormonal_profile VARCHAR(50) DEFAULT 'normal' NOT NULL,
    occupational_stress DECIMAL(3,1) DEFAULT 0.0 NOT NULL,
    is_climate_adapted BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Onboarding Intake Drafts
CREATE TABLE IF NOT EXISTS onboarding_drafts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    step INT DEFAULT 0 NOT NULL,
    data JSONB NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ─── LIFESTYLE & ENVIRONMENTAL DATA INGESTION ────────────────────────────────
CREATE TABLE IF NOT EXISTS daily_checkins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    checkin_date DATE DEFAULT CURRENT_DATE NOT NULL,
    hydration_liters DECIMAL(4,2) DEFAULT 0.0 NOT NULL,
    sleep_hours DECIMAL(4,2) DEFAULT 0.0 NOT NULL,
    stress_level INT DEFAULT 0 NOT NULL, -- 0 to 10
    step_count INT DEFAULT 0 NOT NULL,
    energy_level INT DEFAULT 3 NOT NULL, -- 1 to 5
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE (user_id, checkin_date)
);

CREATE TABLE IF NOT EXISTS environmental_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    latitude DECIMAL(9,6) NOT NULL,
    longitude DECIMAL(9,6) NOT NULL,
    aqi INT NOT NULL,
    humidity INT NOT NULL,
    uv_index DECIMAL(3,1) NOT NULL,
    temperature_c DECIMAL(4,1) NOT NULL,
    pollen_level VARCHAR(50) DEFAULT 'low' NOT NULL,
    sunlight_exposure_minutes INT DEFAULT 0 NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS symptom_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    symptom_type VARCHAR(100) NOT NULL,
    severity INT NOT NULL, -- 1 to 10
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS wearable_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    provider VARCHAR(100) NOT NULL, -- apple_health, fitbit, etc.
    data_type VARCHAR(100) NOT NULL, -- heart_rate, sleep_stage, oxygen
    raw_payload JSONB NOT NULL,
    recorded_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ─── BIOLOGICAL SCORE TRACKING (ESTIMATES) ───────────────────────────────────
CREATE TABLE IF NOT EXISTS recovery_scores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    score DECIMAL(5,2) NOT NULL,
    fatigue_index DECIMAL(5,2) NOT NULL,
    sleep_debt DECIMAL(5,2) NOT NULL,
    inflammation_estimate DECIMAL(5,2) NOT NULL,
    nervous_system_strain DECIMAL(5,2) NOT NULL,
    calculated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ─── PROTOCOLS, RAG & RECOMMENDATION LINEAGE ────────────────────────────────
-- Grounded Clinical Protocols Knowledge Base (RAG)
CREATE TABLE IF NOT EXISTS clinical_protocols (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    scientific_evidence TEXT NOT NULL,
    protocol_data JSONB NOT NULL,
    embedding VECTOR(1536), -- OpenAI Ada-002 compatibility (1536 dims)
    version INT DEFAULT 1 NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS recommendations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    protocol_id UUID REFERENCES clinical_protocols(id) ON DELETE SET NULL,
    adaptation_reason TEXT NOT NULL,
    recommendation_data JSONB NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS adherence_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    recommendation_id UUID REFERENCES recommendations(id) ON DELETE CASCADE NOT NULL,
    adherence_score DECIMAL(5,2) NOT NULL, -- 0.0 to 100.0
    action_taken VARCHAR(100) NOT NULL, -- COMPLETED, SKIPPED
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ─── MACHINE LEARNING FEATURE STORE SCHEMA ───────────────────────────────────
CREATE TABLE IF NOT EXISTS ml_features (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    feature_name VARCHAR(150) NOT NULL,
    feature_value DECIMAL(12,4) NOT NULL,
    temporal_window VARCHAR(50) NOT NULL, -- 1d, 7d, 30d
    calculated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ─── ROW LEVEL SECURITY (RLS) POLICIES ───────────────────────────────────────
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE biological_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE onboarding_drafts ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_checkins ENABLE ROW LEVEL SECURITY;
ALTER TABLE environmental_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE symptom_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE wearable_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE recovery_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE recommendations ENABLE ROW LEVEL SECURITY;
ALTER TABLE adherence_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE ml_features ENABLE ROW LEVEL SECURITY;
ALTER TABLE clinical_protocols ENABLE ROW LEVEL SECURITY; -- Admin only writes, public read

-- Strict RLS Policies (User Isolation)
CREATE POLICY user_read_own ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY user_write_own ON users FOR UPDATE USING (auth.uid() = id);

CREATE POLICY profile_read_own ON user_profiles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY profile_write_own ON user_profiles FOR ALL USING (auth.uid() = user_id);

CREATE POLICY biological_read_own ON biological_profiles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY biological_write_own ON biological_profiles FOR ALL USING (auth.uid() = user_id);

CREATE POLICY drafts_read_own ON onboarding_drafts FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY drafts_write_own ON onboarding_drafts FOR ALL USING (auth.uid() = user_id);

CREATE POLICY checkins_read_own ON daily_checkins FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY checkins_write_own ON daily_checkins FOR ALL USING (auth.uid() = user_id);

CREATE POLICY env_read_own ON environmental_logs FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY env_write_own ON environmental_logs FOR ALL USING (auth.uid() = user_id);

CREATE POLICY symptom_read_own ON symptom_logs FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY symptom_write_own ON symptom_logs FOR ALL USING (auth.uid() = user_id);

CREATE POLICY wearables_read_own ON wearable_data FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY wearables_write_own ON wearable_data FOR ALL USING (auth.uid() = user_id);

CREATE POLICY recovery_read_own ON recovery_scores FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY recovery_write_own ON recovery_scores FOR ALL USING (auth.uid() = user_id);

CREATE POLICY recommendations_read_own ON recommendations FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY recommendations_write_own ON recommendations FOR ALL USING (auth.uid() = user_id);

CREATE POLICY adherence_read_own ON adherence_logs FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY adherence_write_own ON adherence_logs FOR ALL USING (auth.uid() = user_id);

CREATE POLICY ml_features_read_own ON ml_features FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY ml_features_write_own ON ml_features FOR ALL USING (auth.uid() = user_id);

CREATE POLICY protocols_read_all ON clinical_protocols FOR SELECT USING (true);

-- ─── PERFORMANCE INDEXES ─────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON user_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_biological_profiles_user_id ON biological_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_daily_checkins_user_date ON daily_checkins(user_id, checkin_date);
CREATE INDEX IF NOT EXISTS idx_symptom_logs_user ON symptom_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_wearable_data_user_recorded ON wearable_data(user_id, recorded_at DESC);
CREATE INDEX IF NOT EXISTS idx_ml_features_user_name ON ml_features(user_id, feature_name);
CREATE INDEX IF NOT EXISTS idx_recommendations_user_active ON recommendations(user_id, is_active);

-- Vector Cosine Similarity Index
CREATE INDEX IF NOT EXISTS idx_clinical_protocols_embedding ON clinical_protocols USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- ─── TIMESTAMPS TRIGGERS ─────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_modtime BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_profiles_modtime BEFORE UPDATE ON user_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_biological_profiles_modtime BEFORE UPDATE ON biological_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Bind Audit Logging Triggers
CREATE TRIGGER audit_users_trigger AFTER INSERT OR UPDATE OR DELETE ON users FOR EACH ROW EXECUTE FUNCTION audit_log_trigger_fn();
CREATE TRIGGER audit_profiles_trigger AFTER INSERT OR UPDATE OR DELETE ON user_profiles FOR EACH ROW EXECUTE FUNCTION audit_log_trigger_fn();
CREATE TRIGGER audit_biological_trigger AFTER INSERT OR UPDATE OR DELETE ON biological_profiles FOR EACH ROW EXECUTE FUNCTION audit_log_trigger_fn();
