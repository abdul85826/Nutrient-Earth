-- ==============================================================================
-- Migration: 20261027185525_cross_conversation_authorization_hardening.sql
-- Description: Enforces multi-tenant cross-conversation authorization and relational
--              integrity on public.ai_conversations and public.ai_messages.
--
-- Defense-in-Depth Layer 1 (Relational Integrity):
--   1. Ensures public.ai_conversations has a UNIQUE (id, user_id) constraint.
--   2. Adds composite foreign key on public.ai_messages (conversation_id, user_id)
--      referencing public.ai_conversations (id, user_id) ON DELETE CASCADE.
--      This guarantees at the storage engine level that a message cannot exist
--      in a conversation owned by a different user.
--   3. Adds performance indexes on foreign key lookups and tenant queries.
--
-- Defense-in-Depth Layer 2 (Granular RLS Policies):
--   1. Restructures public.ai_conversations RLS into separated SELECT, INSERT,
--      UPDATE (with explicit WITH CHECK), and DELETE policies bound TO authenticated.
--   2. Restructures public.ai_messages RLS into separated SELECT, INSERT,
--      UPDATE (with explicit WITH CHECK), and DELETE policies enforcing that:
--        a) The authenticated user is the message owner ((select auth.uid()) = user_id).
--        b) The referenced conversation belongs to the same user (EXISTS subquery).
--        c) Updates cannot reassign ownership or relocate messages to another user's conversation.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Relational Integrity: Unique Constraint & Composite Foreign Key
-- ------------------------------------------------------------------------------

-- Ensure public.ai_conversations has a unique constraint on (id, user_id)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'ai_conversations_id_user_id_key'
          AND conrelid = 'public.ai_conversations'::regclass
    ) THEN
        ALTER TABLE public.ai_conversations
            ADD CONSTRAINT ai_conversations_id_user_id_key UNIQUE (id, user_id);
    END IF;
END $$;

-- Enforce composite foreign key on public.ai_messages linking (conversation_id, user_id)
-- to public.ai_conversations(id, user_id)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_ai_messages_conversation_user'
          AND conrelid = 'public.ai_messages'::regclass
    ) THEN
        ALTER TABLE public.ai_messages
            ADD CONSTRAINT fk_ai_messages_conversation_user
            FOREIGN KEY (conversation_id, user_id)
            REFERENCES public.ai_conversations(id, user_id)
            ON DELETE CASCADE;
    END IF;
END $$;

-- ------------------------------------------------------------------------------
-- 2. Performance Indexes for RLS and Foreign Key Lookups
-- ------------------------------------------------------------------------------

CREATE INDEX IF NOT EXISTS ai_conversations_user_id_idx
    ON public.ai_conversations (user_id);

CREATE INDEX IF NOT EXISTS ai_messages_conversation_user_idx
    ON public.ai_messages (conversation_id, user_id);

CREATE INDEX IF NOT EXISTS ai_messages_user_id_idx
    ON public.ai_messages (user_id);

-- ------------------------------------------------------------------------------
-- 3. Hardened RLS Policies: public.ai_conversations
-- ------------------------------------------------------------------------------

-- Drop legacy catch-all policy if present
DROP POLICY IF EXISTS "Users can access own conversations" ON public.ai_conversations;
DROP POLICY IF EXISTS "Users can view own conversations" ON public.ai_conversations;
DROP POLICY IF EXISTS "Users can insert own conversations" ON public.ai_conversations;
DROP POLICY IF EXISTS "Users can update own conversations" ON public.ai_conversations;
DROP POLICY IF EXISTS "Users can delete own conversations" ON public.ai_conversations;

-- Ensure RLS is enabled
ALTER TABLE public.ai_conversations ENABLE ROW LEVEL SECURITY;

-- SELECT: Authenticated users can only read their own conversations
CREATE POLICY "Users can view own conversations"
    ON public.ai_conversations FOR SELECT
    TO authenticated
    USING ((select auth.uid()) = user_id);

-- INSERT: Authenticated users can only insert conversations owned by themselves
CREATE POLICY "Users can insert own conversations"
    ON public.ai_conversations FOR INSERT
    TO authenticated
    WITH CHECK ((select auth.uid()) = user_id);

-- UPDATE: Authenticated users can only update their own conversations and cannot transfer ownership
CREATE POLICY "Users can update own conversations"
    ON public.ai_conversations FOR UPDATE
    TO authenticated
    USING ((select auth.uid()) = user_id)
    WITH CHECK ((select auth.uid()) = user_id);

-- DELETE: Authenticated users can only delete their own conversations
CREATE POLICY "Users can delete own conversations"
    ON public.ai_conversations FOR DELETE
    TO authenticated
    USING ((select auth.uid()) = user_id);

-- ------------------------------------------------------------------------------
-- 4. Hardened RLS Policies: public.ai_messages
-- ------------------------------------------------------------------------------

-- Drop legacy catch-all policy if present
DROP POLICY IF EXISTS "Users can access own conversation messages" ON public.ai_messages;
DROP POLICY IF EXISTS "Users can view own conversation messages" ON public.ai_messages;
DROP POLICY IF EXISTS "Users can insert own conversation messages" ON public.ai_messages;
DROP POLICY IF EXISTS "Users can update own conversation messages" ON public.ai_messages;
DROP POLICY IF EXISTS "Users can delete own conversation messages" ON public.ai_messages;

-- Ensure RLS is enabled
ALTER TABLE public.ai_messages ENABLE ROW LEVEL SECURITY;

-- SELECT: Authenticated users can only view messages they own within conversations they own
CREATE POLICY "Users can view own conversation messages"
    ON public.ai_messages FOR SELECT
    TO authenticated
    USING (
        (select auth.uid()) = user_id
        AND EXISTS (
            SELECT 1 FROM public.ai_conversations c
            WHERE c.id = ai_messages.conversation_id
              AND c.user_id = (select auth.uid())
        )
    );

-- INSERT: Authenticated users can only insert messages into their own conversations with their own user_id
CREATE POLICY "Users can insert own conversation messages"
    ON public.ai_messages FOR INSERT
    TO authenticated
    WITH CHECK (
        (select auth.uid()) = user_id
        AND EXISTS (
            SELECT 1 FROM public.ai_conversations c
            WHERE c.id = ai_messages.conversation_id
              AND c.user_id = (select auth.uid())
        )
    );

-- UPDATE: Authenticated users can only update their own messages; cannot mutate user_id or conversation_id
-- to another user's identity or conversation
CREATE POLICY "Users can update own conversation messages"
    ON public.ai_messages FOR UPDATE
    TO authenticated
    USING (
        (select auth.uid()) = user_id
        AND EXISTS (
            SELECT 1 FROM public.ai_conversations c
            WHERE c.id = ai_messages.conversation_id
              AND c.user_id = (select auth.uid())
        )
    )
    WITH CHECK (
        (select auth.uid()) = user_id
        AND EXISTS (
            SELECT 1 FROM public.ai_conversations c
            WHERE c.id = ai_messages.conversation_id
              AND c.user_id = (select auth.uid())
        )
    );

-- DELETE: Authenticated users can only delete their own messages within their own conversations
CREATE POLICY "Users can delete own conversation messages"
    ON public.ai_messages FOR DELETE
    TO authenticated
    USING (
        (select auth.uid()) = user_id
        AND EXISTS (
            SELECT 1 FROM public.ai_conversations c
            WHERE c.id = ai_messages.conversation_id
              AND c.user_id = (select auth.uid())
        )
    );
