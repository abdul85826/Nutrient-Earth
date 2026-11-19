-- ==============================================================================
-- Migration: 20261118000003_universal_product_verification_and_multimodal.sql
-- Description: Universal Product Verification, Multimodal Ingestion Records,
--              Claim-Level Evidence, Multidimensional Ratings, Video Understanding,
--              and Governed Recommendation Architecture.
--
-- Components:
--   1. Companies, Brands, Products, Variants, & Multi-standard Identifiers (GTIN/EAN/UPC)
--   2. Product Formulations & Ingredients (Order of predominance, INCI/MeSH)
--   3. Claim-Level Verification & Scientific Evidence Linkage
--   4. Multidimensional Product Assessment Framework (10 Transparent Dimensions)
--   5. Universal Content Ingestion Records (Durable audit log, SHA-256 hashes)
--   6. Video Multimodal Timeline & Scene Observation Records
--   7. Governed Recommendation Decisions & User Feedback
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Companies & Brands
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.companies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    headquarters_country TEXT,
    website_url TEXT,
    is_verified BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE TABLE IF NOT EXISTS public.brands (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID REFERENCES public.companies(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    UNIQUE(company_id, name)
);

CREATE INDEX IF NOT EXISTS idx_brands_company ON public.brands (company_id);

-- ------------------------------------------------------------------------------
-- 2. Products, Variants & Identifiers
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID REFERENCES public.brands(id) ON DELETE SET NULL,
    canonical_name TEXT NOT NULL,
    category TEXT NOT NULL CHECK (
        category IN ('food', 'supplement', 'medicine', 'ayurvedic_herbal', 'personal_care', 'consumer_good')
    ),
    description TEXT,
    market_country TEXT NOT NULL DEFAULT 'GLOBAL',
    is_discontinued BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_products_brand ON public.products (brand_id);
CREATE INDEX IF NOT EXISTS idx_products_category ON public.products (category);

CREATE TABLE IF NOT EXISTS public.product_variants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    variant_name TEXT NOT NULL,
    sku TEXT,
    serving_size NUMERIC,
    serving_unit TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    UNIQUE(product_id, variant_name)
);

CREATE INDEX IF NOT EXISTS idx_variants_product ON public.product_variants (product_id);

CREATE TABLE IF NOT EXISTS public.product_identifiers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    variant_id UUID NOT NULL REFERENCES public.product_variants(id) ON DELETE CASCADE,
    identifier_type TEXT NOT NULL CHECK (
        identifier_type IN ('gtin', 'upc_a', 'ean_13', 'qr_code', 'manufacturer_code')
    ),
    identifier_value TEXT NOT NULL UNIQUE,
    is_primary BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_identifiers_value ON public.product_identifiers (identifier_value);

-- ------------------------------------------------------------------------------
-- 3. Formulations & Ingredients
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.product_formulations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    variant_id UUID NOT NULL REFERENCES public.product_variants(id) ON DELETE CASCADE,
    formulation_version TEXT NOT NULL DEFAULT 'v1.0',
    packaging_version TEXT,
    effective_date DATE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    UNIQUE(variant_id, formulation_version)
);

CREATE TABLE IF NOT EXISTS public.product_ingredients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    formulation_id UUID NOT NULL REFERENCES public.product_formulations(id) ON DELETE CASCADE,
    ingredient_name TEXT NOT NULL,
    standardized_inci_or_mesh TEXT,
    quantity_amount NUMERIC,
    quantity_unit TEXT,
    is_active_ingredient BOOLEAN NOT NULL DEFAULT false,
    order_of_predominance INT NOT NULL,
    processing_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_ingredients_formulation ON public.product_ingredients (formulation_id);

-- ------------------------------------------------------------------------------
-- 4. Claim-Level Verification & Scientific Evidence Linkage
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.product_claims (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    formulation_id UUID NOT NULL REFERENCES public.product_formulations(id) ON DELETE CASCADE,
    claim_text TEXT NOT NULL,
    claim_statement_type TEXT NOT NULL CHECK (
        claim_statement_type IN (
            'packaging_statement',
            'manufacturer_marketing',
            'regulatory_approved_claim',
            'third_party_lab_certification'
        )
    ),
    relevant_ingredient TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_product_claims_formulation ON public.product_claims (formulation_id);

CREATE TABLE IF NOT EXISTS public.product_claim_evidence (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    claim_id UUID NOT NULL REFERENCES public.product_claims(id) ON DELETE CASCADE,
    evidence_source_type TEXT NOT NULL CHECK (
        evidence_source_type IN (
            'clinical_trial',
            'meta_analysis',
            'independent_testing_lab',
            'regulatory_finding',
            'traditional_treatise'
        )
    ),
    citation_reference TEXT NOT NULL,
    verdict TEXT NOT NULL CHECK (
        verdict IN ('supported', 'contradicted', 'insufficient_evidence', 'misleading')
    ),
    confidence_score NUMERIC(3,2) NOT NULL DEFAULT 1.00 CHECK (
        confidence_score BETWEEN 0.00 AND 1.00
    ),
    population_studied TEXT,
    tested_dosage TEXT,
    limitations TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_claim_evidence_claim ON public.product_claim_evidence (claim_id);

-- ------------------------------------------------------------------------------
-- 5. Multidimensional Product Ratings Framework (10 Separate Dimensions)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.product_multidimensional_assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    variant_id UUID NOT NULL REFERENCES public.product_variants(id) ON DELETE CASCADE,
    formulation_id UUID NOT NULL REFERENCES public.product_formulations(id) ON DELETE CASCADE,
    scoring_algorithm_version TEXT NOT NULL DEFAULT 'v1.0.0',
    identity_confidence NUMERIC(3,2) NOT NULL CHECK (identity_confidence BETWEEN 0.00 AND 1.00),
    label_completeness_score NUMERIC(3,2) NOT NULL CHECK (label_completeness_score BETWEEN 0.00 AND 1.00),
    ingredient_transparency_score NUMERIC(3,2) NOT NULL CHECK (ingredient_transparency_score BETWEEN 0.00 AND 1.00),
    nutritional_composition_score NUMERIC(3,2) NOT NULL CHECK (nutritional_composition_score BETWEEN 0.00 AND 1.00),
    evidence_quality_score NUMERIC(3,2) NOT NULL CHECK (evidence_quality_score BETWEEN 0.00 AND 1.00),
    claim_substantiation_score NUMERIC(3,2) NOT NULL CHECK (claim_substantiation_score BETWEEN 0.00 AND 1.00),
    safety_score NUMERIC(3,2) NOT NULL CHECK (safety_score BETWEEN 0.00 AND 1.00),
    manufacturing_quality_score NUMERIC(3,2) NOT NULL CHECK (manufacturing_quality_score BETWEEN 0.00 AND 1.00),
    personal_suitability_score NUMERIC(3,2) NOT NULL CHECK (personal_suitability_score BETWEEN 0.00 AND 1.00),
    freshness_score NUMERIC(3,2) NOT NULL CHECK (freshness_score BETWEEN 0.00 AND 1.00),
    dimension_explanations JSONB NOT NULL DEFAULT '{}'::jsonb,
    unknowns_and_limitations JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_product_assessments_variant ON public.product_multidimensional_assessments (variant_id);

-- ------------------------------------------------------------------------------
-- 6. Universal Content Ingestion Records
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.content_ingestion_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    content_type TEXT NOT NULL CHECK (
        content_type IN (
            'text_query',
            'product_image',
            'barcode',
            'website_url',
            'pdf_document',
            'audio_voice',
            'video_media',
            'shared_content'
        )
    ),
    source_reference TEXT NOT NULL,
    detected_format TEXT NOT NULL,
    original_language TEXT NOT NULL DEFAULT 'en',
    content_hash_sha256 TEXT NOT NULL,
    extraction_status TEXT NOT NULL DEFAULT 'extracted' CHECK (
        extraction_status IN ('pending', 'extracted', 'failed', 'flagged_untrusted')
    ),
    extraction_version TEXT NOT NULL DEFAULT 'v1.0.0',
    provenance_metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_content_ingestion_user ON public.content_ingestion_records (user_id);
CREATE INDEX IF NOT EXISTS idx_content_ingestion_hash ON public.content_ingestion_records (content_hash_sha256);

-- ------------------------------------------------------------------------------
-- 7. Video Multimodal Timeline & Scene Observation Records
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.video_understanding_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ingestion_id UUID NOT NULL REFERENCES public.content_ingestion_records(id) ON DELETE CASCADE,
    video_url_or_path TEXT NOT NULL,
    duration_seconds INT NOT NULL,
    frame_samples_count INT NOT NULL DEFAULT 0,
    visual_entities JSONB NOT NULL DEFAULT '[]'::jsonb,
    on_screen_text_ocr JSONB NOT NULL DEFAULT '[]'::jsonb,
    audio_transcript_segments JSONB NOT NULL DEFAULT '[]'::jsonb,
    timeline_observations JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_video_understanding_ingestion ON public.video_understanding_records (ingestion_id);

-- ------------------------------------------------------------------------------
-- 8. Governed Recommendation Decisions & User Feedback
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.recommendation_decisions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trace_id TEXT NOT NULL,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    domain_type TEXT NOT NULL CHECK (
        domain_type IN ('food', 'supplement', 'medicine', 'ayurveda', 'exercise', 'lifestyle', 'consumer_good')
    ),
    user_intent TEXT NOT NULL,
    recommended_entity_id TEXT NOT NULL,
    recommended_entity_name TEXT NOT NULL,
    alternatives_evaluated JSONB NOT NULL DEFAULT '[]'::jsonb,
    rejection_reasons JSONB NOT NULL DEFAULT '{}'::jsonb,
    decision_rationale TEXT NOT NULL,
    safety_policy_version TEXT NOT NULL,
    scoring_algorithm_version TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_rec_decisions_user ON public.recommendation_decisions (user_id);
CREATE INDEX IF NOT EXISTS idx_rec_decisions_trace ON public.recommendation_decisions (trace_id);

CREATE TABLE IF NOT EXISTS public.user_product_feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
    assessment_id UUID REFERENCES public.product_multidimensional_assessments(id) ON DELETE SET NULL,
    feedback_type TEXT NOT NULL CHECK (
        feedback_type IN ('incorrect_identity', 'inaccurate_claim', 'unlisted_ingredient', 'general_correction')
    ),
    user_notes TEXT NOT NULL,
    proposed_correction JSONB NOT NULL DEFAULT '{}'::jsonb,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'accepted', 'rejected')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_user_feedback_user ON public.user_product_feedback (user_id);

-- ------------------------------------------------------------------------------
-- 9. Row Level Security Hardening
-- ------------------------------------------------------------------------------
ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.brands ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_identifiers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_formulations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_ingredients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_claims ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_claim_evidence ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_multidimensional_assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.content_ingestion_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.video_understanding_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommendation_decisions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_product_feedback ENABLE ROW LEVEL SECURITY;

-- Shared public read catalogs
CREATE POLICY "Public read companies" ON public.companies FOR SELECT TO authenticated, anon USING (true);
CREATE POLICY "Public read brands" ON public.brands FOR SELECT TO authenticated, anon USING (true);
CREATE POLICY "Public read products" ON public.products FOR SELECT TO authenticated, anon USING (true);
CREATE POLICY "Public read variants" ON public.product_variants FOR SELECT TO authenticated, anon USING (true);
CREATE POLICY "Public read identifiers" ON public.product_identifiers FOR SELECT TO authenticated, anon USING (true);
CREATE POLICY "Public read formulations" ON public.product_formulations FOR SELECT TO authenticated, anon USING (true);
CREATE POLICY "Public read ingredients" ON public.product_ingredients FOR SELECT TO authenticated, anon USING (true);
CREATE POLICY "Public read claims" ON public.product_claims FOR SELECT TO authenticated, anon USING (true);
CREATE POLICY "Public read claim evidence" ON public.product_claim_evidence FOR SELECT TO authenticated, anon USING (true);
CREATE POLICY "Public read assessments" ON public.product_multidimensional_assessments FOR SELECT TO authenticated, anon USING (true);

-- User-isolated records
CREATE POLICY "Users read own content ingestions" ON public.content_ingestion_records
    FOR SELECT TO authenticated USING (auth.uid() = user_id OR user_id IS NULL);
CREATE POLICY "Users insert own content ingestions" ON public.content_ingestion_records
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users read own video records" ON public.video_understanding_records
    FOR SELECT TO authenticated USING (
        EXISTS (
            SELECT 1 FROM public.content_ingestion_records r
            WHERE r.id = video_understanding_records.ingestion_id
              AND (r.user_id = auth.uid() OR r.user_id IS NULL)
        )
    );

CREATE POLICY "Users read own recommendations" ON public.recommendation_decisions
    FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "Users insert own recommendations" ON public.recommendation_decisions
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users read own feedback" ON public.user_product_feedback
    FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "Users insert own feedback" ON public.user_product_feedback
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
