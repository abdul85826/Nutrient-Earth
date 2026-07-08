-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "vector"; -- pgvector for embeddings

-- ==========================================
-- 1. SCHEMA VERSIONING
-- ==========================================
CREATE TABLE schema_versions (
    version_id SERIAL PRIMARY KEY,
    version_number VARCHAR(50) NOT NULL,
    applied_at TIMESTAMPTZ DEFAULT NOW(),
    description TEXT
);

INSERT INTO schema_versions (version_number, description) VALUES ('1.0.0', 'Biological Foundation Init');

-- ==========================================
-- 2. USERS & GUEST PROFILES
-- ==========================================
CREATE TABLE users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ -- Soft delete
);

CREATE TABLE guest_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    migrated_to_user_id UUID REFERENCES users(id) ON DELETE SET NULL, -- Null if still a guest
    deleted_at TIMESTAMPTZ
);
CREATE INDEX idx_guest_device ON guest_profiles(device_id);

-- ==========================================
-- 3. BIOLOGICAL EVENTS
-- ==========================================
CREATE TABLE biological_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    guest_id UUID REFERENCES guest_profiles(id) ON DELETE CASCADE,
    event_type VARCHAR(100) NOT NULL,
    source VARCHAR(100) NOT NULL,
    source_device VARCHAR(100),
    confidence FLOAT NOT NULL CHECK (confidence >= 0 AND confidence <= 1),
    uncertainty FLOAT NOT NULL CHECK (uncertainty >= 0 AND uncertainty <= 1),
    severity FLOAT NOT NULL,
    biological_impact FLOAT NOT NULL,
    reversibility BOOLEAN DEFAULT TRUE,
    causality_chain UUID[], -- Links to other events
    linked_state_ids UUID[], -- Links to states
    metadata JSONB DEFAULT '{}'::jsonb,
    schema_version INT DEFAULT 1,
    occurred_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    
    -- Ensure it belongs to exactly one identity
    CONSTRAINT chk_identity CHECK (
        (user_id IS NOT NULL AND guest_id IS NULL) OR 
        (user_id IS NULL AND guest_id IS NOT NULL)
    )
);
CREATE INDEX idx_events_user_time ON biological_events(user_id, occurred_at DESC);
CREATE INDEX idx_events_guest_time ON biological_events(guest_id, occurred_at DESC);
CREATE INDEX idx_events_type ON biological_events(event_type);

-- ==========================================
-- 4. BIOLOGICAL STATES
-- ==========================================
CREATE TABLE biological_states (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    guest_id UUID REFERENCES guest_profiles(id) ON DELETE CASCADE,
    state_type VARCHAR(100) NOT NULL, -- e.g. 'RecoveryState'
    state_data JSONB NOT NULL,
    confidence FLOAT NOT NULL,
    uncertainty FLOAT NOT NULL,
    temporal_decay_rate FLOAT DEFAULT 0.0,
    embedding VECTOR(1536), -- AI vector representation of state for similarity search
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,

    CONSTRAINT chk_state_identity CHECK (
        (user_id IS NOT NULL AND guest_id IS NULL) OR 
        (user_id IS NULL AND guest_id IS NOT NULL)
    )
);
CREATE INDEX idx_states_user_type ON biological_states(user_id, state_type);
CREATE INDEX idx_states_guest_type ON biological_states(guest_id, state_type);
-- HNSW Index for fast vector similarity searches
CREATE INDEX idx_states_embedding ON biological_states USING hnsw (embedding vector_cosine_ops);

-- ==========================================
-- 5. WEARABLE SNAPSHOTS
-- ==========================================
CREATE TABLE wearable_snapshots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    source VARCHAR(100) NOT NULL,
    payload JSONB NOT NULL,
    captured_at TIMESTAMPTZ NOT NULL,
    processed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_wearable_user_time ON wearable_snapshots(user_id, captured_at DESC);

-- ==========================================
-- 6. RECOMMENDATIONS
-- ==========================================
CREATE TABLE recommendations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    guest_id UUID REFERENCES guest_profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    confidence FLOAT NOT NULL,
    status VARCHAR(50) DEFAULT 'pending', -- pending, accepted, dismissed
    generated_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);
CREATE INDEX idx_recommendations_user_status ON recommendations(user_id, status);

-- ==========================================
-- 7. TIMELINE SNAPSHOTS
-- ==========================================
CREATE TABLE timeline_snapshots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    snapshot_time TIMESTAMPTZ NOT NULL,
    biological_age_delta FLOAT,
    overall_health_score FLOAT,
    compressed_state JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_timeline_user_time ON timeline_snapshots(user_id, snapshot_time DESC);

-- ==========================================
-- 8. SYNC QUEUE (Server-side tracking for conflicts)
-- ==========================================
CREATE TABLE sync_queue (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    collection_name VARCHAR(100) NOT NULL,
    record_id UUID NOT NULL,
    operation VARCHAR(20) NOT NULL,
    payload JSONB,
    processed_at TIMESTAMPTZ,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- 9. AUDIT LOGS
-- ==========================================
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_name VARCHAR(100) NOT NULL,
    record_id UUID NOT NULL,
    action VARCHAR(20) NOT NULL, -- INSERT, UPDATE, DELETE
    old_data JSONB,
    new_data JSONB,
    changed_by UUID, -- Can be a user ID or system
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_audit_table_record ON audit_logs(table_name, record_id);

-- ==========================================
-- 10. FEATURE FLAGS
-- ==========================================
CREATE TABLE feature_flags (
    flag_key VARCHAR(100) PRIMARY KEY,
    is_enabled BOOLEAN DEFAULT FALSE,
    rollout_percentage INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- ROW LEVEL SECURITY (RLS)
-- ==========================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE guest_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE biological_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE biological_states ENABLE ROW LEVEL SECURITY;
ALTER TABLE wearable_snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE recommendations ENABLE ROW LEVEL SECURITY;
ALTER TABLE timeline_snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE sync_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE feature_flags ENABLE ROW LEVEL SECURITY;

-- Users can read/update their own record
CREATE POLICY "Users access own record" ON users
    FOR ALL USING (auth.uid() = id);

-- Events: Users access own events, Guests isolated by a guest_token logic or anonymous session
CREATE POLICY "Users access own events" ON biological_events
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users access own states" ON biological_states
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users access own recommendations" ON recommendations
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users access own wearables" ON wearable_snapshots
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users access own timeline" ON timeline_snapshots
    FOR ALL USING (auth.uid() = user_id);

-- Feature flags are readable by everyone
CREATE POLICY "Feature flags public read" ON feature_flags
    FOR SELECT USING (true);

-- Guests (Anonymous users without auth.uid) must rely on an RPC or specific token claim 
-- for RLS isolation, but typically we allow anonymous inserts that link to a guest_id, 
-- and reads are gated by passing the guest_id securely.
-- For simplicity in standard Supabase:
CREATE POLICY "Guest access own events" ON biological_events
    FOR ALL USING (guest_id IS NOT NULL AND auth.role() = 'anon');
    
CREATE POLICY "Guest access own states" ON biological_states
    FOR ALL USING (guest_id IS NOT NULL AND auth.role() = 'anon');

-- ==========================================
-- SOFT DELETE VIEWS (Optional abstraction)
-- ==========================================
-- Allows querying `active_biological_events` to automatically filter deleted_at
CREATE OR REPLACE VIEW active_biological_events AS 
SELECT * FROM biological_events WHERE deleted_at IS NULL;

CREATE OR REPLACE VIEW active_biological_states AS 
SELECT * FROM biological_states WHERE deleted_at IS NULL;
