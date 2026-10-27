-- ==============================================================================
-- pgTAP Test Suite: cross_conversation_authorization.test.sql
-- Comprehensive Tenant Isolation and RLS Verification
-- Run with: supabase test db
-- ==============================================================================

BEGIN;

SELECT plan(12);

-- ------------------------------------------------------------------------------
-- 0. Fixture Setup: Authenticated User A and User B
-- ------------------------------------------------------------------------------

INSERT INTO auth.users (id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
VALUES 
    ('00000000-0000-0000-0000-000000000001', 'authenticated', 'authenticated', 'user_a@nutrientearth.test', 'secret', now(), '{"provider":"email","providers":["email"]}', '{}', now(), now()),
    ('00000000-0000-0000-0000-000000000002', 'authenticated', 'authenticated', 'user_b@nutrientearth.test', 'secret', now(), '{"provider":"email","providers":["email"]}', '{}', now(), now())
ON CONFLICT (id) DO NOTHING;

-- Clean any previous test rows
DELETE FROM public.ai_messages WHERE user_id IN ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002');
DELETE FROM public.ai_conversations WHERE user_id IN ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002');

-- ------------------------------------------------------------------------------
-- Verification 1 & 2: User A can create and read their own records
-- ------------------------------------------------------------------------------
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "00000000-0000-0000-0000-000000000001", "role": "authenticated"}';
SET LOCAL "request.jwt.claim.sub" = '00000000-0000-0000-0000-000000000001';
SET LOCAL "request.jwt.claim.role" = 'authenticated';

INSERT INTO public.ai_conversations (id, user_id, title)
VALUES ('aaaaaaaa-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'User A Conversation');

INSERT INTO public.ai_messages (id, conversation_id, user_id, is_user, content)
VALUES ('aaaaaaaa-0000-0000-0000-000000000002', 'aaaaaaaa-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', true, 'User A query');

SELECT is(
    (SELECT count(*)::int FROM public.ai_conversations WHERE id = 'aaaaaaaa-0000-0000-0000-000000000001'),
    1,
    'Verification 1: User A can read own conversation'
);

SELECT is(
    (SELECT count(*)::int FROM public.ai_messages WHERE id = 'aaaaaaaa-0000-0000-0000-000000000002'),
    1,
    'Verification 2: User A can read own message'
);

-- ------------------------------------------------------------------------------
-- Verification 3: User B can create and read their own conversation
-- ------------------------------------------------------------------------------
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "00000000-0000-0000-0000-000000000002", "role": "authenticated"}';
SET LOCAL "request.jwt.claim.sub" = '00000000-0000-0000-0000-000000000002';
SET LOCAL "request.jwt.claim.role" = 'authenticated';

INSERT INTO public.ai_conversations (id, user_id, title)
VALUES ('bbbbbbbb-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'User B Private Conversation');

INSERT INTO public.ai_messages (id, conversation_id, user_id, is_user, content)
VALUES ('bbbbbbbb-0000-0000-0000-000000000002', 'bbbbbbbb-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', true, 'User B sensitive medical query');

SELECT is(
    (SELECT count(*)::int FROM public.ai_conversations WHERE id = 'bbbbbbbb-0000-0000-0000-000000000001'),
    1,
    'Verification 3: User B can read own conversation'
);

-- ------------------------------------------------------------------------------
-- Verification 4 & 5: User A cannot read User B's conversation or messages
-- ------------------------------------------------------------------------------
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "00000000-0000-0000-0000-000000000001", "role": "authenticated"}';
SET LOCAL "request.jwt.claim.sub" = '00000000-0000-0000-0000-000000000001';
SET LOCAL "request.jwt.claim.role" = 'authenticated';

SELECT is(
    (SELECT count(*)::int FROM public.ai_conversations WHERE id = 'bbbbbbbb-0000-0000-0000-000000000001'),
    0,
    'Verification 4: User A cannot read User B conversation (tenant isolation)'
);

SELECT is(
    (SELECT count(*)::int FROM public.ai_messages WHERE id = 'bbbbbbbb-0000-0000-0000-000000000002'),
    0,
    'Verification 5: User A cannot read User B message (tenant isolation)'
);

-- ------------------------------------------------------------------------------
-- Verification 6: User A cannot insert a message into User B's conversation
-- ------------------------------------------------------------------------------
SELECT throws_ok(
    $$
    INSERT INTO public.ai_messages (id, conversation_id, user_id, is_user, content)
    VALUES ('aaaaaaaa-9999-0000-0000-000000000001', 'bbbbbbbb-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', true, 'Malicious injection');
    $$,
    NULL,
    NULL,
    'Verification 6: User A cannot insert message into User B conversation'
);

-- ------------------------------------------------------------------------------
-- Verification 7: User A cannot move an existing message into User B's conversation
-- ------------------------------------------------------------------------------
SELECT throws_ok(
    $$
    UPDATE public.ai_messages
    SET conversation_id = 'bbbbbbbb-0000-0000-0000-000000000001'
    WHERE id = 'aaaaaaaa-0000-0000-0000-000000000002';
    $$,
    NULL,
    NULL,
    'Verification 7: User A cannot move message into User B conversation'
);

-- ------------------------------------------------------------------------------
-- Verification 8: User A cannot change ownership of their message
-- ------------------------------------------------------------------------------
SELECT throws_ok(
    $$
    UPDATE public.ai_messages
    SET user_id = '00000000-0000-0000-0000-000000000002'
    WHERE id = 'aaaaaaaa-0000-0000-0000-000000000002';
    $$,
    NULL,
    NULL,
    'Verification 8: User A cannot transfer message ownership to User B'
);

-- ------------------------------------------------------------------------------
-- Verification 9: User A cannot update or delete User B's records
-- ------------------------------------------------------------------------------
UPDATE public.ai_messages SET content = 'tampered' WHERE id = 'bbbbbbbb-0000-0000-0000-000000000002';
DELETE FROM public.ai_messages WHERE id = 'bbbbbbbb-0000-0000-0000-000000000002';

SET LOCAL ROLE postgres;
SELECT is(
    (SELECT content FROM public.ai_messages WHERE id = 'bbbbbbbb-0000-0000-0000-000000000002'),
    'User B sensitive medical query',
    'Verification 9: User B message remained completely unmodified and undeleted by User A'
);

-- ------------------------------------------------------------------------------
-- Verification 10 & 11: Anonymous users cannot access or insert protected records
-- ------------------------------------------------------------------------------
SET LOCAL ROLE anon;
SET LOCAL "request.jwt.claims" = '';
SET LOCAL "request.jwt.claim.sub" = '';
SET LOCAL "request.jwt.claim.role" = 'anon';

SELECT is(
    (SELECT count(*)::int FROM public.ai_conversations),
    0,
    'Verification 10: Anonymous user cannot read any conversations'
);

SELECT throws_ok(
    $$
    INSERT INTO public.ai_conversations (user_id, title)
    VALUES ('00000000-0000-0000-0000-000000000001', 'Anonymous Conversation Injection');
    $$,
    NULL,
    NULL,
    'Verification 11: Anonymous user cannot insert conversations'
);

-- ------------------------------------------------------------------------------
-- Verification 12: Composite FK rejects mismatched ownership even when RLS bypassed
-- ------------------------------------------------------------------------------
SET LOCAL ROLE postgres;
SELECT throws_matching(
    $$
    INSERT INTO public.ai_messages (conversation_id, user_id, is_user, content)
    VALUES ('bbbbbbbb-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', true, 'bypassed rls attempt');
    $$,
    'fk_ai_messages_conversation_user',
    'Verification 12: Composite foreign key rejects mismatched ownership even when RLS bypassed by superuser'
);

SELECT * FROM finish();
ROLLBACK;
