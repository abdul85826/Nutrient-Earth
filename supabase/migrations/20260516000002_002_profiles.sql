-- 002_profiles.sql

DROP TABLE IF EXISTS profiles CASCADE;

CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    
    -- Basic Demographics
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    
    -- Lifestyle
    occupation VARCHAR(100),
    activity_level VARCHAR(20), -- sedentary, light, moderate, active, very_active
    stress_level VARCHAR(20), -- low, medium, high
    
    -- Goals
    primary_goal VARCHAR(50),
    secondary_goals TEXT[],
    
    -- Location
    current_city VARCHAR(100),
    current_country VARCHAR(100),
    timezone VARCHAR(50),
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON profiles(user_id);

-- RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access their own profile" ON profiles FOR ALL USING (auth.uid() = user_id);
