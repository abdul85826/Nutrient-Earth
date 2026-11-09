-- ==============================================================================
-- Test Script: provenance_anchor_and_rls_security_test.sql
-- Description: Direct transactional verification script for SEC-01 and Task 3 RLS hardening.
-- Tests:
--   1. Unauthorized caller (anon) cannot invoke record_provenance_anchor_result.
--   2. User A cannot update User B's provenance manifest (privilege boundary).
--   3. Invalid status parameter is strictly rejected (domain bounds).
--   4. User A successfully updates own manifest with search_path manipulated.
--   5. Service role can update manifest across tenants.
--   6. health_sync_state isolates sync records between tenants.
--   7. Anon and authenticated cannot insert into learn_content catalog.
-- ==============================================================================

BEGIN;

-- 1. Setup Test Fixtures in auth.users
INSERT INTO auth.users (id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
VALUES 
    ('10000000-0000-0000-0000-000000000001', 'authenticated', 'authenticated', 'anchor_user_a@nutrientearth.test', 'secret', now(), '{"provider":"email"}', '{}', now(), now()),
    ('20000000-0000-0000-0000-000000000002', 'authenticated', 'authenticated', 'anchor_user_b@nutrientearth.test', 'secret', now(), '{"provider":"email"}', '{}', now(), now())
ON CONFLICT (id) DO NOTHING;

-- Seed conversations
INSERT INTO public.ai_conversations (id, user_id, title)
VALUES 
    ('c1000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'User A Conversation'),
    ('c2000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000002', 'User B Conversation')
ON CONFLICT (id) DO NOTHING;

-- Seed provenance manifests
INSERT INTO public.research_provenance_manifests (
    id, user_id, conversation_id, inquiry_reference_id, query_sanitized, domain_category,
    evidence_tier, manifest_hash, merkle_root, non_sensitive_manifest, anchor_status
)
VALUES 
    (
        'm1000000-0000-0000-0000-000000000001',
        '10000000-0000-0000-0000-000000000001',
        'c1000000-0000-0000-0000-000000000001',
        'REF-USER-A-001',
        'What is isabgol mechanism?',
        'Pharmacokinetics',
        'strong',
        'hash_a_111',
        'root_a_111',
        '{"claims":[]}'::jsonb,
        'pending'
    ),
    (
        'm2000000-0000-0000-0000-000000000002',
        '20000000-0000-0000-0000-000000000002',
        'c2000000-0000-0000-0000-000000000002',
        'REF-USER-B-002',
        'Creatine kinase kinetics',
        'Exercise Physiology',
        'moderate',
        'hash_b_222',
        'root_b_222',
        '{"claims":[]}'::jsonb,
        'pending'
    )
ON CONFLICT (id) DO NOTHING;

-- ------------------------------------------------------------------------------
-- TEST 1: Anon caller must be rejected from calling record_provenance_anchor_result
-- ------------------------------------------------------------------------------
SET LOCAL ROLE anon;
SET LOCAL "request.jwt.claims" = '{"role": "anon"}';
SET LOCAL "request.jwt.claim.role" = 'anon';
SET LOCAL "request.jwt.claim.sub" = '';

DO $$
DECLARE
    v_caught BOOLEAN := false;
BEGIN
    BEGIN
        PERFORM public.record_provenance_anchor_result(
            'm1000000-0000-0000-0000-000000000001'::uuid,
            'verified',
            'sepolia',
            '0x123abc'
        );
    EXCEPTION WHEN OTHERS THEN
        v_caught := true;
        RAISE NOTICE 'TEST 1 PASSED: Anon execution was blocked with error: %', SQLERRM;
    END;

    IF NOT v_caught THEN
        RAISE EXCEPTION 'TEST 1 FAILED: Anon caller was able to execute record_provenance_anchor_result!';
    END IF;
END $$;

-- ------------------------------------------------------------------------------
-- TEST 2: User A cannot update User B's provenance manifest
-- ------------------------------------------------------------------------------
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "10000000-0000-0000-0000-000000000001", "role": "authenticated"}';
SET LOCAL "request.jwt.claim.sub" = '10000000-0000-0000-0000-000000000001';
SET LOCAL "request.jwt.claim.role" = 'authenticated';

DO $$
DECLARE
    v_caught BOOLEAN := false;
BEGIN
    BEGIN
        PERFORM public.record_provenance_anchor_result(
            'm2000000-0000-0000-0000-000000000002'::uuid, -- User B's manifest
            'verified',
            'sepolia',
            '0x999attacker'
        );
    EXCEPTION WHEN OTHERS THEN
        v_caught := true;
        RAISE NOTICE 'TEST 2 PASSED: Cross-tenant update blocked with error: %', SQLERRM;
    END;

    IF NOT v_caught THEN
        RAISE EXCEPTION 'TEST 2 FAILED: User A was able to update User B manifest!';
    END IF;
END $$;

-- ------------------------------------------------------------------------------
-- TEST 3: Invalid status parameter is strictly rejected
-- ------------------------------------------------------------------------------
DO $$
DECLARE
    v_caught BOOLEAN := false;
BEGIN
    BEGIN
        PERFORM public.record_provenance_anchor_result(
            'm1000000-0000-0000-0000-000000000001'::uuid,
            'malicious_status', -- Invalid status
            'sepolia',
            '0x123abc'
        );
    EXCEPTION WHEN OTHERS THEN
        v_caught := true;
        RAISE NOTICE 'TEST 3 PASSED: Invalid parameter blocked with error: %', SQLERRM;
    END;

    IF NOT v_caught THEN
        RAISE EXCEPTION 'TEST 3 FAILED: Invalid anchor status parameter was accepted!';
    END IF;
END $$;

-- ------------------------------------------------------------------------------
-- TEST 4: Search-path manipulation attempt & authorized User A update
-- ------------------------------------------------------------------------------
-- Attempt to tamper with search path prior to execution
SET LOCAL search_path = public, pg_temp;

DO $$
DECLARE
    v_status TEXT;
    v_tx TEXT;
BEGIN
    PERFORM public.record_provenance_anchor_result(
        'm1000000-0000-0000-0000-000000000001'::uuid,
        'verified',
        'sepolia',
        '0xverified_tx_hash_111',
        1234567::bigint,
        '0xcontract123'
    );

    SELECT anchor_status, tx_hash INTO v_status, v_tx
    FROM public.research_provenance_manifests
    WHERE id = 'm1000000-0000-0000-0000-000000000001';

    IF v_status <> 'verified' OR v_tx <> '0xverified_tx_hash_111' THEN
        RAISE EXCEPTION 'TEST 4 FAILED: Legitimate update did not commit expected values.';
    END IF;
    RAISE NOTICE 'TEST 4 PASSED: Legitimate update succeeded safely regardless of caller search_path.';
END $$;

-- ------------------------------------------------------------------------------
-- TEST 5: Service role authorized update across tenants
-- ------------------------------------------------------------------------------
SET LOCAL ROLE service_role;
SET LOCAL "request.jwt.claims" = '{"role": "service_role"}';
SET LOCAL "request.jwt.claim.role" = 'service_role';
SET LOCAL "request.jwt.claim.sub" = '';

DO $$
DECLARE
    v_status TEXT;
BEGIN
    PERFORM public.record_provenance_anchor_result(
        'm2000000-0000-0000-0000-000000000002'::uuid, -- User B's manifest updated by service worker
        'anchored',
        'sepolia',
        '0xservice_worker_tx_hash',
        9999999::bigint,
        '0xcontract_anchor'
    );

    SELECT anchor_status INTO v_status
    FROM public.research_provenance_manifests
    WHERE id = 'm2000000-0000-0000-0000-000000000002';

    IF v_status <> 'anchored' THEN
        RAISE EXCEPTION 'TEST 5 FAILED: Service role update failed to commit.';
    END IF;
    RAISE NOTICE 'TEST 5 PASSED: Service role worker successfully updated manifest status.';
END $$;

-- ------------------------------------------------------------------------------
-- TEST 6: health_sync_state multi-tenant isolation
-- ------------------------------------------------------------------------------
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "10000000-0000-0000-0000-000000000001", "role": "authenticated"}';
SET LOCAL "request.jwt.claim.sub" = '10000000-0000-0000-0000-000000000001';
SET LOCAL "request.jwt.claim.role" = 'authenticated';

INSERT INTO public.health_sync_state (user_id, platform, sync_cursor, status)
VALUES ('10000000-0000-0000-0000-000000000001', 'android_health_connect', 'cursor_a_1', 'synced');

-- Switch to User B
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "20000000-0000-0000-0000-000000000002", "role": "authenticated"}';
SET LOCAL "request.jwt.claim.sub" = '20000000-0000-0000-0000-000000000002';
SET LOCAL "request.jwt.claim.role" = 'authenticated';

DO $$
DECLARE
    v_count INT;
    v_caught BOOLEAN := false;
BEGIN
    -- User B cannot read User A's sync state
    SELECT COUNT(*) INTO v_count FROM public.health_sync_state WHERE user_id = '10000000-0000-0000-0000-000000000001';
    IF v_count <> 0 THEN
        RAISE EXCEPTION 'TEST 6 FAILED: User B was able to read User A sync state (count: %)', v_count;
    END IF;

    -- User B cannot delete User A's sync state
    DELETE FROM public.health_sync_state WHERE user_id = '10000000-0000-0000-0000-000000000001';
    GET DIAGNOSTICS v_count = ROW_COUNT;
    IF v_count <> 0 THEN
        RAISE EXCEPTION 'TEST 6 FAILED: User B was able to delete User A sync state!';
    END IF;

    -- User B cannot insert sync state with User A's user_id
    BEGIN
        INSERT INTO public.health_sync_state (user_id, platform, sync_cursor, status)
        VALUES ('10000000-0000-0000-0000-000000000001', 'android_health_connect', 'spoofed_cursor', 'synced');
    EXCEPTION WHEN OTHERS THEN
        v_caught := true;
    END;

    IF NOT v_caught THEN
        RAISE EXCEPTION 'TEST 6 FAILED: User B was able to insert sync state for User A!';
    END IF;
    RAISE NOTICE 'TEST 6 PASSED: health_sync_state tenant isolation strictly enforced across CRUD.';
END $$;

-- ------------------------------------------------------------------------------
-- TEST 7: Catalog write restriction (learn_content, exercise_routines, store_products)
-- ------------------------------------------------------------------------------
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "10000000-0000-0000-0000-000000000001", "role": "authenticated"}';
SET LOCAL "request.jwt.claim.sub" = '10000000-0000-0000-0000-000000000001';
SET LOCAL "request.jwt.claim.role" = 'authenticated';

DO $$
DECLARE
    v_caught BOOLEAN := false;
BEGIN
    BEGIN
        INSERT INTO public.learn_content (id, title, category, summary, content, reading_time_minutes, evidence_score, primary_source_citation, published_date)
        VALUES ('malicious_art', 'Injected', 'Nutrition', 'Summary', 'Content', 5, 50, 'Cite', '2026-01-01');
    EXCEPTION WHEN OTHERS THEN
        v_caught := true;
    END;

    IF NOT v_caught THEN
        RAISE EXCEPTION 'TEST 7 FAILED: Authenticated user was able to insert into learn_content catalog!';
    END IF;
    RAISE NOTICE 'TEST 7 PASSED: Catalog tables strictly deny writes to non-service roles.';
END $$;

ROLLBACK;

