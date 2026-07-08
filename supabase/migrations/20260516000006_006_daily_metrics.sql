-- 006_daily_metrics.sql

DROP TABLE IF EXISTS daily_metrics CASCADE;

CREATE TABLE daily_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    
    -- Sleep
    sleep_hours DECIMAL(4,2),
    sleep_quality VARCHAR(20),
    
    -- Hydration
    water_intake_ml INTEGER DEFAULT 0,
    
    -- Energy & Stress
    energy_level INTEGER CHECK (energy_level BETWEEN 1 AND 10),
    stress_level INTEGER CHECK (stress_level BETWEEN 1 AND 10),
    
    -- Habits & Compliance
    tasks_completed INTEGER DEFAULT 0,
    total_tasks INTEGER DEFAULT 0,
    
    -- Logged Symptoms
    symptoms_tracked TEXT[],
    daily_state VARCHAR(20) DEFAULT 'normal', -- low_energy, high_energy
    
    -- Metadata
    logged_at TIMESTAMP DEFAULT NOW(),
    
    UNIQUE(user_id, date)
);

CREATE INDEX IF NOT EXISTS idx_daily_metrics_user_date ON daily_metrics(user_id, date);

-- RLS
ALTER TABLE daily_metrics ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access their own daily metrics" ON daily_metrics FOR ALL USING (auth.uid() = user_id);
