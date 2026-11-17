-- ==============================================================================
-- Migration: 20261117000001_living_avatar_engine.sql
-- Description: Extends public.profiles with Living Avatar Engine attributes:
--              has_avatar, skin_tone, and avatar_config.
--              Implements secure RPC update_avatar for atomic creation and persistence.
-- ==============================================================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'has_avatar') THEN
        ALTER TABLE public.profiles ADD COLUMN has_avatar BOOLEAN NOT NULL DEFAULT FALSE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'skin_tone') THEN
        ALTER TABLE public.profiles ADD COLUMN skin_tone TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'avatar_config') THEN
        ALTER TABLE public.profiles ADD COLUMN avatar_config JSONB NOT NULL DEFAULT '{}'::jsonb;
    END IF;
END $$;

-- Atomic RPC function to update user avatar state
CREATE OR REPLACE FUNCTION public.update_avatar(
    p_skin_tone TEXT,
    p_avatar_config JSONB DEFAULT '{}'::jsonb
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID;
    v_result JSONB;
BEGIN
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    UPDATE public.profiles
    SET 
        has_avatar = TRUE,
        skin_tone = p_skin_tone,
        avatar_config = COALESCE(p_avatar_config, '{}'::jsonb),
        updated_at = NOW()
    WHERE user_id = v_user_id
    RETURNING to_jsonb(profiles.*) INTO v_result;

    RETURN v_result;
END;
$$;

-- Grant execution to authenticated users
GRANT EXECUTE ON FUNCTION public.update_avatar(TEXT, JSONB) TO authenticated;
