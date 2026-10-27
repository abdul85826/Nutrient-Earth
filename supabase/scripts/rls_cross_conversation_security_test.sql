-- ==============================================================================
-- Test Suite: rls_cross_conversation_security_test.sql
-- Description: Direct assertion script for psql / automated test runner
-- ==============================================================================

BEGIN;

-- Ensure test users exist in auth.users
INSERT INTO auth.users (id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
VALUES 
    ('00000000-0000-0000-0000-000000000001', 'authenticated', 'authenticated', 'user_a@nutrientearth.test', 'secret', now(), '{"provider":"email","providers":["email"]}', '{}', now(), now()),
    ('00000000-0000-0000-0000-000000000002', 'authenticated', 'authenticated', 'user_b@nutrientearth.test', 'secret', now(), '{"provider":"email","providers":["email"]}', '{}', now(), now())
ON CONFLICT (id) DO NOTHING;

-- Clean test rows
DELETE FROM public.ai_messages WHERE user_id IN ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002');
DELETE FROM public.ai_conversations WHERE user_id IN ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002');

-- Seed User B record
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "00000000-0000-0000-0000-000000000002", "role": "authenticated"}';
SET LOCAL "request.jwt.claim.sub" = '00000000-0000-0000-0000-000000000002';
SET LOCAL "request.jwt.claim.role" = 'authenticated';

INSERT INTO public.ai_conversations (id, user_id, title)
VALUES ('bbbbbbbb-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'User B Private Conversation');

INSERT INTO public.ai_messages (id, conversation_id, user_id, is_user, content)
VALUES ('bbbbbbbb-0000-0000-0000-000000000002', 'bbbbbbbb-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', true, 'User B sensitive medical query');

-- Switch to User A context
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "00000000-0000-0000-0000-000000000001", "role": "authenticated"}';
SET LOCAL "request.jwt.claim.sub" = '00000000-0000-0000-0000-000000000001';
SET LOCAL "request.jwt.claim.role" = 'authenticated';

DO $$
DECLARE
    v_count INT;
    v_user_a_conv UUID := 'aaaaaaaa-0000-0000-0000-000000000001';
    v_user_a_msg UUID := 'aaaaaaaa-0000-0000-0000-000000000002';
    v_user_b_conv UUID := 'bbbbbbbb-0000-0000-0000-000000000001';
    v_user_b_msg UUID := 'bbbbbbbb-0000-0000-0000-000000000002';
    v_caught_exception BOOLEAN;
BEGIN
    RAISE NOTICE '>>> TEST 1: User A inserts and reads own conversation and message';
    INSERT INTO public.ai_conversations (id, user_id, title)
    VALUES (v_user_a_conv, '00000000-0000-0000-0000-000000000001', 'User A Conversation');

    INSERT INTO public.ai_messages (id, conversation_id, user_id, is_user, content)
    VALUES (v_user_a_msg, v_user_a_conv, '00000000-0000-0000-0000-000000000001', true, 'User A query');

    SELECT COUNT(*) INTO v_count FROM public.ai_conversations WHERE id = v_user_a_conv;
    IF v_count <> 1 THEN
        RAISE EXCEPTION 'TEST 1 FAILED: User A cannot read own conversation';
    END IF;

    SELECT COUNT(*) INTO v_count FROM public.ai_messages WHERE id = v_user_a_msg;
    IF v_count <> 1 THEN
        RAISE EXCEPTION 'TEST 1 FAILED: User A cannot read own message';
    END IF;
    RAISE NOTICE 'TEST 1 PASSED: User A successfully created and read own records.';

    RAISE NOTICE '>>> TEST 2: User A cannot read User B conversation or messages';
    SELECT COUNT(*) INTO v_count FROM public.ai_conversations WHERE id = v_user_b_conv;
    IF v_count <> 0 THEN
        RAISE EXCEPTION 'TEST 2 FAILED: User A was able to read User B conversation! (count: %)', v_count;
    END IF;

    SELECT COUNT(*) INTO v_count FROM public.ai_messages WHERE id = v_user_b_msg;
    IF v_count <> 0 THEN
        RAISE EXCEPTION 'TEST 2 FAILED: User A was able to read User B message! (count: %)', v_count;
    END IF;
    RAISE NOTICE 'TEST 2 PASSED: User B records are completely invisible to User A.';

    RAISE NOTICE '>>> TEST 3: User A cannot insert message into User B conversation';
    v_caught_exception := false;
    BEGIN
        INSERT INTO public.ai_messages (id, conversation_id, user_id, is_user, content)
        VALUES (
            'aaaaaaaa-9999-0000-0000-000000000001',
            v_user_b_conv,
            '00000000-0000-0000-0000-000000000001',
            true,
            'Malicious message injected by User A'
        );
    EXCEPTION WHEN OTHERS THEN
        v_caught_exception := true;
        RAISE NOTICE 'Expected rejection on inserting into User B conversation: %', SQLERRM;
    END;

    IF NOT v_caught_exception THEN
        RAISE EXCEPTION 'TEST 3 FAILED: User A was able to insert message into User B conversation!';
    END IF;
    RAISE NOTICE 'TEST 3 PASSED: Cross-conversation message injection was strictly rejected.';

    RAISE NOTICE '>>> TEST 4: User A cannot update existing message to point to User B conversation';
    v_caught_exception := false;
    BEGIN
        UPDATE public.ai_messages
        SET conversation_id = v_user_b_conv
        WHERE id = v_user_a_msg;
    EXCEPTION WHEN OTHERS THEN
        v_caught_exception := true;
        RAISE NOTICE 'Expected rejection on updating conversation_id to User B conversation: %', SQLERRM;
    END;

    IF NOT v_caught_exception THEN
        SELECT conversation_id INTO v_user_b_conv FROM public.ai_messages WHERE id = v_user_a_msg;
        IF v_user_b_conv = 'bbbbbbbb-0000-0000-0000-000000000001'::uuid THEN
            RAISE EXCEPTION 'TEST 4 FAILED: User A updated message conversation_id to User B conversation!';
        END IF;
    END IF;
    RAISE NOTICE 'TEST 4 PASSED: Message re-parenting to another user conversation was strictly blocked.';

    RAISE NOTICE '>>> TEST 5: User A cannot update or delete User B messages';
    UPDATE public.ai_messages
    SET content = 'Tampered content'
    WHERE id = v_user_b_msg;

    GET DIAGNOSTICS v_count = ROW_COUNT;
    IF v_count > 0 THEN
        RAISE EXCEPTION 'TEST 5 FAILED: User A was able to update User B message!';
    END IF;

    DELETE FROM public.ai_messages
    WHERE id = v_user_b_msg;

    GET DIAGNOSTICS v_count = ROW_COUNT;
    IF v_count > 0 THEN
        RAISE EXCEPTION 'TEST 5 FAILED: User A was able to delete User B message!';
    END IF;
    RAISE NOTICE 'TEST 5 PASSED: User A cannot update or delete User B messages.';

    RAISE NOTICE '>>> TEST 6: User A legitimate update and cascade behavior works';
    UPDATE public.ai_messages
    SET content = 'Updated legitimate query'
    WHERE id = v_user_a_msg;

    GET DIAGNOSTICS v_count = ROW_COUNT;
    IF v_count <> 1 THEN
        RAISE EXCEPTION 'TEST 6 FAILED: Legitimate update on own message failed';
    END IF;
    RAISE NOTICE 'TEST 6 PASSED: Legitimate update on own message succeeded.';
END $$;

-- Anonymous user testing
SET LOCAL ROLE anon;
SET LOCAL "request.jwt.claims" = '';
SET LOCAL "request.jwt.claim.sub" = '';
SET LOCAL "request.jwt.claim.role" = 'anon';

DO $$
DECLARE
    v_count INT;
    v_caught_exception BOOLEAN;
BEGIN
    RAISE NOTICE '>>> TEST 7: Anonymous user cannot read conversations or messages';
    SELECT COUNT(*) INTO v_count FROM public.ai_conversations;
    IF v_count <> 0 THEN
        RAISE EXCEPTION 'TEST 7 FAILED: Anonymous user read conversations (count: %)', v_count;
    END IF;

    SELECT COUNT(*) INTO v_count FROM public.ai_messages;
    IF v_count <> 0 THEN
        RAISE EXCEPTION 'TEST 7 FAILED: Anonymous user read messages (count: %)', v_count;
    END IF;

    v_caught_exception := false;
    BEGIN
        INSERT INTO public.ai_conversations (user_id, title)
        VALUES ('00000000-0000-0000-0000-000000000001', 'Anon Injected Conv');
    EXCEPTION WHEN OTHERS THEN
        v_caught_exception := true;
        RAISE NOTICE 'Expected rejection on anon insert: %', SQLERRM;
    END;

    IF NOT v_caught_exception THEN
        RAISE EXCEPTION 'TEST 7 FAILED: Anonymous user was able to insert into ai_conversations!';
    END IF;
    RAISE NOTICE 'TEST 7 PASSED: Anonymous access is strictly denied.';
END $$;

ROLLBACK;
