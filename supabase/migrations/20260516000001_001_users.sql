-- 001_users.sql
-- We extend or recreate the users table. Assuming we drop existing to rebuild according to the new spec.
-- NOTE: In production, we would use ALTER TABLE. For development, we drop and recreate.

DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE users (
    -- Identity
    id UUID PRIMARY KEY DEFAULT auth.uid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    last_active TIMESTAMP,
    
    -- Authentication
    auth_provider VARCHAR(50) DEFAULT 'email', -- email, google, apple
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    
    -- Account status
    status VARCHAR(20) DEFAULT 'active', -- active, inactive, suspended
    subscription_tier VARCHAR(20) DEFAULT 'free', -- free, pro, premium
    subscription_expires_at TIMESTAMP,
    
    -- Privacy & Permissions
    data_sharing_consent BOOLEAN DEFAULT FALSE,
    research_consent BOOLEAN DEFAULT FALSE,
    marketing_consent BOOLEAN DEFAULT FALSE,
    
    -- Metadata
    device_info JSONB, -- {platform: "ios", version: "1.2.0"}
    app_version VARCHAR(20),
    timezone VARCHAR(50),
    language VARCHAR(10) DEFAULT 'en'
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);
CREATE INDEX IF NOT EXISTS idx_users_subscription ON users(subscription_tier);

-- RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access their own data" ON users FOR ALL USING (auth.uid() = id);
