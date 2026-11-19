-- ==============================================================================
-- Migration: 20261117000004_intelligence_workspace_foundation.sql
-- Description: Intelligence Workspace Foundation:
--   1. Workspace Research Projects (workspace_projects)
--   2. Saved Intelligence Items (workspace_saved_items)
--   3. Conversation Enhancements (project grouping, pinning, archiving)
--   4. Universal Full-Text Search Indexes (conversations, messages, projects, saved)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Workspace Research Projects
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.workspace_projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    color_hex TEXT DEFAULT '#00251D',
    is_archived BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_workspace_projects_user
    ON public.workspace_projects (user_id, is_archived, updated_at DESC);

ALTER TABLE public.workspace_projects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own workspace projects"
    ON public.workspace_projects FOR ALL
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- ------------------------------------------------------------------------------
-- 2. Extend ai_conversations with workspace attributes
-- ------------------------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'ai_conversations' AND column_name = 'project_id'
    ) THEN
        ALTER TABLE public.ai_conversations
            ADD COLUMN project_id UUID REFERENCES public.workspace_projects(id) ON DELETE SET NULL;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'ai_conversations' AND column_name = 'is_pinned'
    ) THEN
        ALTER TABLE public.ai_conversations
            ADD COLUMN is_pinned BOOLEAN NOT NULL DEFAULT false;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'ai_conversations' AND column_name = 'is_archived'
    ) THEN
        ALTER TABLE public.ai_conversations
            ADD COLUMN is_archived BOOLEAN NOT NULL DEFAULT false;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'ai_conversations' AND column_name = 'updated_at'
    ) THEN
        ALTER TABLE public.ai_conversations
            ADD COLUMN updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now());
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_ai_conversations_user_pinned
    ON public.ai_conversations (user_id, is_pinned DESC, updated_at DESC);

CREATE INDEX IF NOT EXISTS idx_ai_conversations_project
    ON public.ai_conversations (project_id)
    WHERE project_id IS NOT NULL;

-- ------------------------------------------------------------------------------
-- 3. Workspace Saved Intelligence Items
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.workspace_saved_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    project_id UUID REFERENCES public.workspace_projects(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    item_type TEXT NOT NULL CHECK (
        item_type IN ('answer', 'research_paper', 'product_analysis', 'plan', 'calculation', 'report')
    ),
    content_snippet TEXT NOT NULL,
    payload JSONB NOT NULL DEFAULT '{}'::jsonb,
    source_reference TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_workspace_saved_items_user
    ON public.workspace_saved_items (user_id, item_type, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_workspace_saved_items_project
    ON public.workspace_saved_items (project_id)
    WHERE project_id IS NOT NULL;

ALTER TABLE public.workspace_saved_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own saved items"
    ON public.workspace_saved_items FOR ALL
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- ------------------------------------------------------------------------------
-- 4. Universal Full-Text Search Indexes
-- ------------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_fts_ai_conversations_title
    ON public.ai_conversations USING GIN (to_tsvector('english', title));

CREATE INDEX IF NOT EXISTS idx_fts_ai_messages_content
    ON public.ai_messages USING GIN (to_tsvector('english', content));

CREATE INDEX IF NOT EXISTS idx_fts_workspace_projects_name
    ON public.workspace_projects USING GIN (to_tsvector('english', name || ' ' || COALESCE(description, '')));

CREATE INDEX IF NOT EXISTS idx_fts_workspace_saved_title
    ON public.workspace_saved_items USING GIN (to_tsvector('english', title || ' ' || content_snippet));
