-- 004_environment_logs.sql

DROP TABLE IF EXISTS environment_logs CASCADE;

CREATE TABLE environment_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    -- Location
    city VARCHAR(100),
    country VARCHAR(100),
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    
    -- Air Quality
    aqi INTEGER,
    aqi_category VARCHAR(20), -- good, moderate, unhealthy, hazardous
    pm25 DECIMAL(6,2),
    
    -- Weather
    temperature_c DECIMAL(5,2),
    humidity_percent INTEGER,
    uv_index INTEGER,
    weather_condition VARCHAR(50),
    
    -- Timestamp
    recorded_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_environment_logs_user_time ON environment_logs(user_id, recorded_at);

-- RLS
ALTER TABLE environment_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access their own environment logs" ON environment_logs FOR ALL USING (auth.uid() = user_id);
