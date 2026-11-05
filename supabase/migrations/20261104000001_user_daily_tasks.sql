-- ==============================================================================
-- Migration: 20261104000001_user_daily_tasks.sql
-- Description: Authentic user daily tasks schema with user isolation (RLS).
--              Preserves authentic user goals, routines, and daily plan tasks
--              while guaranteeing zero fabricated tasks for new accounts.
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.user_daily_tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    note TEXT,
    scheduled_time TEXT,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    is_up_next BOOLEAN NOT NULL DEFAULT FALSE,
    goal_category TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for efficient queries
CREATE INDEX IF NOT EXISTS idx_user_daily_tasks_user_created
    ON public.user_daily_tasks (user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_user_daily_tasks_user_status
    ON public.user_daily_tasks (user_id, is_completed);

-- Enable Row Level Security (RLS)
ALTER TABLE public.user_daily_tasks ENABLE ROW LEVEL SECURITY;

-- RLS Policies: Multi-tenant user data isolation
CREATE POLICY "Users can view their own daily tasks"
    ON public.user_daily_tasks
    FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own daily tasks"
    ON public.user_daily_tasks
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own daily tasks"
    ON public.user_daily_tasks
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own daily tasks"
    ON public.user_daily_tasks
    FOR DELETE
    USING (auth.uid() = user_id);

