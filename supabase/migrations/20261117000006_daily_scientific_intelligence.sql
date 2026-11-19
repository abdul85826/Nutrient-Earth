-- ==============================================================================
-- Migration: 20261117000006_daily_scientific_intelligence.sql
-- Description: Daily Scientific Intelligence Feed & Engagement State Machine.
--              - Curated 5-article daily editions personalized to user goals
--              - Bilingual support: Plain-language English & Tamil summaries
--              - Auditable reading engagement state machine (60-second active dwell gate)
--              - Row Level Security (RLS) enforcement
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Daily Research Editions
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.daily_research_editions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    edition_date DATE NOT NULL,
    title TEXT NOT NULL DEFAULT 'Daily Scientific Intelligence',
    subtitle TEXT DEFAULT 'Evidence-based insights for your biology',
    status TEXT NOT NULL DEFAULT 'published' CHECK (
        status IN ('generating', 'published', 'archived')
    ),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_user_edition_date UNIQUE (user_id, edition_date)
);

CREATE INDEX IF NOT EXISTS idx_research_editions_user_date
    ON public.daily_research_editions (user_id, edition_date DESC);

ALTER TABLE public.daily_research_editions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own daily research editions"
    ON public.daily_research_editions FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can insert own daily research editions"
    ON public.daily_research_editions FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can update own daily research editions"
    ON public.daily_research_editions FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- ------------------------------------------------------------------------------
-- 2. Daily Research Articles (The 5 Curated Daily Articles)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.daily_research_articles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    edition_id UUID NOT NULL REFERENCES public.daily_research_editions(id) ON DELETE CASCADE,
    order_index INT NOT NULL CHECK (order_index BETWEEN 1 AND 5),
    -- English Content
    title TEXT NOT NULL,
    summary_en TEXT NOT NULL,
    scientific_takeaway TEXT NOT NULL,
    actionable_recommendation TEXT NOT NULL,
    -- Tamil Content (Multilingual Gateway)
    title_ta TEXT,
    summary_ta TEXT,
    scientific_takeaway_ta TEXT,
    actionable_recommendation_ta TEXT,
    -- Scientific Rigor & Provenance
    evidence_strength TEXT NOT NULL CHECK (
        evidence_strength IN (
            'meta_analysis',
            'systematic_review',
            'randomized_controlled_trial',
            'cohort_study',
            'mechanistic_in_vitro',
            'observational'
        )
    ),
    citation_reference TEXT NOT NULL,
    publication_doi TEXT,
    matched_goal_category TEXT NOT NULL CHECK (
        matched_goal_category IN (
            'circadian_sleep',
            'gut_microbiome',
            'metabolic_health',
            'stress_reduction',
            'cellular_longevity',
            'cognitive_performance',
            'musculoskeletal_strength'
        )
    ),
    estimated_reading_seconds INT NOT NULL DEFAULT 90,
    audio_narration_url TEXT,
    audio_duration_seconds INT DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_edition_article_order UNIQUE (edition_id, order_index)
);

CREATE INDEX IF NOT EXISTS idx_research_articles_edition
    ON public.daily_research_articles (edition_id, order_index);

ALTER TABLE public.daily_research_articles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view articles belonging to their editions"
    ON public.daily_research_articles FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.daily_research_editions e
            WHERE e.id = edition_id AND e.user_id = (SELECT auth.uid())
        )
    );

CREATE POLICY "Users can insert articles for their editions"
    ON public.daily_research_articles FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.daily_research_editions e
            WHERE e.id = edition_id AND e.user_id = (SELECT auth.uid())
        )
    );

-- ------------------------------------------------------------------------------
-- 3. Article Reading Sessions (60-Second Auditable Engagement State Machine)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.article_reading_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    article_id UUID NOT NULL REFERENCES public.daily_research_articles(id) ON DELETE CASCADE,
    session_start TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    session_end TIMESTAMPTZ,
    dwell_time_seconds INT NOT NULL DEFAULT 0,
    audio_listen_seconds INT NOT NULL DEFAULT 0,
    scroll_depth_percent NUMERIC(5,2) NOT NULL DEFAULT 0.00 CHECK (scroll_depth_percent BETWEEN 0.00 AND 100.00),
    is_verified_read BOOLEAN NOT NULL DEFAULT false,
    verified_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_user_article_reading UNIQUE (user_id, article_id)
);

CREATE INDEX IF NOT EXISTS idx_reading_sessions_user_verified
    ON public.article_reading_sessions (user_id, is_verified_read);

ALTER TABLE public.article_reading_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own reading sessions"
    ON public.article_reading_sessions FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can insert own reading sessions"
    ON public.article_reading_sessions FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can update own reading sessions"
    ON public.article_reading_sessions FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- ------------------------------------------------------------------------------
-- 4. Stored Procedure: Record Reading Telemetry & Verify Engagement
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.record_reading_telemetry(
    p_user_id UUID,
    p_article_id UUID,
    p_dwell_delta_seconds INT,
    p_audio_delta_seconds INT,
    p_scroll_depth NUMERIC
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_session_id UUID;
    v_total_dwell INT;
    v_total_audio INT;
    v_max_scroll NUMERIC;
    v_is_verified BOOLEAN;
    v_now TIMESTAMPTZ := timezone('utc'::text, now());
BEGIN
    IF auth.uid() != p_user_id THEN
        RAISE EXCEPTION 'Access denied. You can only record reading telemetry for yourself.';
    END IF;

    -- Upsert session
    INSERT INTO public.article_reading_sessions (
        user_id, article_id, dwell_time_seconds, audio_listen_seconds, scroll_depth_percent, updated_at
    )
    VALUES (
        p_user_id, p_article_id, GREATEST(0, p_dwell_delta_seconds), GREATEST(0, p_audio_delta_seconds), p_scroll_depth, v_now
    )
    ON CONFLICT (user_id, article_id)
    DO UPDATE SET
        dwell_time_seconds = public.article_reading_sessions.dwell_time_seconds + GREATEST(0, p_dwell_delta_seconds),
        audio_listen_seconds = public.article_reading_sessions.audio_listen_seconds + GREATEST(0, p_audio_delta_seconds),
        scroll_depth_percent = GREATEST(public.article_reading_sessions.scroll_depth_percent, p_scroll_depth),
        updated_at = v_now
    RETURNING id, dwell_time_seconds, audio_listen_seconds, scroll_depth_percent, is_verified_read
    INTO v_session_id, v_total_dwell, v_total_audio, v_max_scroll, v_is_verified;

    -- Engagement verification check:
    -- Verified IF active dwell >= 60 seconds OR audio listen >= 60 seconds (or complete)
    IF NOT v_is_verified AND (v_total_dwell >= 60 OR v_total_audio >= 60) THEN
        UPDATE public.article_reading_sessions
        SET is_verified_read = true,
            verified_at = v_now
        WHERE id = v_session_id;

        v_is_verified := true;
    END IF;

    RETURN jsonb_build_object(
        'session_id', v_session_id,
        'dwell_time_seconds', v_total_dwell,
        'audio_listen_seconds', v_total_audio,
        'scroll_depth_percent', v_max_scroll,
        'is_verified_read', v_is_verified,
        'remaining_seconds_for_verification', GREATEST(0, 60 - v_total_dwell)
    );
END;
$$;
