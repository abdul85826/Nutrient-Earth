-- ==============================================================================
-- Migration: 20261103000002_native_health_connect_healthkit_sync.sql
-- Description: Schema updates for native Android Health Connect and iOS HealthKit
--              synchronization, deduplication, audit provenance, and cursor state.
-- ==============================================================================

-- 1. Extend health_measurements table with deduplication and source attributes
DO $$
BEGIN
    -- Update data_source CHECK constraint to support clinical distinction
    ALTER TABLE public.health_measurements DROP CONSTRAINT IF EXISTS health_measurements_data_source_check;
    ALTER TABLE public.health_measurements ADD CONSTRAINT health_measurements_data_source_check
        CHECK (data_source IN ('deviceMeasured', 'wearable', 'userEntered', 'aiEstimated', 'measured', 'userReported'));

    -- Add external record identifier for HealthKit/Health Connect deduplication
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'health_measurements' AND column_name = 'external_record_id') THEN
        ALTER TABLE public.health_measurements ADD COLUMN external_record_id TEXT;
    END IF;

    -- Add source platform ('android_health_connect', 'apple_healthkit', 'manual_entry', 'ai_estimation')
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'health_measurements' AND column_name = 'source_platform') THEN
        ALTER TABLE public.health_measurements ADD COLUMN source_platform TEXT;
    END IF;

    -- Add device model / hardware origin (e.g. 'Apple Watch Series 9', 'Pixel Watch 2', 'iPhone 15')
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'health_measurements' AND column_name = 'device_model') THEN
        ALTER TABLE public.health_measurements ADD COLUMN device_model TEXT;
    END IF;

    -- Add observation timestamps
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'health_measurements' AND column_name = 'recorded_at') THEN
        ALTER TABLE public.health_measurements ADD COLUMN recorded_at TIMESTAMPTZ DEFAULT NOW();
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'health_measurements' AND column_name = 'end_recorded_at') THEN
        ALTER TABLE public.health_measurements ADD COLUMN end_recorded_at TIMESTAMPTZ;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'health_measurements' AND column_name = 'metadata') THEN
        ALTER TABLE public.health_measurements ADD COLUMN metadata JSONB DEFAULT '{}'::jsonb;
    END IF;
END $$;

-- 2. Create non-partial unique index for PostgREST onConflict inference
DROP INDEX IF EXISTS public.idx_health_measurements_dedup;
CREATE UNIQUE INDEX IF NOT EXISTS idx_health_measurements_dedup
    ON public.health_measurements (user_id, source_platform, external_record_id);

-- 3. Create index for timeline queries
CREATE INDEX IF NOT EXISTS idx_health_measurements_user_metric_time
    ON public.health_measurements (user_id, metric_name, recorded_at DESC);

-- 4. Create health_sync_state table for cursor tracking and token management
CREATE TABLE IF NOT EXISTS public.health_sync_state (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    platform TEXT NOT NULL CHECK (platform IN ('android_health_connect', 'apple_healthkit')),
    sync_cursor TEXT,
    last_synced_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metrics_synced JSONB NOT NULL DEFAULT '[]'::jsonb,
    status TEXT NOT NULL DEFAULT 'synced' CHECK (status IN ('synced', 'syncing', 'error', 'revoked', 'unauthorized')),
    error_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_health_sync_state_user_platform UNIQUE (user_id, platform)
);

-- Enable Row Level Security (RLS) on health_sync_state
ALTER TABLE public.health_sync_state ENABLE ROW LEVEL SECURITY;

-- Multi-tenant isolation policy for health_sync_state
DROP POLICY IF EXISTS "Users manage own health sync state" ON public.health_sync_state;
CREATE POLICY "Users manage own health sync state"
    ON public.health_sync_state FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Updated_at trigger for health_sync_state
CREATE OR REPLACE FUNCTION public.set_health_sync_state_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_health_sync_state_updated_at ON public.health_sync_state;
CREATE TRIGGER trg_health_sync_state_updated_at
    BEFORE UPDATE ON public.health_sync_state
    FOR EACH ROW
    EXECUTE FUNCTION public.set_health_sync_state_updated_at();

