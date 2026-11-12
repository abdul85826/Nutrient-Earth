-- ==============================================================================
-- Migration: 20261112000002_add_difficulties_note_to_profiles.sql
-- Description: Adds difficulties_note column to public.profiles to persist
--              the user's authentic Step 2 additional free-text notes.
-- ==============================================================================

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
          AND table_name = 'profiles' 
          AND column_name = 'difficulties_note'
    ) THEN
        ALTER TABLE public.profiles ADD COLUMN difficulties_note TEXT DEFAULT '';
    END IF;
END $$;

