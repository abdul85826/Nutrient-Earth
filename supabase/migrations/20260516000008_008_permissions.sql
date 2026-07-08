-- 008_permissions.sql

DROP TABLE IF EXISTS permissions CASCADE;

CREATE TABLE permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    
    -- Hardware Permissions
    camera_enabled BOOLEAN DEFAULT FALSE,
    location_enabled BOOLEAN DEFAULT FALSE,
    notifications_enabled BOOLEAN DEFAULT FALSE,
    health_connect_enabled BOOLEAN DEFAULT FALSE,
    
    -- Data Privacy
    share_anonymous_data BOOLEAN DEFAULT FALSE,
    allow_ai_training BOOLEAN DEFAULT FALSE,
    
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_permissions_user_id ON permissions(user_id);

-- RLS
ALTER TABLE permissions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access their own permissions" ON permissions FOR ALL USING (auth.uid() = user_id);
