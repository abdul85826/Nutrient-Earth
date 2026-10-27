-- ==============================================================================
-- Migration: 20261026000001_rls_security_hardening.sql
-- Description: Hardens Row Level Security (RLS) policies, enforces explicit
--              WITH CHECK clauses, adds storage deletion capabilities, and
--              validates document size constraints.
-- ==============================================================================

-- 1. Profiles Table Hardening: Enforce explicit WITH CHECK & operation separation
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;

CREATE POLICY "Users can update own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own profile"
    ON public.profiles FOR DELETE
    USING (auth.uid() = user_id);

-- 2. Health Measurements: Enforce explicit WITH CHECK
DROP POLICY IF EXISTS "Users can access own health measurements" ON public.health_measurements;

CREATE POLICY "Users can view own health measurements"
    ON public.health_measurements FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own health measurements"
    ON public.health_measurements FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own health measurements"
    ON public.health_measurements FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own health measurements"
    ON public.health_measurements FOR DELETE
    USING (auth.uid() = user_id);

-- 3. Health Reports: Constraint Fix & Scoped Policies
ALTER TABLE public.health_reports
    DROP CONSTRAINT IF EXISTS health_reports_file_size_check;

ALTER TABLE public.health_reports
    ADD CONSTRAINT health_reports_file_size_check
    CHECK (file_size > 0 AND file_size <= 15728640); -- Explicitly rejects non-positive size

DROP POLICY IF EXISTS "Users can access own uploaded health reports" ON public.health_reports;

CREATE POLICY "Users can view own health reports"
    ON public.health_reports FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own health reports"
    ON public.health_reports FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own health reports"
    ON public.health_reports FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own health reports"
    ON public.health_reports FOR DELETE
    USING (auth.uid() = user_id);

-- 4. Storage Bucket Policies: Enable Right-to-Erasure (DELETE) & Safe UPDATE
CREATE POLICY "Users can delete their own reports"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'health-reports' AND
        (storage.foldername(name))[1] = auth.uid()::text
    );

CREATE POLICY "Users can update their own reports"
    ON storage.objects FOR UPDATE
    USING (
        bucket_id = 'health-reports' AND
        (storage.foldername(name))[1] = auth.uid()::text
    )
    WITH CHECK (
        bucket_id = 'health-reports' AND
        (storage.foldername(name))[1] = auth.uid()::text
    );
