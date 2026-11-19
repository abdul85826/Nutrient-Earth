-- ==============================================================================
-- Migration: 20261117000002_today_experience_engine.sql
-- Description: Establishes the deterministic Streak Engine, Qualifying Activity
--              Event ledger, and Today Experience 2.0 schema extensions.
-- Enforces: Strict RLS, idempotency, server-authoritative calculations, zero fake streaks.
-- ==============================================================================

-- 1. Qualifying Activity Events Ledger
CREATE TABLE IF NOT EXISTS public.user_activity_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL, -- 'task_completed', 'food_logged', 'workout_completed', 'milestone_verified'
    event_data JSONB NOT NULL DEFAULT '{}'::jsonb,
    local_date DATE NOT NULL,
    timezone_id TEXT NOT NULL DEFAULT 'UTC',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    idempotency_key TEXT UNIQUE
);

ALTER TABLE public.user_activity_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can access own activity events"
    ON public.user_activity_events FOR ALL
    USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_activity_events_user_date 
    ON public.user_activity_events (user_id, local_date DESC);

-- 2. User Streak Cache & Summary
CREATE TABLE IF NOT EXISTS public.user_streaks (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    current_streak INT NOT NULL DEFAULT 0 CHECK (current_streak >= 0),
    longest_streak INT NOT NULL DEFAULT 0 CHECK (longest_streak >= 0),
    last_qualifying_date DATE,
    streak_freeze_count INT NOT NULL DEFAULT 0,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.user_streaks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can access own streaks"
    ON public.user_streaks FOR ALL
    USING (auth.uid() = user_id);

-- 3. Profile Schema Extensions for Seasonal & Motion Preferences
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'season_preference') THEN
        ALTER TABLE public.profiles ADD COLUMN season_preference TEXT DEFAULT 'auto';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'reduced_motion') THEN
        ALTER TABLE public.profiles ADD COLUMN reduced_motion BOOLEAN DEFAULT FALSE;
    END IF;
END $$;

-- 4. Deterministic Atomic Streak Calculation Function
CREATE OR REPLACE FUNCTION public.record_qualifying_activity(
    p_event_type TEXT,
    p_local_date DATE,
    p_timezone_id TEXT DEFAULT 'UTC',
    p_event_data JSONB DEFAULT '{}'::jsonb,
    p_idempotency_key TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID;
    v_streak RECORD;
    v_new_current INT;
    v_new_longest INT;
    v_already_qualified BOOLEAN := FALSE;
BEGIN
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    -- Idempotency check: Return existing streak if event already processed
    IF p_idempotency_key IS NOT NULL THEN
        IF EXISTS (SELECT 1 FROM public.user_activity_events WHERE idempotency_key = p_idempotency_key) THEN
            SELECT * INTO v_streak FROM public.user_streaks WHERE user_id = v_user_id;
            RETURN jsonb_build_object(
                'status', 'duplicate_ignored',
                'current_streak', COALESCE(v_streak.current_streak, 0),
                'longest_streak', COALESCE(v_streak.longest_streak, 0),
                'last_qualifying_date', v_streak.last_qualifying_date
            );
        END IF;
    END IF;

    -- Record event in activity ledger
    INSERT INTO public.user_activity_events (
        user_id,
        event_type,
        event_data,
        local_date,
        timezone_id,
        idempotency_key
    ) VALUES (
        v_user_id,
        p_event_type,
        COALESCE(p_event_data, '{}'::jsonb),
        p_local_date,
        COALESCE(p_timezone_id, 'UTC'),
        p_idempotency_key
    );

    -- Load or initialize user streak record
    SELECT * INTO v_streak FROM public.user_streaks WHERE user_id = v_user_id FOR UPDATE;

    IF NOT FOUND THEN
        -- First ever activity
        v_new_current := 1;
        v_new_longest := 1;
        INSERT INTO public.user_streaks (
            user_id,
            current_streak,
            longest_streak,
            last_qualifying_date,
            updated_at
        ) VALUES (
            v_user_id,
            v_new_current,
            v_new_longest,
            p_local_date,
            NOW()
        );
    ELSE
        IF v_streak.last_qualifying_date = p_local_date THEN
            -- Already qualified for this calendar date
            v_new_current := v_streak.current_streak;
            v_new_longest := v_streak.longest_streak;
            v_already_qualified := TRUE;
        ELSIF v_streak.last_qualifying_date = (p_local_date - INTERVAL '1 day')::DATE THEN
            -- Consecutive calendar day: increment streak
            v_new_current := v_streak.current_streak + 1;
            v_new_longest := GREATEST(v_streak.longest_streak, v_new_current);
            UPDATE public.user_streaks
            SET current_streak = v_new_current,
                longest_streak = v_new_longest,
                last_qualifying_date = p_local_date,
                updated_at = NOW()
            WHERE user_id = v_user_id;
        ELSE
            -- Streak broken (gap > 1 day) or brand new: reset to 1
            v_new_current := 1;
            v_new_longest := GREATEST(v_streak.longest_streak, 1);
            UPDATE public.user_streaks
            SET current_streak = v_new_current,
                longest_streak = v_new_longest,
                last_qualifying_date = p_local_date,
                updated_at = NOW()
            WHERE user_id = v_user_id;
        END IF;
    END IF;

    RETURN jsonb_build_object(
        'status', 'success',
        'current_streak', v_new_current,
        'longest_streak', v_new_longest,
        'last_qualifying_date', p_local_date,
        'already_qualified_today', v_already_qualified
    );
END;
$$;

GRANT EXECUTE ON FUNCTION public.record_qualifying_activity(TEXT, DATE, TEXT, JSONB, TEXT) TO authenticated;
