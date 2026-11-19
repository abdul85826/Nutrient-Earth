-- ==============================================================================
-- Migration: 20261118000001_universal_research_and_food_intelligence.sql
-- Description: Universal Research, Web Intelligence, Food Processing,
--              Utensil Safety, Food Hazards, and Evidence-Backed Practices.
--
-- Components:
--   1. Research Acquisition & Crawler Registry (SSRF/Robots safe)
--   2. Scientific Claims & Contradiction Engine (Study hierarchy, retractions)
--   3. Ingredient Food-Processing & Nutrient Transformations (Retention vs Concentration)
--   4. Utensils & Food-Contact Material Safety (Acidic migration, temperature, coatings)
--   5. Food Hazards, Contaminants & Cancer Evidence (FSSAI limits, IARC groups, HCA/PAH)
--   6. Evidence-Backed Everyday Practices (Habits, effect sizes, contraindications)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Research Acquisition & Crawler Governance
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.crawler_domain_policies (
    domain TEXT PRIMARY KEY,
    is_allowed BOOLEAN NOT NULL DEFAULT true,
    crawl_delay_seconds INT NOT NULL DEFAULT 5,
    user_agent TEXT NOT NULL DEFAULT 'NutrientEarthResearchBot/1.0 (+https://nutrientearth.com/bot)',
    rate_limit_per_minute INT NOT NULL DEFAULT 12,
    robots_txt_url TEXT,
    last_robots_check TIMESTAMPTZ,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE TABLE IF NOT EXISTS public.crawled_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    canonical_url TEXT NOT NULL UNIQUE,
    domain TEXT NOT NULL REFERENCES public.crawler_domain_policies(domain) ON DELETE RESTRICT,
    title TEXT NOT NULL,
    main_text TEXT NOT NULL,
    authors TEXT,
    publication_date DATE,
    doi TEXT,
    pmid TEXT,
    content_hash_sha256 TEXT NOT NULL,
    http_etag TEXT,
    last_modified_header TEXT,
    license_type TEXT NOT NULL DEFAULT 'open_access',
    extraction_status TEXT NOT NULL DEFAULT 'extracted' CHECK (
        extraction_status IN ('pending', 'extracted', 'failed', 'blocked_robots', 'flagged_untrusted')
    ),
    is_trusted_source BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_crawled_docs_domain ON public.crawled_documents (domain);
CREATE INDEX IF NOT EXISTS idx_crawled_docs_doi ON public.crawled_documents (doi) WHERE doi IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_crawled_docs_pmid ON public.crawled_documents (pmid) WHERE pmid IS NOT NULL;

-- ------------------------------------------------------------------------------
-- 2. Scientific Claims & Contradiction Detection Engine
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.scientific_claims (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    publication_id UUID REFERENCES public.scientific_publications(id) ON DELETE SET NULL,
    crawled_doc_id UUID REFERENCES public.crawled_documents(id) ON DELETE SET NULL,
    claim_text TEXT NOT NULL,
    claim_category TEXT NOT NULL CHECK (
        claim_category IN (
            'bioavailability',
            'nutrient_retention',
            'health_outcome',
            'food_safety',
            'utensil_migration',
            'disease_prevention',
            'metabolic_function'
        )
    ),
    study_design TEXT NOT NULL CHECK (
        study_design IN (
            'meta_analysis',
            'randomized_controlled_trial',
            'prospective_cohort',
            'case_control',
            'in_vitro_mechanistic',
            'animal_model',
            'expert_guideline',
            'traditional_observation'
        )
    ),
    population_description TEXT,
    sample_size INT,
    intervention_or_exposure TEXT,
    comparator TEXT,
    primary_outcome TEXT,
    effect_size_summary TEXT,
    confidence_interval TEXT,
    is_statistically_significant BOOLEAN,
    is_retracted BOOLEAN NOT NULL DEFAULT false,
    study_limitations TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_scientific_claims_category
    ON public.scientific_claims (claim_category, study_design);

CREATE TABLE IF NOT EXISTS public.claim_contradictions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    primary_claim_id UUID NOT NULL REFERENCES public.scientific_claims(id) ON DELETE CASCADE,
    conflicting_claim_id UUID NOT NULL REFERENCES public.scientific_claims(id) ON DELETE CASCADE,
    contradiction_category TEXT NOT NULL CHECK (
        contradiction_category IN (
            'conflicting_outcomes',
            'population_variance',
            'dosage_threshold_variance',
            'preparation_method_variance',
            'study_quality_disparity'
        )
    ),
    explanation TEXT NOT NULL,
    evidence_synthesis TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- ------------------------------------------------------------------------------
-- 3. Ingredient Food Processing & Nutrient Transformations
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ingredient_processing_operations (
    id TEXT PRIMARY KEY, -- e.g. 'op_washing', 'op_soaking', 'op_sprouting', 'op_boiling', 'op_steaming', 'op_pressure_cooking', 'op_reheating'
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    typical_temperature_c NUMERIC,
    typical_duration_minutes INT,
    water_interaction TEXT CHECK (water_interaction IN ('none', 'submerged', 'vapor', 'rinsed', 'discarded_water'))
);

CREATE TABLE IF NOT EXISTS public.nutrient_transformation_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ingredient_id TEXT, -- Slugs e.g. 'spinach', 'parboiled_rice', 'chana_dal', 'moringa'
    operation_id TEXT NOT NULL REFERENCES public.ingredient_processing_operations(id) ON DELETE RESTRICT,
    nutrient_id TEXT NOT NULL, -- e.g. 'nut_vitamin_c', 'nut_folate', 'nut_iron', 'nut_resistant_starch'
    retention_percentage_min NUMERIC(5,2) NOT NULL, -- e.g. 45.00%
    retention_percentage_max NUMERIC(5,2) NOT NULL, -- e.g. 75.00%
    concentration_change_factor NUMERIC(5,2) DEFAULT 1.00, -- Accounts for moisture loss/gain
    leaching_risk TEXT NOT NULL DEFAULT 'none' CHECK (leaching_risk IN ('none', 'low', 'moderate', 'high')),
    bioavailability_effect TEXT NOT NULL DEFAULT 'unchanged' CHECK (
        bioavailability_effect IN ('increased', 'decreased', 'unchanged')
    ),
    antinutrient_reduction_percent NUMERIC(5,2) DEFAULT 0.00, -- e.g. Phytate or Oxalate reduction %
    resistant_starch_impact TEXT CHECK (resistant_starch_impact IN ('formed_rs3', 'degraded', 'unaffected')),
    scientific_mechanism TEXT NOT NULL,
    evidence_citation TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_nutrient_transformations_lookup
    ON public.nutrient_transformation_rules (ingredient_id, operation_id, nutrient_id);

-- ------------------------------------------------------------------------------
-- 4. Utensils & Food-Contact Material Safety
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.utensil_materials (
    id TEXT PRIMARY KEY, -- e.g. 'mat_cast_iron', 'mat_stainless_steel_304', 'mat_raw_aluminium', 'mat_copper_unlined', 'mat_ceramic_glazed', 'mat_nonstick_ptfe'
    name TEXT NOT NULL,
    material_category TEXT NOT NULL CHECK (
        material_category IN ('ferrous_metal', 'non_ferrous_metal', 'alloy', 'ceramic_earthenware', 'polymer_coating', 'silicone', 'glass')
    ),
    food_contact_grade TEXT NOT NULL,
    max_safe_temp_c NUMERIC NOT NULL,
    acidic_food_compatibility TEXT NOT NULL CHECK (
        acidic_food_compatibility IN ('safe', 'caution_short_contact', 'contraindicated_leaching')
    ),
    leaching_potential_elements TEXT[], -- e.g. ARRAY['iron'], ARRAY['aluminium'], ARRAY['copper', 'nickel'], ARRAY['lead', 'cadmium']
    coating_degradation_risk TEXT NOT NULL,
    efsa_fssai_compliance_notes TEXT NOT NULL,
    usage_guidelines TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- ------------------------------------------------------------------------------
-- 5. Food Hazards, Contaminants & Cancer Evidence
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.food_safety_hazards (
    id TEXT PRIMARY KEY, -- e.g. 'haz_aflatoxin_b1', 'haz_acrylamide', 'haz_lead', 'haz_chlorpyrifos', 'haz_heterocyclic_amines'
    name TEXT NOT NULL,
    hazard_class TEXT NOT NULL CHECK (
        hazard_class IN ('mycotoxin', 'heavy_metal', 'pesticide_residue', 'processing_contaminant', 'bacterial_pathogen', 'adulterant')
    ),
    fssai_max_permissible_limit TEXT,
    codex_max_limit TEXT,
    iarc_carcinogenicity_group TEXT CHECK (
        iarc_carcinogenicity_group IN (
            'Group 1: Carcinogenic to humans',
            'Group 2A: Probably carcinogenic to humans',
            'Group 2B: Possibly carcinogenic to humans',
            'Group 3: Not classifiable as to carcinogenicity'
        )
    ),
    formation_conditions TEXT,
    high_risk_foods TEXT[],
    human_evidence_summary TEXT NOT NULL,
    mitigation_strategies TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- ------------------------------------------------------------------------------
-- 6. Evidence-Backed Everyday Practices (Practical Habits Engine)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.evidence_backed_practices (
    id TEXT PRIMARY KEY, -- e.g. 'prac_morning_sunlight', 'prac_soleus_pushup', 'prac_rice_retrogradation', 'prac_cast_iron_iron_boost'
    title TEXT NOT NULL,
    category TEXT NOT NULL CHECK (
        category IN ('food_preparation', 'circadian_sleep', 'physical_movement', 'metabolic_health', 'environmental_safety')
    ),
    target_benefit TEXT NOT NULL,
    target_population TEXT NOT NULL,
    contraindications TEXT,
    evidence_grade TEXT NOT NULL CHECK (
        evidence_grade IN (
            'strong_meta_analysis',
            'moderate_rct',
            'preliminary_cohort',
            'traditional_verified',
            'inconclusive'
        )
    ),
    effect_size_summary TEXT NOT NULL,
    practical_protocol TEXT NOT NULL,
    effort_level TEXT NOT NULL CHECK (effort_level IN ('minimal', 'moderate', 'high')),
    cost_level TEXT NOT NULL CHECK (cost_level IN ('free', 'low_cost', 'investment')),
    key_studies TEXT[],
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- ------------------------------------------------------------------------------
-- RLS Security: Read-Only Public Scientific Knowledge
-- ------------------------------------------------------------------------------
ALTER TABLE public.crawler_domain_policies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.crawled_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scientific_claims ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.claim_contradictions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ingredient_processing_operations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.nutrient_transformation_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.utensil_materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.food_safety_hazards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.evidence_backed_practices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read-only scientific crawler policies"
    ON public.crawler_domain_policies FOR SELECT TO authenticated, anon USING (true);

CREATE POLICY "Public read-only scientific crawled docs"
    ON public.crawled_documents FOR SELECT TO authenticated, anon USING (true);

CREATE POLICY "Public read-only scientific claims"
    ON public.scientific_claims FOR SELECT TO authenticated, anon USING (true);

CREATE POLICY "Public read-only claim contradictions"
    ON public.claim_contradictions FOR SELECT TO authenticated, anon USING (true);

CREATE POLICY "Public read-only food processing ops"
    ON public.ingredient_processing_operations FOR SELECT TO authenticated, anon USING (true);

CREATE POLICY "Public read-only nutrient transformations"
    ON public.nutrient_transformation_rules FOR SELECT TO authenticated, anon USING (true);

CREATE POLICY "Public read-only utensil materials"
    ON public.utensil_materials FOR SELECT TO authenticated, anon USING (true);

CREATE POLICY "Public read-only food safety hazards"
    ON public.food_safety_hazards FOR SELECT TO authenticated, anon USING (true);

CREATE POLICY "Public read-only evidence backed practices"
    ON public.evidence_backed_practices FOR SELECT TO authenticated, anon USING (true);
