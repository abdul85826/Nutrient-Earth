-- ==============================================================================
-- Migration: 20261121000001_streak_engine_recovery.sql
-- Description: Production-Grade Deterministic Streak Engine with Qualifying Activity
--              Ledger, Timezone-Aware Calculations, Idempotency, and Audit History.
-- ==============================================================================

-- 1. Ensure user_activity_events has all required forensic and timezone columns
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'user_activity_events' AND column_name = 'activity_type') THEN
        ALTER TABLE public.user_activity_events ADD COLUMN activity_type TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'user_activity_events' AND column_name = 'event_timestamp') THEN
        ALTER TABLE public.user_activity_events ADD COLUMN event_timestamp TIMESTAMPTZ DEFAULT NOW();
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'user_activity_events' AND column_name = 'user_local_date') THEN
        ALTER TABLE public.user_activity_events ADD COLUMN user_local_date DATE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'user_activity_events' AND column_name = 'iana_timezone') THEN
        ALTER TABLE public.user_activity_events ADD COLUMN iana_timezone TEXT DEFAULT 'UTC';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'user_activity_events' AND column_name = 'qualification_result') THEN
        ALTER TABLE public.user_activity_events ADD COLUMN qualification_result BOOLEAN DEFAULT TRUE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'user_activity_events' AND column_name = 'qualification_rule_version') THEN
        ALTER TABLE public.user_activity_events ADD COLUMN qualification_rule_version TEXT DEFAULT 'v1.0.0';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'user_activity_events' AND column_name = 'source_record_reference') THEN
        ALTER TABLE public.user_activity_events ADD COLUMN source_record_reference TEXT;
    END IF;
END $$;

-- Populate user_local_date from local_date if null
UPDATE public.user_activity_events 
SET user_local_date = local_date 
WHERE user_local_date IS NULL AND local_date IS NOT NULL;

-- Populate activity_type from event_type if null
UPDATE public.user_activity_events 
SET activity_type = event_type 
WHERE activity_type IS NULL AND event_type IS NOT NULL;

-- Ensure indexes for fast timezone-aware queries
CREATE INDEX IF NOT EXISTS idx_activity_events_user_local_date 
    ON public.user_activity_events (user_id, user_local_date DESC);

CREATE INDEX IF NOT EXISTS idx_activity_events_user_qual 
    ON public.user_activity_events (user_id, qualification_result, user_local_date DESC);

-- 2. Ensure user_streaks has all required summary columns
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'user_streaks' AND column_name = 'qualified_activity_days') THEN
        ALTER TABLE public.user_streaks ADD COLUMN qualified_activity_days INT DEFAULT 0;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'user_streaks' AND column_name = 'is_today_qualified') THEN
        ALTER TABLE public.user_streaks ADD COLUMN is_today_qualified BOOLEAN DEFAULT FALSE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'user_streaks' AND column_name = 'last_calculated_at') THEN
        ALTER TABLE public.user_streaks ADD COLUMN last_calculated_at TIMESTAMPTZ DEFAULT NOW();
    END IF;
END $$;

-- 3. Production-Grade Atomic Record Qualifying Activity Function
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
    v_new_total_days INT;
    v_already_qualified BOOLEAN := FALSE;
    v_is_qualifying BOOLEAN := TRUE;
    v_rule_version TEXT := 'v1.0.0';
    v_source_ref TEXT;
BEGIN
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    -- Extract source reference if available
    v_source_ref := p_event_data->>'source_reference';

    -- A1. Qualifying Activity Qualification Policy
    -- Opening app, screen viewing, notification receipt, and raw clicks MUST NOT qualify
    IF p_event_type IN ('app_opened', 'screen_viewed', 'button_clicked', 'notification_received', 'view_evidence') THEN
        v_is_qualifying := FALSE;
    ELSIF p_event_type IN (
        'daily_task_completed', 'task_completed',
        'meal_logged', 'food_logged',
        'workout_logged', 'workout_completed', 'movement_logged',
        'lifestyle_activity_completed', 'milestone_verified',
        'learn_completed'
    ) THEN
        v_is_qualifying := TRUE;
    ELSE
        -- Conservative fallback for unrecognized event types
        v_is_qualifying := FALSE;
    END IF;

    -- Idempotency check: Return existing streak if event already processed
    IF p_idempotency_key IS NOT NULL THEN
        IF EXISTS (SELECT 1 FROM public.user_activity_events WHERE idempotency_key = p_idempotency_key) THEN
            SELECT * INTO v_streak FROM public.user_streaks WHERE user_id = v_user_id;
            RETURN jsonb_build_object(
                'status', 'duplicate_ignored',
                'current_streak', COALESCE(v_streak.current_streak, 0),
                'longest_streak', COALESCE(v_streak.longest_streak, 0),
                'last_qualifying_date', v_streak.last_qualifying_date,
                'qualified_activity_days', COALESCE(v_streak.qualified_activity_days, 0),
                'already_qualified_today', (v_streak.last_qualifying_date = p_local_date)
            );
        END IF;
    END IF;

    -- Insert into immutable user_activity_events ledger
    INSERT INTO public.user_activity_events (
        user_id,
        event_type,
        activity_type,
        event_data,
        local_date,
        user_local_date,
        timezone_id,
        iana_timezone,
        qualification_result,
        qualification_rule_version,
        source_record_reference,
        event_timestamp,
        created_at,
        idempotency_key
    ) VALUES (
        v_user_id,
        p_event_type,
        p_event_type,
        COALESCE(p_event_data, '{}'::jsonb),
        p_local_date,
        p_local_date,
        COALESCE(p_timezone_id, 'UTC'),
        COALESCE(p_timezone_id, 'UTC'),
        v_is_qualifying,
        v_rule_version,
        v_source_ref,
        NOW(),
        NOW(),
        p_idempotency_key
    );

    -- If event did not qualify, do not update streak
    IF NOT v_is_qualifying THEN
        SELECT * INTO v_streak FROM public.user_streaks WHERE user_id = v_user_id;
        RETURN jsonb_build_object(
            'status', 'non_qualifying_recorded',
            'current_streak', COALESCE(v_streak.current_streak, 0),
            'longest_streak', COALESCE(v_streak.longest_streak, 0),
            'last_qualifying_date', v_streak.last_qualifying_date,
            'qualified_activity_days', COALESCE(v_streak.qualified_activity_days, 0),
            'already_qualified_today', (v_streak.last_qualifying_date = p_local_date)
        );
    END IF;

    -- Load user streak record with row-level lock
    SELECT * INTO v_streak FROM public.user_streaks WHERE user_id = v_user_id FOR UPDATE;

    IF NOT FOUND THEN
        -- First ever qualifying activity for user
        v_new_current := 1;
        v_new_longest := 1;
        v_new_total_days := 1;
        INSERT INTO public.user_streaks (
            user_id,
            current_streak,
            longest_streak,
            last_qualifying_date,
            qualified_activity_days,
            is_today_qualified,
            last_calculated_at,
            updated_at
        ) VALUES (
            v_user_id,
            v_new_current,
            v_new_longest,
            p_local_date,
            v_new_total_days,
            TRUE,
            NOW(),
            NOW()
        );
    ELSE
        v_new_total_days := COALESCE(v_streak.qualified_activity_days, 0);

        IF v_streak.last_qualifying_date = p_local_date THEN
            -- Already qualified on this calendar date
            v_new_current := v_streak.current_streak;
            v_new_longest := v_streak.longest_streak;
            v_already_qualified := TRUE;

            UPDATE public.user_streaks
            SET is_today_qualified = TRUE,
                last_calculated_at = NOW(),
                updated_at = NOW()
            WHERE user_id = v_user_id;
        ELSIF v_streak.last_qualifying_date = (p_local_date - INTERVAL '1 day')::DATE THEN
            -- Consecutive calendar day: increment streak
            v_new_current := v_streak.current_streak + 1;
            v_new_longest := GREATEST(v_streak.longest_streak, v_new_current);
            v_new_total_days := v_new_total_days + 1;

            UPDATE public.user_streaks
            SET current_streak = v_new_current,
                longest_streak = v_new_longest,
                last_qualifying_date = p_local_date,
                qualified_activity_days = v_new_total_days,
                is_today_qualified = TRUE,
                last_calculated_at = NOW(),
                updated_at = NOW()
            WHERE user_id = v_user_id;
        ELSE
            -- Streak broken (gap > 1 day) or brand new restart: reset to 1
            v_new_current := 1;
            v_new_longest := GREATEST(v_streak.longest_streak, 1);
            v_new_total_days := v_new_total_days + 1;

            UPDATE public.user_streaks
            SET current_streak = v_new_current,
                longest_streak = v_new_longest,
                last_qualifying_date = p_local_date,
                qualified_activity_days = v_new_total_days,
                is_today_qualified = TRUE,
                last_calculated_at = NOW(),
                updated_at = NOW()
            WHERE user_id = v_user_id;
        END IF;
    END IF;

    RETURN jsonb_build_object(
        'status', 'success',
        'current_streak', v_new_current,
        'longest_streak', v_new_longest,
        'last_qualifying_date', p_local_date,
        'qualified_activity_days', v_new_total_days,
        'already_qualified_today', v_already_qualified
    );
END;
$$;

-- 4. Get User Streak with Local Timezone & Day-End Preservation
CREATE OR REPLACE FUNCTION public.get_user_streak(
    p_local_date DATE,
    p_timezone_id TEXT DEFAULT 'UTC'
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID;
    v_streak RECORD;
    v_effective_streak INT := 0;
    v_is_today_qualified BOOLEAN := FALSE;
BEGIN
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    SELECT * INTO v_streak FROM public.user_streaks WHERE user_id = v_user_id;

    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'current_streak', 0,
            'longest_streak', 0,
            'last_qualifying_date', NULL,
            'qualified_activity_days', 0,
            'is_today_qualified', FALSE
        );
    END IF;

    -- Evaluate effective streak based on local calendar date:
    -- If qualified today: streak is alive and active
    IF v_streak.last_qualifying_date = p_local_date THEN
        v_effective_streak := v_streak.current_streak;
        v_is_today_qualified := TRUE;
    -- If qualified yesterday: today is still in progress! Do not reset streak before user local day ends!
    ELSIF v_streak.last_qualifying_date = (p_local_date - INTERVAL '1 day')::DATE THEN
        v_effective_streak := v_streak.current_streak;
        v_is_today_qualified := FALSE;
    -- If older than yesterday: streak has lapsed
    ELSE
        v_effective_streak := 0;
        v_is_today_qualified := FALSE;
    END IF;

    RETURN jsonb_build_object(
        'current_streak', v_effective_streak,
        'longest_streak', v_streak.longest_streak,
        'last_qualifying_date', v_streak.last_qualifying_date,
        'qualified_activity_days', COALESCE(v_streak.qualified_activity_days, 0),
        'is_today_qualified', v_is_today_qualified
    );
END;
$$;

-- 5. Deterministic Reconciliation / Rebuild Function
CREATE OR REPLACE FUNCTION public.recalculate_user_streak(
    p_target_user_id UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID;
    v_r RECORD;
    v_curr INT := 0;
    v_longest INT := 0;
    v_total_days INT := 0;
    v_last_date DATE := NULL;
    v_prev_date DATE := NULL;
BEGIN
    v_user_id := COALESCE(p_target_user_id, auth.uid());
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'User ID required';
    END IF;

    -- Iterate through distinct qualifying dates in ascending order
    FOR v_r IN (
        SELECT DISTINCT user_local_date 
        FROM public.user_activity_events
        WHERE user_id = v_user_id 
          AND qualification_result = TRUE
          AND user_local_date IS NOT NULL
        ORDER BY user_local_date ASC
    ) LOOP
        v_total_days := v_total_days + 1;

        IF v_prev_date IS NULL THEN
            v_curr := 1;
            v_longest := 1;
        ELSIF v_r.user_local_date = (v_prev_date + INTERVAL '1 day')::DATE THEN
            v_curr := v_curr + 1;
            v_longest := GREATEST(v_longest, v_curr);
        ELSE
            -- Gap > 1 day: reset
            v_curr := 1;
            v_longest := GREATEST(v_longest, 1);
        END IF;

        v_prev_date := v_r.user_local_date;
        v_last_date := v_r.user_local_date;
    END LOOP;

    -- Upsert reconstructed summary into user_streaks
    INSERT INTO public.user_streaks (
        user_id,
        current_streak,
        longest_streak,
        last_qualifying_date,
        qualified_activity_days,
        is_today_qualified,
        last_calculated_at,
        updated_at
    ) VALUES (
        v_user_id,
        v_curr,
        v_longest,
        v_last_date,
        v_total_days,
        (v_last_date = CURRENT_DATE),
        NOW(),
        NOW()
    )
    ON CONFLICT (user_id) DO UPDATE SET
        current_streak = EXCLUDED.current_streak,
        longest_streak = EXCLUDED.longest_streak,
        last_qualifying_date = EXCLUDED.last_qualifying_date,
        qualified_activity_days = EXCLUDED.qualified_activity_days,
        is_today_qualified = EXCLUDED.is_today_qualified,
        last_calculated_at = NOW(),
        updated_at = NOW();

    RETURN jsonb_build_object(
        'status', 'recalculated',
        'current_streak', v_curr,
        'longest_streak', v_longest,
        'last_qualifying_date', v_last_date,
        'qualified_activity_days', v_total_days
    );
END;
$$;

GRANT EXECUTE ON FUNCTION public.record_qualifying_activity(TEXT, DATE, TEXT, JSONB, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_streak(DATE, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.recalculate_user_streak(UUID) TO authenticated;
