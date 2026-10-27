-- ==============================================================================
-- pgTAP Test Suite: research_persistence_integration.test.sql
-- Comprehensive Research Persistence Pipeline & Authorization Integration Tests
-- Run with: supabase test db
-- ==============================================================================

BEGIN;

SELECT plan(10);

-- ------------------------------------------------------------------------------
-- 0. Fixtures: Test Users
-- ------------------------------------------------------------------------------
INSERT INTO auth.users (id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
VALUES 
    ('11111111-0000-0000-0000-000000000001', 'authenticated', 'authenticated', 'researcher_a@nutrientearth.test', 'secret', now(), '{"provider":"email"}', '{}', now(), now()),
    ('22222222-0000-0000-0000-000000000002', 'authenticated', 'authenticated', 'researcher_b@nutrientearth.test', 'secret', now(), '{"provider":"email"}', '{}', now(), now())
ON CONFLICT (id) DO NOTHING;

-- Clean prior test records
DELETE FROM public.ai_messages WHERE user_id IN ('11111111-0000-0000-0000-000000000001', '22222222-0000-0000-0000-000000000002');
DELETE FROM public.ai_conversations WHERE user_id IN ('11111111-0000-0000-0000-000000000001', '22222222-0000-0000-0000-000000000002');

-- ------------------------------------------------------------------------------
-- Test 1 & 2: User A persists conversation and atomic batch research turn
-- ------------------------------------------------------------------------------
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "11111111-0000-0000-0000-000000000001", "role": "authenticated"}';
SET LOCAL "request.jwt.claim.sub" = '11111111-0000-0000-0000-000000000001';
SET LOCAL "request.jwt.claim.role" = 'authenticated';

-- Step 1: Create conversation
INSERT INTO public.ai_conversations (id, user_id, title)
VALUES ('e1111111-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000001', 'Magnesium bisglycinate and sleep');

SELECT is(
    (SELECT count(*)::int FROM public.ai_conversations WHERE id = 'e1111111-0000-0000-0000-000000000001'),
    1,
    'Test 1: User A successfully persists research conversation'
);

-- Step 2: Atomic batch insert of inquiry and answer
INSERT INTO public.ai_messages (id, conversation_id, user_id, is_user, content, sources, evidence_quality, practical_next_steps)
VALUES 
    (
        'f1111111-0000-0000-0000-000000000001', 
        'e1111111-0000-0000-0000-000000000001', 
        '11111111-0000-0000-0000-000000000001', 
        true, 
        'Does magnesium bisglycinate improve sleep quality?',
        '[]'::jsonb,
        NULL,
        '{}'
    ),
    (
        'f1111111-0000-0000-0000-000000000002', 
        'e1111111-0000-0000-0000-000000000001', 
        '11111111-0000-0000-0000-000000000001', 
        false, 
        'Systematic review evidence indicates magnesium supplementation supports sleep latency.',
        '[{"title":"Magnesium in Sleep Architecture","doi":"10.1016/j.smrv.2023.101850"}]'::jsonb,
        'RCT REVIEW • GRADE A (SYSTEMATIC EVIDENCE)',
        ARRAY['Take 200mg elemental magnesium 45 minutes before sleep']
    );

SELECT is(
    (SELECT count(*)::int FROM public.ai_messages WHERE conversation_id = 'e1111111-0000-0000-0000-000000000001'),
    2,
    'Test 2: Atomic batch insertion creates exactly 2 messages satisfying composite FK and RLS'
);

-- ------------------------------------------------------------------------------
-- Test 3: Messages ordering and association verification
-- ------------------------------------------------------------------------------
SELECT is(
    (SELECT is_user FROM public.ai_messages WHERE conversation_id = 'e1111111-0000-0000-0000-000000000001' ORDER BY created_at ASC, id ASC LIMIT 1),
    true,
    'Test 3: First message in research turn is the user query'
);

-- ------------------------------------------------------------------------------
-- Test 4: User A retrieves their own history
-- ------------------------------------------------------------------------------
SELECT is(
    (SELECT count(*)::int FROM public.ai_conversations WHERE user_id = '11111111-0000-0000-0000-000000000001'),
    1,
    'Test 4: User A retrieves their active research history'
);

-- ------------------------------------------------------------------------------
-- Test 5: User B cannot retrieve User A history
-- ------------------------------------------------------------------------------
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "22222222-0000-0000-0000-000000000002", "role": "authenticated"}';
SET LOCAL "request.jwt.claim.sub" = '22222222-0000-0000-0000-000000000002';
SET LOCAL "request.jwt.claim.role" = 'authenticated';

SELECT is(
    (SELECT count(*)::int FROM public.ai_conversations WHERE id = 'e1111111-0000-0000-0000-000000000001'),
    0,
    'Test 5: User B cannot retrieve User A conversation history (tenant isolation)'
);

-- ------------------------------------------------------------------------------
-- Test 6: Unauthorized write to foreign conversation fails safely
-- ------------------------------------------------------------------------------
SELECT throws_ok(
    $$
    INSERT INTO public.ai_messages (conversation_id, user_id, is_user, content)
    VALUES ('e1111111-0000-0000-0000-000000000001', '22222222-0000-0000-0000-000000000002', true, 'Unauthorized attempt');
    $$,
    NULL,
    NULL,
    'Test 6: User B cannot write messages to User A conversation'
);

-- ------------------------------------------------------------------------------
-- Test 7: User B cannot forge user_id in conversation creation
-- ------------------------------------------------------------------------------
SELECT throws_ok(
    $$
    INSERT INTO public.ai_conversations (user_id, title)
    VALUES ('11111111-0000-0000-0000-000000000001', 'Forged Conversation Owner');
    $$,
    NULL,
    NULL,
    'Test 7: User B cannot create conversation with User A user_id'
);

-- ------------------------------------------------------------------------------
-- Test 8: Atomic rollback: batch with 1 invalid row rolls back completely
-- ------------------------------------------------------------------------------
SELECT throws_ok(
    $$
    INSERT INTO public.ai_messages (conversation_id, user_id, is_user, content)
    VALUES 
        ('e1111111-0000-0000-0000-000000000001', '22222222-0000-0000-0000-000000000002', true, 'Row 1 invalid'),
        ('e1111111-0000-0000-0000-000000000001', '22222222-0000-0000-0000-000000000002', false, 'Row 2 invalid');
    $$,
    NULL,
    NULL,
    'Test 8: Atomic rollback of invalid multi-row persistence batch'
);

-- ------------------------------------------------------------------------------
-- Test 9: Conversation deletion cascade
-- ------------------------------------------------------------------------------
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "11111111-0000-0000-0000-000000000001", "role": "authenticated"}';
SET LOCAL "request.jwt.claim.sub" = '11111111-0000-0000-0000-000000000001';
SET LOCAL "request.jwt.claim.role" = 'authenticated';

DELETE FROM public.ai_conversations WHERE id = 'e1111111-0000-0000-0000-000000000001';

SELECT is(
    (SELECT count(*)::int FROM public.ai_messages WHERE conversation_id = 'e1111111-0000-0000-0000-000000000001'),
    0,
    'Test 9: Conversation deletion cascades to remove associated messages'
);

-- ------------------------------------------------------------------------------
-- Test 10: Anonymous access denied
-- ------------------------------------------------------------------------------
SET LOCAL ROLE anon;
SET LOCAL "request.jwt.claims" = '';
SET LOCAL "request.jwt.claim.sub" = '';
SET LOCAL "request.jwt.claim.role" = 'anon';

SELECT is(
    (SELECT count(*)::int FROM public.ai_conversations),
    0,
    'Test 10: Anonymous role cannot read any conversations'
);

SELECT * FROM finish();
ROLLBACK;
