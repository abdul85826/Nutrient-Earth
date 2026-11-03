-- ==============================================================================
-- Migration: 20261103000001_research_provenance_blockchain_manifests.sql
-- Description: Creates the chain-independent Evidence Integrity & Provenance
--              manifest storage for Nutrient Earth Explore/Research platform.
--              Stores canonical research manifests, SHA-256 hashes, Merkle roots,
--              and blockchain anchoring transaction metadata with strict multi-tenant RLS.
-- ==============================================================================

-- 1. Create research_provenance_manifests table
CREATE TABLE IF NOT EXISTS public.research_provenance_manifests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    conversation_id UUID,
    message_id UUID,
    inquiry_reference_id TEXT NOT NULL,
    query_sanitized TEXT NOT NULL,
    domain_category TEXT NOT NULL,
    evidence_tier TEXT NOT NULL CHECK (
        evidence_tier IN ('strong', 'moderate', 'limited', 'emerging', 'conflicting', 'insufficient')
    ),
    manifest_hash TEXT NOT NULL, -- SHA-256 of canonical manifest JSON
    merkle_root TEXT NOT NULL,   -- Merkle root of the research batch / claim tree
    merkle_proof JSONB NOT NULL DEFAULT '[]'::jsonb, -- Array of audit path hashes
    leaf_index INT NOT NULL DEFAULT 0,
    tree_size INT NOT NULL DEFAULT 1,
    claim_count INT NOT NULL DEFAULT 1,
    source_count INT NOT NULL DEFAULT 1,
    non_sensitive_manifest JSONB NOT NULL, -- Canonical manifest without PII
    anchor_status TEXT NOT NULL DEFAULT 'pending' CHECK (
        anchor_status IN ('pending', 'submitted', 'anchored', 'verified', 'failed')
    ),
    chain_id TEXT NOT NULL DEFAULT 'sepolia-testnet',
    contract_or_anchor_address TEXT,
    tx_hash TEXT,
    block_number BIGINT,
    anchored_at TIMESTAMPTZ,
    verification_attempts INT NOT NULL DEFAULT 0,
    last_error TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Foreign key to ai_conversations with composite tenant check (if conversation_id present)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_provenance_conversation_user'
          AND conrelid = 'public.research_provenance_manifests'::regclass
    ) THEN
        ALTER TABLE public.research_provenance_manifests
            ADD CONSTRAINT fk_provenance_conversation_user
            FOREIGN KEY (conversation_id, user_id)
            REFERENCES public.ai_conversations(id, user_id)
            ON DELETE SET NULL;
    END IF;
END $$;

-- 3. High-Performance Indexes for Proof Verification & Tenant Lookups
CREATE INDEX IF NOT EXISTS idx_provenance_user_id
    ON public.research_provenance_manifests (user_id);

CREATE INDEX IF NOT EXISTS idx_provenance_manifest_hash
    ON public.research_provenance_manifests (manifest_hash);

CREATE INDEX IF NOT EXISTS idx_provenance_merkle_root
    ON public.research_provenance_manifests (merkle_root);

CREATE INDEX IF NOT EXISTS idx_provenance_tx_hash
    ON public.research_provenance_manifests (tx_hash)
    WHERE tx_hash IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_provenance_inquiry_ref
    ON public.research_provenance_manifests (inquiry_reference_id);

CREATE INDEX IF NOT EXISTS idx_provenance_anchor_status
    ON public.research_provenance_manifests (anchor_status);

-- 4. Multi-Tenant Row Level Security (RLS)
ALTER TABLE public.research_provenance_manifests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own provenance manifests" ON public.research_provenance_manifests;
DROP POLICY IF EXISTS "Users can insert own provenance manifests" ON public.research_provenance_manifests;
DROP POLICY IF EXISTS "Users can update own provenance manifests" ON public.research_provenance_manifests;
DROP POLICY IF EXISTS "Users can delete own provenance manifests" ON public.research_provenance_manifests;

CREATE POLICY "Users can view own provenance manifests"
    ON public.research_provenance_manifests FOR SELECT
    TO authenticated
    USING ((select auth.uid()) = user_id);

CREATE POLICY "Users can insert own provenance manifests"
    ON public.research_provenance_manifests FOR INSERT
    TO authenticated
    WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY "Users can update own provenance manifests"
    ON public.research_provenance_manifests FOR UPDATE
    TO authenticated
    USING ((select auth.uid()) = user_id)
    WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY "Users can delete own provenance manifests"
    ON public.research_provenance_manifests FOR DELETE
    TO authenticated
    USING ((select auth.uid()) = user_id);

-- 5. Updated_at Trigger
CREATE OR REPLACE FUNCTION public.handle_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_provenance_manifests_updated_at ON public.research_provenance_manifests;
CREATE TRIGGER set_provenance_manifests_updated_at
    BEFORE UPDATE ON public.research_provenance_manifests
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at_column();
