-- Add missing columns to public.users table if they don't already exist
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS subscription_tier VARCHAR(50) DEFAULT 'free' NOT NULL;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS onboarding_step INT DEFAULT 0 NOT NULL;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS profile_completed BOOLEAN DEFAULT FALSE NOT NULL;
