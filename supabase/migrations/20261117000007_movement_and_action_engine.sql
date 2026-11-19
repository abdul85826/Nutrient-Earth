-- ==============================================================================
-- Migration: 20261117000007_movement_and_action_engine.sql
-- Description: Goal-Driven Movement & Action Engine (JITAI Architecture)
--              - Just-In-Time Adaptive Intervention task lifecycle:
--                'planned' -> 'available' -> 'started' -> 'completed' / 'skipped' / 'deferred'
--              - Weather and environmental awareness (indoor fallback on rain/AQI spikes)
--              - Sensor-verified vs. user-reported completion modes
--              - Multi-tenant isolation with strict Row Level Security (RLS)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.movement_tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    goal_id TEXT,
    title TEXT NOT NULL,
    description TEXT,
    movement_category TEXT NOT NULL CHECK (
        movement_category IN (
            'aerobic_endurance',
            'musculoskeletal_strength',
            'postprandial_metabolic',
            'circadian_photobiology',
            'restorative_mobility'
        )
    ),
    target_duration_minutes INT NOT NULL DEFAULT 15,
    target_steps INT,
    target_met_hours NUMERIC(4,2),
    preferred_time_of_day TEXT NOT NULL DEFAULT 'anytime' CHECK (
        preferred_time_of_day IN ('morning', 'midday', 'afternoon', 'evening', 'anytime')
    ),
    is_outdoor_dependent BOOLEAN NOT NULL DEFAULT false,
    indoor_alternative_title TEXT,
    indoor_alternative_description TEXT,
    current_status TEXT NOT NULL DEFAULT 'planned' CHECK (
        current_status IN ('planned', 'available', 'started', 'completed', 'skipped', 'deferred')
    ),
    completion_mode TEXT CHECK (
        completion_mode IN ('user_self_reported', 'sensor_step_verified', 'sensor_hr_verified', 'hybrid_verified')
    ),
    completion_telemetry JSONB,
    adaptation_reason TEXT,
    scheduled_date DATE NOT NULL DEFAULT CURRENT_DATE,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_movement_tasks_user_date_status
    ON public.movement_tasks (user_id, scheduled_date, current_status);

ALTER TABLE public.movement_tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own movement tasks"
    ON public.movement_tasks FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can insert own movement tasks"
    ON public.movement_tasks FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can update own movement tasks"
    ON public.movement_tasks FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can delete own movement tasks"
    ON public.movement_tasks FOR DELETE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

-- ------------------------------------------------------------------------------
-- Stored Procedure: Adapt Task Based on Environmental Context
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.adapt_movement_task_for_environment(
    p_task_id UUID,
    p_user_id UUID,
    p_is_weather_adverse BOOLEAN,
    p_air_quality_index INT,
    p_reason TEXT
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_task RECORD;
BEGIN
    IF auth.uid() != p_user_id THEN
        RAISE EXCEPTION 'Access denied. You can only adapt tasks for yourself.';
    END IF;

    SELECT * INTO v_task
    FROM public.movement_tasks
    WHERE id = p_task_id AND user_id = p_user_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Movement task not found.';
    END IF;

    -- If the task is outdoor-dependent and environment is adverse (rain or AQI > 100),
    -- substitute the title and description with the indoor alternative.
    IF v_task.is_outdoor_dependent AND (p_is_weather_adverse OR p_air_quality_index > 100) THEN
        UPDATE public.movement_tasks
        SET title = COALESCE(v_task.indoor_alternative_title, v_task.title || ' (Indoor Adaptation)'),
            description = COALESCE(v_task.indoor_alternative_description, v_task.description),
            adaptation_reason = p_reason,
            updated_at = timezone('utc'::text, now())
        WHERE id = p_task_id;
    END IF;

    RETURN p_task_id;
END;
$$;
