-- Migration: NE Core Engine v1
-- Adds missing fields to user_profiles and daily_progress for health tracking

ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS diabetes_status TEXT,
ADD COLUMN IF NOT EXISTS activity_level TEXT,
ADD COLUMN IF NOT EXISTS sleep_hours DECIMAL(5,2),
ADD COLUMN IF NOT EXISTS diet_preference TEXT;

ALTER TABLE daily_progress
ADD COLUMN IF NOT EXISTS steps INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS symptoms_tracked JSONB DEFAULT '[]'::jsonb,
ADD COLUMN IF NOT EXISTS plan_completed BOOLEAN DEFAULT FALSE;
