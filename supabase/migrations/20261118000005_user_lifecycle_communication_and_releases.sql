-- ==============================================================================
-- Migration: 20261118000005_user_lifecycle_communication_and_releases.sql
-- Description: User Lifecycle, Installation Tracking, Central Communication Engine,
--              Brevo Email Suppression, In-App Notifications, and Release Metadata.
--
-- Components:
--   1. App Installations & Device Lifecycle (Separating User from Device ID)
--   2. Communication Preferences & Quiet Hours (Timezone aware)
--   3. Communication Suppression Registry (Hard bounces, unsubscribes, deletions)
--   4. Communication Events & Delivery Tracking State Machine
--   5. In-App Notification Centre
--   6. App Release Metadata & Minimum Version Gating
--   7. Account Deletion Requests & Suppression Binding
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. App Installations & Device Lifecycle
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.app_installations (
    installation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    platform TEXT NOT NULL CHECK (
        platform IN ('android', 'ios', 'web', 'macos', 'windows')
    ),
    app_version TEXT NOT NULL DEFAULT '1.0.0',
    build_number INT NOT NULL DEFAULT 1,
    push_provider TEXT NOT NULL DEFAULT 'none' CHECK (
        push_provider IN ('fcm', 'apns', 'web_push', 'none')
    ),
    push_token TEXT,
    permission_status TEXT NOT NULL DEFAULT 'not_determined' CHECK (
        permission_status IN ('granted', 'denied', 'provisional', 'not_determined')
    ),
    lifecycle_state TEXT NOT NULL DEFAULT 'ACTIVE' CHECK (
        lifecycle_state IN ('ACTIVE', 'INACTIVE', 'TOKEN_INVALID', 'REGISTRATION_STALE', 'PERMISSION_DENIED', 'REGISTRATION_REVOKED', 'UNKNOWN')
    ),
    token_validity_state TEXT NOT NULL DEFAULT 'valid' CHECK (
        token_validity_state IN ('valid', 'invalid', 'refresh_required')
    ),
    last_sync_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    last_activity_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    registered_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    revoked_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_installations_user ON public.app_installations (user_id);
CREATE INDEX IF NOT EXISTS idx_installations_token ON public.app_installations (push_token) WHERE push_token IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_installations_state ON public.app_installations (lifecycle_state);

-- ------------------------------------------------------------------------------
-- 2. Communication Preferences & Quiet Hours
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.communication_preferences (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    timezone_iana TEXT NOT NULL DEFAULT 'UTC',
    quiet_hours_start_local TIME NOT NULL DEFAULT '21:00:00',
    quiet_hours_end_local TIME NOT NULL DEFAULT '06:00:00',
    allow_push BOOLEAN NOT NULL DEFAULT true,
    allow_email_transactional BOOLEAN NOT NULL DEFAULT true,
    allow_email_engagement BOOLEAN NOT NULL DEFAULT true,
    allow_in_app BOOLEAN NOT NULL DEFAULT true,
    goal_reminders_enabled BOOLEAN NOT NULL DEFAULT true,
    research_updates_enabled BOOLEAN NOT NULL DEFAULT true,
    daily_summary_enabled BOOLEAN NOT NULL DEFAULT true,
    max_push_per_day INT NOT NULL DEFAULT 3,
    max_email_per_week INT NOT NULL DEFAULT 2,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- ------------------------------------------------------------------------------
-- 3. Communication Suppression Registry
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.communication_suppressions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient_identifier TEXT NOT NULL,
    suppression_type TEXT NOT NULL CHECK (
        suppression_type IN ('hard_bounce', 'complaint', 'user_unsubscribe', 'account_deleted', 'frequency_cap')
    ),
    reason TEXT,
    suppressed_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    UNIQUE(recipient_identifier, suppression_type)
);

CREATE INDEX IF NOT EXISTS idx_suppressions_recipient ON public.communication_suppressions (recipient_identifier);

-- ------------------------------------------------------------------------------
-- 4. Communication Events & Delivery Tracking
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.communication_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    installation_id UUID REFERENCES public.app_installations(installation_id) ON DELETE SET NULL,
    triggering_event_id TEXT NOT NULL,
    event_category TEXT NOT NULL CHECK (
        event_category IN ('goal_reminder', 'research_digest', 'security_alert', 'account_export', 're_engagement', 'system_update')
    ),
    channel TEXT NOT NULL CHECK (
        channel IN ('push_fcm', 'push_apns', 'email_brevo', 'in_app')
    ),
    payload JSONB NOT NULL DEFAULT '{}'::jsonb,
    status TEXT NOT NULL DEFAULT 'CREATED' CHECK (
        status IN (
            'CREATED',
            'ELIGIBILITY_CHECKED',
            'QUEUED',
            'SUBMITTED',
            'PROVIDER_ACCEPTED',
            'PROVIDER_REJECTED',
            'DELIVERED',
            'OPENED',
            'EXPIRED',
            'SUPPRESSED'
        )
    ),
    suppression_reason TEXT,
    retry_count INT NOT NULL DEFAULT 0,
    idempotency_key TEXT UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_comm_events_user ON public.communication_events (user_id);
CREATE INDEX IF NOT EXISTS idx_comm_events_status ON public.communication_events (status);
CREATE INDEX IF NOT EXISTS idx_comm_events_idemp ON public.communication_events (idempotency_key);

-- ------------------------------------------------------------------------------
-- 5. In-App Notification Centre
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.in_app_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'general',
    deep_link_route TEXT,
    is_read BOOLEAN NOT NULL DEFAULT false,
    is_archived BOOLEAN NOT NULL DEFAULT false,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_in_app_user ON public.in_app_notifications (user_id);
CREATE INDEX IF NOT EXISTS idx_in_app_read ON public.in_app_notifications (is_read);

-- ------------------------------------------------------------------------------
-- 6. App Release Metadata & Version Gating
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.app_release_metadata (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    platform TEXT NOT NULL CHECK (
        platform IN ('android', 'ios', 'web', 'macos', 'windows')
    ),
    version_name TEXT NOT NULL,
    build_number INT NOT NULL,
    min_supported_version TEXT NOT NULL,
    is_critical_security_update BOOLEAN NOT NULL DEFAULT false,
    release_notes TEXT NOT NULL,
    store_url TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    published_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    UNIQUE(platform, build_number)
);

CREATE INDEX IF NOT EXISTS idx_release_platform ON public.app_release_metadata (platform, is_active);

-- Seed initial approved release v1.0.0 (build 1)
INSERT INTO public.app_release_metadata (platform, version_name, build_number, min_supported_version, release_notes, store_url, is_active)
VALUES
    ('android', '1.0.0', 1, '1.0.0', 'Initial Production Release: Food intelligence, living avatar, and scientific research.', 'https://play.google.com/store/apps/details?id=com.nutrientearth.app', true),
    ('ios', '1.0.0', 1, '1.0.0', 'Initial Production Release: Food intelligence, living avatar, and scientific research.', 'https://apps.apple.com/app/id6470000000', true)
ON CONFLICT (platform, build_number) DO NOTHING;

-- ------------------------------------------------------------------------------
-- 7. Account Deletion Requests & Suppression
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.account_deletion_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (
        status IN ('pending', 'processing', 'completed', 'cancelled')
    ),
    suppression_applied BOOLEAN NOT NULL DEFAULT false,
    crypto_shredding_completed BOOLEAN NOT NULL DEFAULT false,
    reason TEXT,
    requested_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    completed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_deletion_user ON public.account_deletion_requests (user_id);

-- ------------------------------------------------------------------------------
-- 8. Row Level Security Hardening
-- ------------------------------------------------------------------------------
ALTER TABLE public.app_installations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.communication_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.communication_suppressions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.communication_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.in_app_notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_release_metadata ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.account_deletion_requests ENABLE ROW LEVEL SECURITY;

-- Installations: users manage own installations; anonymous can register fresh installation
CREATE POLICY "Users read own installations" ON public.app_installations
    FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "Users insert/update own installations" ON public.app_installations
    FOR ALL TO authenticated, anon USING (true) WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

-- Preferences: user-isolated
CREATE POLICY "Users manage own preferences" ON public.communication_preferences
    FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- In-App Notifications: user-isolated
CREATE POLICY "Users manage own in-app notifications" ON public.in_app_notifications
    FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Releases: public read
CREATE POLICY "Public read releases" ON public.app_release_metadata
    FOR SELECT TO authenticated, anon USING (is_active = true);

-- Deletion requests: user-isolated
CREATE POLICY "Users manage deletion requests" ON public.account_deletion_requests
    FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
