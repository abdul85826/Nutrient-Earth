-- ==============================================================================
-- Migration: 20261106000200_harden_provenance_anchor_and_rls.sql
-- Description: Forward-only security remediation for Nutrient Earth backend:
--   1. SEC-01: Hardens SECURITY DEFINER function record_provenance_anchor_result
--      with empty search_path, explicit schema qualifications, parameter validation,
--      strict role gating, and revoked public execution grants.
--   2. RLS Hardening (Task 3): Restructures public.health_sync_state into granular
--      SELECT, INSERT, UPDATE, and DELETE policies bound TO authenticated with
--      subselect caching.
--   3. Public Catalog Hardening (Task 3): Enforces FORCE ROW LEVEL SECURITY and
--      explicitly revokes write permissions (INSERT/UPDATE/DELETE/TRUNCATE) on
--      system-owned tables (learn_content, exercise_routines, store_products)
--      from anon and authenticated roles.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. SEC-01 Hardening: record_provenance_anchor_result
-- ------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.record_provenance_anchor_result(
    p_manifest_id pg_catalog.uuid,
    p_anchor_status pg_catalog.text,
    p_chain_id pg_catalog.text,
    p_tx_hash pg_catalog.text,
    p_block_number pg_catalog.int8 DEFAULT NULL,
    p_contract_address pg_catalog.text DEFAULT NULL
)
RETURNS pg_catalog.void AS $$
BEGIN
    -- Step 1: Parameter Domain Validation
    IF p_anchor_status NOT IN ('pending', 'submitted', 'anchored', 'verified', 'failed') THEN
        RAISE EXCEPTION 'Invalid anchor status: %. Permitted statuses: pending, submitted, anchored, verified, failed.', p_anchor_status
            USING ERRCODE = 'check_violation';
    END IF;

    -- Step 2: Role Authorization Gate
    -- Strictly reject unauthenticated callers or arbitrary roles
    IF auth.role() IS NULL OR (auth.role() <> 'authenticated' AND auth.role() <> 'service_role') THEN
        RAISE EXCEPTION 'Unauthorized: Caller must have authenticated or service_role privilege context.'
            USING ERRCODE = 'insufficient_privilege';
    END IF;

    -- Step 3: Schema-Qualified Mutation with Zero Reliance on search_path
    UPDATE public.research_provenance_manifests
    SET anchor_status = p_anchor_status,
        chain_id = p_chain_id,
        tx_hash = p_tx_hash,
        block_number = p_block_number,
        contract_or_anchor_address = pg_catalog.coalesce(p_contract_address, contract_or_anchor_address),
        anchored_at = pg_catalog.now(),
        updated_at = pg_catalog.now()
    WHERE id = p_manifest_id
      AND (
          (auth.role() = 'authenticated' AND user_id = (SELECT auth.uid()))
          OR auth.role() = 'service_role'
      );

    -- Step 4: Fail Closed if Manifest Not Found or Not Owned by Caller
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Manifest not found or unauthorized: ID % cannot be modified by current role context.', p_manifest_id
            USING ERRCODE = 'data_exception';
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';

-- Revoke dangerous default execution permissions from PUBLIC and anon
REVOKE EXECUTE ON FUNCTION public.record_provenance_anchor_result(pg_catalog.uuid, pg_catalog.text, pg_catalog.text, pg_catalog.text, pg_catalog.int8, pg_catalog.text) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.record_provenance_anchor_result(pg_catalog.uuid, pg_catalog.text, pg_catalog.text, pg_catalog.text, pg_catalog.int8, pg_catalog.text) FROM anon;

-- Explicitly grant execution only to authenticated callers and service_role
GRANT EXECUTE ON FUNCTION public.record_provenance_anchor_result(pg_catalog.uuid, pg_catalog.text, pg_catalog.text, pg_catalog.text, pg_catalog.int8, pg_catalog.text) TO authenticated, service_role;

COMMENT ON FUNCTION public.record_provenance_anchor_result IS 'Hardened SECURITY DEFINER anchor update function with empty search_path, explicit schema qualifiers, parameter checks, and role isolation.';

-- ------------------------------------------------------------------------------
-- 2. Task 3 RLS Hardening: public.health_sync_state
-- ------------------------------------------------------------------------------

-- Drop unseparated FOR ALL policy
DROP POLICY IF EXISTS "Users manage own health sync state" ON public.health_sync_state;
DROP POLICY IF EXISTS "Users can view own health sync state" ON public.health_sync_state;
DROP POLICY IF EXISTS "Users can insert own health sync state" ON public.health_sync_state;
DROP POLICY IF EXISTS "Users can update own health sync state" ON public.health_sync_state;
DROP POLICY IF EXISTS "Users can delete own health sync state" ON public.health_sync_state;

-- Granular SELECT policy bound TO authenticated with cached subselect
CREATE POLICY "Users can view own health sync state"
    ON public.health_sync_state FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

-- Granular INSERT policy bound TO authenticated
CREATE POLICY "Users can insert own health sync state"
    ON public.health_sync_state FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- Granular UPDATE policy bound TO authenticated
CREATE POLICY "Users can update own health sync state"
    ON public.health_sync_state FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- Granular DELETE policy bound TO authenticated
CREATE POLICY "Users can delete own health sync state"
    ON public.health_sync_state FOR DELETE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

-- Force RLS on health_sync_state and research_provenance_manifests
ALTER TABLE public.health_sync_state FORCE ROW LEVEL SECURITY;
ALTER TABLE public.research_provenance_manifests FORCE ROW LEVEL SECURITY;

-- ------------------------------------------------------------------------------
-- 3. Task 3 Catalog Hardening: learn_content, exercise_routines, store_products
-- ------------------------------------------------------------------------------

-- Enforce FORCE ROW LEVEL SECURITY on system catalog tables
ALTER TABLE public.learn_content FORCE ROW LEVEL SECURITY;
ALTER TABLE public.exercise_routines FORCE ROW LEVEL SECURITY;
ALTER TABLE public.store_products FORCE ROW LEVEL SECURITY;

-- Explicitly revoke write grants from anon and authenticated roles
REVOKE INSERT, UPDATE, DELETE, TRUNCATE ON public.learn_content FROM anon, authenticated;
REVOKE INSERT, UPDATE, DELETE, TRUNCATE ON public.exercise_routines FROM anon, authenticated;
REVOKE INSERT, UPDATE, DELETE, TRUNCATE ON public.store_products FROM anon, authenticated;

