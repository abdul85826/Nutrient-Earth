-- ==============================================================================
-- Migration: 20261118000004_blockchain_trust_infrastructure.sql
-- Description: Hybrid Web2 + Web3 Cryptographic Provenance & Blockchain Trust
--              Infrastructure for Nutrient Earth.
--
-- Components:
--   1. Networks & Contract Deployments (Base Sepolia 84532 / Base Mainnet 8453)
--   2. Protocol Versions & Standards Registry
--   3. Merkle Batches & Transaction Lifecycle State Machine
--   4. Cryptographic Commitments & Merkle Proofs
--   5. Issuer Directory & Key Status
--   6. Independent Verification Audit Logs
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Networks & Deployments
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.blockchain_networks (
    chain_id BIGINT PRIMARY KEY,
    network_name TEXT NOT NULL,
    rpc_endpoint_masked TEXT NOT NULL,
    block_explorer_url TEXT NOT NULL,
    finality_confirmations INT NOT NULL DEFAULT 12,
    is_testnet BOOLEAN NOT NULL DEFAULT true,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

INSERT INTO public.blockchain_networks (chain_id, network_name, rpc_endpoint_masked, block_explorer_url, finality_confirmations, is_testnet, is_active)
VALUES
    (84532, 'Base Sepolia Testnet', 'https://sepolia.base.org', 'https://sepolia.basescan.org', 5, true, true),
    (8453, 'Base Mainnet', 'https://mainnet.base.org', 'https://basescan.org', 20, false, false)
ON CONFLICT (chain_id) DO NOTHING;

CREATE TABLE IF NOT EXISTS public.blockchain_contract_deployments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chain_id BIGINT NOT NULL REFERENCES public.blockchain_networks(chain_id) ON DELETE RESTRICT,
    contract_name TEXT NOT NULL CHECK (
        contract_name IN ('EvidenceAnchorRegistry', 'IssuerRegistry', 'ProtocolVersionRegistry')
    ),
    contract_address TEXT NOT NULL,
    deployment_tx_hash TEXT,
    deployed_by TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    deployed_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    UNIQUE(chain_id, contract_name, contract_address)
);

CREATE INDEX IF NOT EXISTS idx_deployments_chain_contract ON public.blockchain_contract_deployments (chain_id, contract_name);

-- ------------------------------------------------------------------------------
-- 2. Protocol Versions
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.blockchain_protocol_versions (
    version TEXT PRIMARY KEY,
    schema_uri TEXT NOT NULL,
    hashing_standard TEXT NOT NULL DEFAULT 'KECCAK256_RFC8785',
    is_active BOOLEAN NOT NULL DEFAULT true,
    registered_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    deprecated_at TIMESTAMPTZ
);

INSERT INTO public.blockchain_protocol_versions (version, schema_uri, hashing_standard, is_active)
VALUES ('1.0.0', 'ipfs://bafkreinutrientearthschema100', 'KECCAK256_RFC8785', true)
ON CONFLICT (version) DO NOTHING;

-- ------------------------------------------------------------------------------
-- 3. Batches & Transaction State Machine
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.blockchain_batches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_id TEXT NOT NULL UNIQUE,
    chain_id BIGINT NOT NULL REFERENCES public.blockchain_networks(chain_id) ON DELETE RESTRICT,
    merkle_root TEXT NOT NULL UNIQUE,
    batch_size INT NOT NULL CHECK (batch_size > 0),
    protocol_version TEXT NOT NULL REFERENCES public.blockchain_protocol_versions(version) ON DELETE RESTRICT,
    manifest_uri TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'created' CHECK (
        status IN ('created', 'queued', 'submitted', 'pending', 'confirmed', 'finalized', 'failed', 'reorged')
    ),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_batches_status ON public.blockchain_batches (status);
CREATE INDEX IF NOT EXISTS idx_batches_root ON public.blockchain_batches (merkle_root);

CREATE TABLE IF NOT EXISTS public.blockchain_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_id UUID NOT NULL REFERENCES public.blockchain_batches(id) ON DELETE CASCADE,
    chain_id BIGINT NOT NULL REFERENCES public.blockchain_networks(chain_id) ON DELETE RESTRICT,
    tx_hash TEXT NOT NULL UNIQUE,
    from_address TEXT NOT NULL,
    to_contract_address TEXT NOT NULL,
    nonce INT,
    status TEXT NOT NULL DEFAULT 'SUBMITTED' CHECK (
        status IN ('CREATED', 'QUEUED', 'SUBMITTED', 'PENDING', 'CONFIRMED', 'FINALIZED', 'FAILED', 'REPLACED', 'REORGED')
    ),
    block_number BIGINT,
    confirmations_count INT NOT NULL DEFAULT 0,
    gas_used BIGINT,
    effective_gas_price_wei NUMERIC,
    error_message TEXT,
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    confirmed_at TIMESTAMPTZ,
    finalized_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_tx_batch ON public.blockchain_transactions (batch_id);
CREATE INDEX IF NOT EXISTS idx_tx_status ON public.blockchain_transactions (status);

-- ------------------------------------------------------------------------------
-- 4. Cryptographic Commitments & Merkle Proofs
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.cryptographic_commitments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_id UUID REFERENCES public.blockchain_batches(id) ON DELETE SET NULL,
    record_type TEXT NOT NULL CHECK (
        record_type IN ('scientific_evidence', 'product_verification', 'ai_recommendation', 'consent_audit')
    ),
    record_id TEXT NOT NULL,
    record_version TEXT NOT NULL DEFAULT 'v1.0.0',
    leaf_hash TEXT NOT NULL,
    leaf_index INT NOT NULL DEFAULT 0,
    merkle_proof JSONB NOT NULL DEFAULT '[]'::jsonb,
    canonical_payload_digest TEXT NOT NULL,
    domain_separator TEXT NOT NULL,
    is_anchored BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_commitments_record ON public.cryptographic_commitments (record_type, record_id);
CREATE INDEX IF NOT EXISTS idx_commitments_leaf ON public.cryptographic_commitments (leaf_hash);
CREATE INDEX IF NOT EXISTS idx_commitments_batch ON public.cryptographic_commitments (batch_id);

-- ------------------------------------------------------------------------------
-- 5. Authorized Issuers Directory
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.blockchain_issuers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    issuer_address TEXT NOT NULL UNIQUE,
    organization_name TEXT NOT NULL,
    metadata_uri TEXT,
    assigned_role TEXT NOT NULL DEFAULT 'ISSUER_ROLE',
    is_active BOOLEAN NOT NULL DEFAULT true,
    registered_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    revoked_at TIMESTAMPTZ,
    revocation_reason TEXT
);

CREATE INDEX IF NOT EXISTS idx_issuers_address ON public.blockchain_issuers (issuer_address);

-- ------------------------------------------------------------------------------
-- 6. Independent Verification Audit Logs
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.verification_audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    commitment_id UUID REFERENCES public.cryptographic_commitments(id) ON DELETE SET NULL,
    record_type TEXT NOT NULL,
    record_id TEXT NOT NULL,
    provided_leaf_hash TEXT NOT NULL,
    provided_root TEXT NOT NULL,
    verification_status TEXT NOT NULL CHECK (
        verification_status IN (
            'VALID_COMMITMENT',
            'INVALID_COMMITMENT',
            'UNKNOWN_BATCH',
            'UNCONFIRMED_TRANSACTION',
            'REVOKED_ISSUER',
            'UNSUPPORTED_PROTOCOL',
            'INSUFFICIENT_VERIFICATION_DATA'
        )
    ),
    verification_checks JSONB NOT NULL DEFAULT '{}'::jsonb,
    verifier_ip_hash TEXT,
    verified_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_verification_status ON public.verification_audit_logs (verification_status);

-- ------------------------------------------------------------------------------
-- 7. Row Level Security Hardening
-- ------------------------------------------------------------------------------
ALTER TABLE public.blockchain_networks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.blockchain_contract_deployments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.blockchain_protocol_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.blockchain_batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.blockchain_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cryptographic_commitments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.blockchain_issuers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.verification_audit_logs ENABLE ROW LEVEL SECURITY;

-- Shared public read policies for independent verification
CREATE POLICY "Public read networks" ON public.blockchain_networks FOR SELECT TO authenticated, anon USING (true);
CREATE POLICY "Public read deployments" ON public.blockchain_contract_deployments FOR SELECT TO authenticated, anon USING (true);
CREATE POLICY "Public read protocol versions" ON public.blockchain_protocol_versions FOR SELECT TO authenticated, anon USING (true);
CREATE POLICY "Public read batches" ON public.blockchain_batches FOR SELECT TO authenticated, anon USING (true);
CREATE POLICY "Public read transactions" ON public.blockchain_transactions FOR SELECT TO authenticated, anon USING (true);
CREATE POLICY "Public read commitments" ON public.cryptographic_commitments FOR SELECT TO authenticated, anon USING (true);
CREATE POLICY "Public read issuers" ON public.blockchain_issuers FOR SELECT TO authenticated, anon USING (true);

-- Verification audit logs: insert allowed, select for verifiers
CREATE POLICY "Allow log verification" ON public.verification_audit_logs FOR INSERT TO authenticated, anon WITH CHECK (true);
CREATE POLICY "Public read verification logs" ON public.verification_audit_logs FOR SELECT TO authenticated, anon USING (true);
