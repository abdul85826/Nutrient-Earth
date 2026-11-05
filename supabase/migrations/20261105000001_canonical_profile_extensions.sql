-- ==============================================================================
-- Migration: 20261105000001_canonical_profile_extensions.sql
-- Description: Extends public.profiles with canonical onboarding attributes:
--              allergies, body measurements, eating routine, sleep quality,
--              knowledge level, difficulties, and onboarding completion status.
-- ==============================================================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'allergies') THEN
        ALTER TABLE public.profiles ADD COLUMN allergies TEXT[] NOT NULL DEFAULT '{}';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'height_cm') THEN
        ALTER TABLE public.profiles ADD COLUMN height_cm NUMERIC;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'weight_kg') THEN
        ALTER TABLE public.profiles ADD COLUMN weight_kg NUMERIC;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'eating_routine') THEN
        ALTER TABLE public.profiles ADD COLUMN eating_routine TEXT DEFAULT 'regular';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'sleep_quality') THEN
        ALTER TABLE public.profiles ADD COLUMN sleep_quality TEXT DEFAULT 'good_consistent';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'knowledge_level') THEN
        ALTER TABLE public.profiles ADD COLUMN knowledge_level TEXT DEFAULT 'basics';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'difficulties') THEN
        ALTER TABLE public.profiles ADD COLUMN difficulties TEXT[] NOT NULL DEFAULT '{}';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'daily_impacts') THEN
        ALTER TABLE public.profiles ADD COLUMN daily_impacts JSONB NOT NULL DEFAULT '{}'::jsonb;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'onboarding_completed') THEN
        ALTER TABLE public.profiles ADD COLUMN onboarding_completed BOOLEAN NOT NULL DEFAULT FALSE;
    END IF;
END $$;

