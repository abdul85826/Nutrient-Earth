-- ==============================================================================
-- Nutrient Earth — Universal Health Knowledge Graph & Direct Source Acquisition Engine
-- Migration: 20261121000003_universal_health_knowledge_graph_and_direct_acquisition.sql
--
-- Provisions:
-- 1. Universal Knowledge Graph Expansion (All 23 Core Entity Types & 15 Relationship Types)
-- 2. Direct Scientific Source Registry (Zero MCP Dependency)
-- 3. Source Acquisition Events & Idempotency Audit Ledger
-- 4. Multi-Tenant Row Level Security & Provenance Tracking
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Universal Health Knowledge Graph Schema Expansion
-- ------------------------------------------------------------------------------

-- Drop existing entity_type constraint and replace with all 23 canonical types
ALTER TABLE public.kg_entities DROP CONSTRAINT IF EXISTS kg_entities_entity_type_check;

ALTER TABLE public.kg_entities ADD CONSTRAINT kg_entities_entity_type_check CHECK (
    entity_type IN (
        'exposure',
        'chemical',
        'material',
        'product',
        'food',
        'ingredient',
        'activity',
        'environment',
        'biological_mechanism',
        'organ',
        'cell',
        'gene',
        'hormone',
        'population',
        'health_outcome',
        'disease',
        'intervention',
        'study',
        'evidence_claim',
        'source',
        'guideline',
        'regulation',
        'recommendation'
    )
);

-- Drop existing relationship_type constraint and replace with all 15 canonical relationships
ALTER TABLE public.kg_relationships DROP CONSTRAINT IF EXISTS kg_relationships_relationship_type_check;

ALTER TABLE public.kg_relationships ADD CONSTRAINT kg_relationships_relationship_type_check CHECK (
    relationship_type IN (
        'contains',
        'exposes_to',
        'interacts_with',
        'affects',
        'associated_with',
        'causes',
        'prevents',
        'treats',
        'measured_by',
        'studied_in',
        'supported_by',
        'contradicted_by',
        'applies_to',
        'supersedes',
        'regulated_by'
    )
);

-- Add provenance, versioning, and causality justifications to relationships
ALTER TABLE public.kg_relationships
    ADD COLUMN IF NOT EXISTS causality_justification TEXT,
    ADD COLUMN IF NOT EXISTS relationship_version INT NOT NULL DEFAULT 1,
    ADD COLUMN IF NOT EXISTS provenance_hash TEXT,
    ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT true;

CREATE INDEX IF NOT EXISTS idx_kg_rel_causality ON public.kg_relationships(relationship_type, is_active);

-- ------------------------------------------------------------------------------
-- 2. Direct Scientific Source Registry (NO MCP DEPENDENCY)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.direct_source_registry (
    id TEXT PRIMARY KEY, -- e.g. 'pubmed_ncbi', 'europe_pmc', 'openalex', 'usda_fdc', 'pubchem', 'clinical_trials_v2'
    name TEXT NOT NULL,
    official_source_url TEXT NOT NULL,
    documentation_url TEXT NOT NULL,
    api_base_url TEXT NOT NULL,
    auth_requirement TEXT NOT NULL CHECK (
        auth_requirement IN ('none', 'api_key_header', 'api_key_query', 'bearer_token', 'open_access')
    ),
    rate_limit_per_second NUMERIC(4,1) NOT NULL DEFAULT 3.0,
    timeout_seconds INT NOT NULL DEFAULT 15,
    max_retries INT NOT NULL DEFAULT 3,
    license TEXT NOT NULL,
    usage_restrictions TEXT NOT NULL,
    health_status TEXT NOT NULL DEFAULT 'operational' CHECK (
        health_status IN ('operational', 'degraded', 'rate_limited', 'outage', 'maintenance')
    ),
    total_acquisitions INT NOT NULL DEFAULT 0,
    failed_acquisitions INT NOT NULL DEFAULT 0,
    last_successful_acquisition_at TIMESTAMPTZ,
    last_verified_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Seed Canonical Direct External Sources
INSERT INTO public.direct_source_registry (
    id, name, official_source_url, documentation_url, api_base_url,
    auth_requirement, rate_limit_per_second, license, usage_restrictions
) VALUES
('pubmed_ncbi', 'PubMed & NCBI E-utilities', 'https://pubmed.ncbi.nlm.nih.gov', 'https://www.ncbi.nlm.nih.gov/books/NBK25501/', 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils', 'none', 3.0, 'Public Domain (US Gov)', 'Max 3 req/sec without API key, 10 req/sec with key; respect E-utilities guidelines'),
('europe_pmc', 'Europe PMC REST API', 'https://europepmc.org', 'https://europepmc.org/RestfulWebService', 'https://www.ebi.ac.uk/europepmc/webservices/rest', 'none', 5.0, 'CC0 / CC-BY (Open Access subset)', 'Attribution required for commercial reuse; respect rate limits'),
('openalex', 'OpenAlex Global Scholarly Graph', 'https://openalex.org', 'https://docs.openalex.org', 'https://api.openalex.org', 'none', 10.0, 'CC0 Universal', 'Include mailto in user-agent for polite pool access'),
('clinical_trials_gov', 'ClinicalTrials.gov API v2', 'https://clinicaltrials.gov', 'https://clinicaltrials.gov/data-api/about-api', 'https://clinicaltrials.gov/api/v2', 'none', 5.0, 'Public Domain', 'Government trial registry; no commercial endorsement permitted'),
('usda_fooddata_central', 'USDA FoodData Central', 'https://fdc.nal.usda.gov', 'https://fdc.nal.usda.gov/api-guide.html', 'https://api.nal.usda.gov/fdc/v1', 'api_key_query', 2.0, 'Public Domain', 'Standard API key required for full throughput'),
('pubchem_pug_rest', 'PubChem PUG REST', 'https://pubchem.ncbi.nlm.nih.gov', 'https://pubchem.ncbi.nlm.nih.gov/docs/pug-rest', 'https://pubchem.ncbi.nlm.nih.gov/rest/pug', 'none', 5.0, 'Public Domain', 'Max 5 requests per second; bulk requests must be batched'),
('open_food_facts', 'Open Food Facts Database', 'https://world.openfoodfacts.org', 'https://openfoodfacts.github.io/api-documentation/', 'https://world.openfoodfacts.org/api/v2', 'none', 2.0, 'Open Database License (ODbL)', 'Database attribution required; respect robots.txt and query headers'),
('openfda_drug_labeling', 'openFDA Drug Product Labels', 'https://open.fda.gov', 'https://open.fda.gov/apis/drug/label/', 'https://api.fda.gov/drug', 'none', 4.0, 'CC0 Universal', 'Official FDA drug labeling and warnings; not a substitute for clinical advice'),
('chembl_ebi', 'ChEMBL Bioactive Compounds', 'https://www.ebi.ac.uk/chembl/', 'https://chembl.gitbook.io/chembl-interface-documentation/web-services', 'https://www.ebi.ac.uk/chembl/api/data', 'none', 5.0, 'CC-BY-SA 3.0', 'European Bioinformatics Institute; attribution required')
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    official_source_url = EXCLUDED.official_source_url,
    documentation_url = EXCLUDED.documentation_url,
    api_base_url = EXCLUDED.api_base_url,
    rate_limit_per_second = EXCLUDED.rate_limit_per_second,
    usage_restrictions = EXCLUDED.usage_restrictions;

-- ------------------------------------------------------------------------------
-- 3. Source Acquisition Events & Idempotency Audit Ledger
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.source_acquisition_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_id TEXT NOT NULL REFERENCES public.direct_source_registry(id) ON DELETE RESTRICT,
    external_identifier TEXT NOT NULL, -- e.g. PMID '19056590', DOI '10.3945/ajcn.2008.26401', FDC ID '171688'
    request_url TEXT NOT NULL,
    acquisition_state TEXT NOT NULL CHECK (
        acquisition_state IN (
            'DISCOVERED',
            'ACCESS_CHECKED',
            'ACQUIRED',
            'INTEGRITY_VERIFIED',
            'PARSED',
            'NORMALIZED',
            'VALIDATED',
            'STORED',
            'INDEXED',
            'AVAILABLE',
            'RESTRICTED',
            'FAILED',
            'DUPLICATE',
            'QUARANTINED',
            'SUPERSEDED',
            'WITHDRAWN'
        )
    ),
    http_status_code INT,
    latency_ms INT NOT NULL DEFAULT 0,
    content_hash_sha256 TEXT NOT NULL,
    schema_validated BOOLEAN NOT NULL DEFAULT true,
    error_classification TEXT, -- 'RATE_LIMIT_EXCEEDED', 'NETWORK_TIMEOUT', 'NOT_FOUND', 'MALFORMED_JSON', 'ROBOTS_RESTRICTED'
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    acquired_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_source_external_hash UNIQUE (source_id, external_identifier, content_hash_sha256)
);

CREATE INDEX IF NOT EXISTS idx_acquisition_source_state ON public.source_acquisition_events(source_id, acquisition_state);
CREATE INDEX IF NOT EXISTS idx_acquisition_hash ON public.source_acquisition_events(content_hash_sha256);

-- ------------------------------------------------------------------------------
-- 4. Row Level Security & Operational Permissions
-- ------------------------------------------------------------------------------
ALTER TABLE public.direct_source_registry ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.source_acquisition_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read for direct source registry"
    ON public.direct_source_registry FOR SELECT TO authenticated, anon USING (true);

CREATE POLICY "Service role full access for source acquisition events"
    ON public.source_acquisition_events FOR ALL TO service_role USING (true);

CREATE POLICY "Public read access for acquisition events"
    ON public.source_acquisition_events FOR SELECT TO authenticated, anon USING (true);
