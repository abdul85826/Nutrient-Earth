-- ==============================================================================
-- Migration: 20261112000001_master_scientific_knowledge_foundation.sql
-- Description: Master Scientific Data Architecture & Knowledge Foundation for Nutrient Earth
-- Covers all 55 sources across Categories A-G:
--   1. Sources, Source Licenses & Ingestion Runs
--   2. Scientific Publications & Clinical Trials
--   3. Botanical Taxa, Vernacular Synonyms & Herbs
--   4. Chemical Compounds, Plant-Compound Junctions & Compound Targets
--   5. Nutrients, Reference Intakes & Food Composition
--   6. Safety Evidence & Drug-Induced Liver Injury (LiverTox / DailyMed)
--   7. Genetics & Genomic Variations (GWAS Catalog / ClinVar)
--   8. Physical Activities & MET Values (Compendium of Physical Activities)
--   9. Scientific Document Chunks & Semantic Vector Embeddings
--   10. Row Level Security (RLS) & Integrity Check Constraints
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Scientific Sources & Ingestion Operations
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.scientific_sources (
    id TEXT PRIMARY KEY, -- e.g. 'src_pubmed', 'src_usda_fdc', 'src_fao_infoods'
    name TEXT NOT NULL,
    category TEXT NOT NULL CHECK (
        category IN (
            'A_research_literature',
            'B_chemistry_botanical',
            'C_traditional_medicine_safety',
            'D_anatomy_physiology_exercise',
            'E_datasets_genetics',
            'F_indian_data_food_safety',
            'G_environment_geographical'
        )
    ),
    home_url TEXT NOT NULL,
    api_docs_url TEXT,
    source_type TEXT NOT NULL,
    default_license TEXT NOT NULL,
    commercial_use_terms TEXT NOT NULL,
    requires_auth BOOLEAN NOT NULL DEFAULT false,
    sync_frequency TEXT NOT NULL DEFAULT 'weekly',
    is_active BOOLEAN NOT NULL DEFAULT true,
    last_synced_at TIMESTAMPTZ,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_scientific_sources_cat ON public.scientific_sources (category);

ALTER TABLE public.scientific_sources ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access for scientific sources"
    ON public.scientific_sources FOR SELECT
    TO authenticated, anon
    USING (true);

CREATE TABLE IF NOT EXISTS public.ingestion_runs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_id TEXT NOT NULL REFERENCES public.scientific_sources(id) ON DELETE RESTRICT,
    job_name TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('started', 'in_progress', 'completed', 'failed', 'partial')),
    records_acquired INT NOT NULL DEFAULT 0,
    records_normalized INT NOT NULL DEFAULT 0,
    bytes_processed BIGINT NOT NULL DEFAULT 0,
    error_message TEXT,
    started_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    completed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_ingestion_runs_source ON public.ingestion_runs (source_id, started_at DESC);

ALTER TABLE public.ingestion_runs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access for ingestion runs"
    ON public.ingestion_runs FOR SELECT
    TO authenticated, anon
    USING (true);

-- ------------------------------------------------------------------------------
-- 2. Scientific Publications & Clinical Trials
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.scientific_publications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_id TEXT NOT NULL REFERENCES public.scientific_sources(id) ON DELETE RESTRICT,
    pmid TEXT UNIQUE,
    pmcid TEXT,
    doi TEXT UNIQUE,
    title TEXT NOT NULL,
    authors TEXT[] NOT NULL DEFAULT '{}',
    journal TEXT,
    publication_year INT,
    publication_date TEXT,
    volume TEXT,
    issue TEXT,
    pages TEXT,
    abstract TEXT,
    study_type TEXT NOT NULL DEFAULT 'unspecified' CHECK (
        study_type IN (
            'clinical_trial',
            'randomized_controlled_trial',
            'systematic_review',
            'meta_analysis',
            'cohort_study',
            'case_control',
            'observational',
            'preclinical_animal',
            'in_vitro',
            'traditional_treatise',
            'review',
            'guideline',
            'unspecified'
        )
    ),
    evidence_level TEXT NOT NULL DEFAULT 'Level 4: Mechanistic / Observational' CHECK (
        evidence_level IN (
            'Level 1: Systematic Review / Meta-Analysis',
            'Level 2: Randomized Controlled Trial',
            'Level 3: Controlled Cohort / Non-Randomized',
            'Level 4: Mechanistic / Observational',
            'Level 5: Preclinical / In Vitro',
            'Traditional Empirical Knowledge'
        )
    ),
    mesh_terms TEXT[] NOT NULL DEFAULT '{}',
    keywords TEXT[] NOT NULL DEFAULT '{}',
    is_open_access BOOLEAN NOT NULL DEFAULT false,
    license TEXT NOT NULL DEFAULT 'Proprietary / Citation Permitted',
    original_url TEXT NOT NULL,
    raw_payload JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_scientific_pub_pmid ON public.scientific_publications (pmid) WHERE pmid IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_scientific_pub_doi ON public.scientific_publications (doi) WHERE doi IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_scientific_pub_year ON public.scientific_publications (publication_year);
CREATE INDEX IF NOT EXISTS idx_scientific_pub_study_type ON public.scientific_publications (study_type);
CREATE INDEX IF NOT EXISTS idx_scientific_pub_title_fts ON public.scientific_publications USING gin (to_tsvector('english', title));
CREATE INDEX IF NOT EXISTS idx_scientific_pub_abstract_fts ON public.scientific_publications USING gin (to_tsvector('english', coalesce(abstract, '')));

ALTER TABLE public.scientific_publications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access for scientific publications"
    ON public.scientific_publications FOR SELECT
    TO authenticated, anon
    USING (true);

CREATE TABLE IF NOT EXISTS public.clinical_trials_catalog (
    nct_id TEXT PRIMARY KEY, -- e.g. 'NCT03192735'
    source_id TEXT NOT NULL REFERENCES public.scientific_sources(id) ON DELETE RESTRICT,
    brief_title TEXT NOT NULL,
    official_title TEXT,
    overall_status TEXT NOT NULL,
    start_date DATE,
    completion_date DATE,
    conditions TEXT[] NOT NULL DEFAULT '{}',
    interventions TEXT[] NOT NULL DEFAULT '{}',
    study_type TEXT,
    allocation TEXT,
    masking TEXT,
    eligibility_criteria TEXT,
    primary_outcomes TEXT[] NOT NULL DEFAULT '{}',
    results_url TEXT,
    source_url TEXT NOT NULL,
    raw_payload JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_clinical_trials_status ON public.clinical_trials_catalog (overall_status);
CREATE INDEX IF NOT EXISTS idx_clinical_trials_conditions ON public.clinical_trials_catalog USING gin (conditions);
CREATE INDEX IF NOT EXISTS idx_clinical_trials_interventions ON public.clinical_trials_catalog USING gin (interventions);

ALTER TABLE public.clinical_trials_catalog ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access for clinical trials catalog"
    ON public.clinical_trials_catalog FOR SELECT
    TO authenticated, anon
    USING (true);

-- ------------------------------------------------------------------------------
-- 3. Botanical Taxa, Vernacular Synonyms & Herbs
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.botanical_taxa (
    id TEXT PRIMARY KEY, -- Canonical slug, e.g. 'withania_somnifera'
    scientific_name TEXT NOT NULL UNIQUE,
    canonical_name TEXT NOT NULL,
    genus TEXT NOT NULL,
    family TEXT NOT NULL,
    taxon_rank TEXT NOT NULL DEFAULT 'species',
    taxonomic_status TEXT NOT NULL DEFAULT 'accepted',
    gbif_taxon_key INT,
    wfo_id TEXT,
    powo_id TEXT,
    confidence_score NUMERIC(4,2) DEFAULT 100.0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_botanical_taxa_family ON public.botanical_taxa (family);
CREATE INDEX IF NOT EXISTS idx_botanical_taxa_gbif ON public.botanical_taxa (gbif_taxon_key);

ALTER TABLE public.botanical_taxa ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access for botanical taxa"
    ON public.botanical_taxa FOR SELECT
    TO authenticated, anon
    USING (true);

CREATE TABLE IF NOT EXISTS public.botanical_synonyms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    taxon_id TEXT NOT NULL REFERENCES public.botanical_taxa(id) ON DELETE CASCADE,
    synonym_name TEXT NOT NULL,
    language_or_system TEXT NOT NULL CHECK (
        language_or_system IN ('sanskrit', 'hindi', 'english', 'latin_synonym', 'tamil', 'telugu', 'arabic', 'persian', 'chinese')
    ),
    is_primary BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_botanical_synonyms_lookup ON public.botanical_synonyms (synonym_name);
CREATE INDEX IF NOT EXISTS idx_botanical_synonyms_taxon ON public.botanical_synonyms (taxon_id);

ALTER TABLE public.botanical_synonyms ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access for botanical synonyms"
    ON public.botanical_synonyms FOR SELECT
    TO authenticated, anon
    USING (true);

CREATE TABLE IF NOT EXISTS public.botanical_herbs (
    id TEXT PRIMARY KEY REFERENCES public.botanical_taxa(id) ON DELETE RESTRICT,
    ayurvedic_name TEXT NOT NULL,
    traditional_systems TEXT[] NOT NULL DEFAULT '{"Ayurveda"}',
    parts_used TEXT[] NOT NULL DEFAULT '{}',
    ayurvedic_energetics JSONB NOT NULL DEFAULT '{
        "rasa": [],
        "guna": [],
        "virya": null,
        "vipaka": null,
        "prabhava": null,
        "dosha_karma": []
    }'::jsonb,
    traditional_indications TEXT[] NOT NULL DEFAULT '{}',
    standard_dosage_range TEXT,
    contraindications TEXT[] NOT NULL DEFAULT '{}',
    safety_summary TEXT,
    evidence_score NUMERIC(3,2) NOT NULL DEFAULT 0.85,
    monograph_source_id TEXT REFERENCES public.scientific_sources(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.botanical_herbs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access for botanical herbs"
    ON public.botanical_herbs FOR SELECT
    TO authenticated, anon
    USING (true);

-- ------------------------------------------------------------------------------
-- 4. Chemical Compounds, Plant Junctions & Targets
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.chemical_compounds (
    id TEXT PRIMARY KEY, -- Slug or canonical name e.g. 'withaferin_a', 'curcumin'
    compound_name TEXT NOT NULL,
    iupac_name TEXT,
    pubchem_cid INT UNIQUE,
    chebi_id TEXT,
    chembl_id TEXT,
    molecular_formula TEXT,
    molecular_weight NUMERIC(8,3) CHECK (molecular_weight > 0),
    canonical_smiles TEXT,
    inchikey TEXT UNIQUE,
    pharmacological_classes TEXT[] NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_chemical_compounds_cid ON public.chemical_compounds (pubchem_cid);
CREATE INDEX IF NOT EXISTS idx_chemical_compounds_inchikey ON public.chemical_compounds (inchikey);

ALTER TABLE public.chemical_compounds ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access for chemical compounds"
    ON public.chemical_compounds FOR SELECT
    TO authenticated, anon
    USING (true);

CREATE TABLE IF NOT EXISTS public.plant_compounds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    taxon_id TEXT NOT NULL REFERENCES public.botanical_taxa(id) ON DELETE CASCADE,
    compound_id TEXT NOT NULL REFERENCES public.chemical_compounds(id) ON DELETE CASCADE,
    plant_part TEXT NOT NULL DEFAULT 'whole_plant',
    concentration_range TEXT,
    lotus_evidence_id TEXT,
    evidence_pmid TEXT,
    evidence_doi TEXT,
    provenance_source_id TEXT NOT NULL REFERENCES public.scientific_sources(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    UNIQUE(taxon_id, compound_id, plant_part)
);

CREATE INDEX IF NOT EXISTS idx_plant_compounds_taxon ON public.plant_compounds (taxon_id);
CREATE INDEX IF NOT EXISTS idx_plant_compounds_compound ON public.plant_compounds (compound_id);

ALTER TABLE public.plant_compounds ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access for plant compounds"
    ON public.plant_compounds FOR SELECT
    TO authenticated, anon
    USING (true);

CREATE TABLE IF NOT EXISTS public.compound_targets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    compound_id TEXT NOT NULL REFERENCES public.chemical_compounds(id) ON DELETE CASCADE,
    target_name TEXT NOT NULL,
    uniprot_id TEXT,
    organism TEXT NOT NULL DEFAULT 'Homo sapiens',
    affinity_type TEXT CHECK (affinity_type IN ('Ki', 'Kd', 'IC50', 'EC50', 'Potency', 'unspecified')),
    affinity_value NUMERIC(10,3),
    affinity_unit TEXT,
    evidence_doi TEXT,
    source_id TEXT NOT NULL REFERENCES public.scientific_sources(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_compound_targets_compound ON public.compound_targets (compound_id);
CREATE INDEX IF NOT EXISTS idx_compound_targets_uniprot ON public.compound_targets (uniprot_id);

ALTER TABLE public.compound_targets ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access for compound targets"
    ON public.compound_targets FOR SELECT
    TO authenticated, anon
    USING (true);

-- ------------------------------------------------------------------------------
-- 5. Nutrients Catalog, Reference Intakes & Food Composition
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.nutrients_catalog (
    id TEXT PRIMARY KEY, -- e.g. 'nut_zinc', 'nut_vitamin_d', 'nut_magnesium'
    name TEXT NOT NULL UNIQUE,
    category TEXT NOT NULL CHECK (
        category IN ('macronutrient', 'vitamin', 'mineral', 'fatty_acid', 'amino_acid', 'phytonutrient', 'water_electrolyte')
    ),
    standard_unit TEXT NOT NULL CHECK (standard_unit IN ('g', 'mg', 'mcg', 'ug', 'IU', 'kcal', 'kJ')),
    physiological_functions TEXT[] NOT NULL DEFAULT '{}',
    deficiency_symptoms TEXT[] NOT NULL DEFAULT '{}',
    toxicity_symptoms TEXT[] NOT NULL DEFAULT '{}',
    food_sources TEXT[] NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.nutrients_catalog ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access for nutrients catalog"
    ON public.nutrients_catalog FOR SELECT
    TO authenticated, anon
    USING (true);

CREATE TABLE IF NOT EXISTS public.nutrient_reference_intakes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nutrient_id TEXT NOT NULL REFERENCES public.nutrients_catalog(id) ON DELETE CASCADE,
    jurisdiction TEXT NOT NULL CHECK (jurisdiction IN ('US_NIH_ODS', 'ICMR_NIN_INDIA', 'EFSA_EUROPE', 'WHO_FAO')),
    population_group TEXT NOT NULL,
    age_min_years NUMERIC(4,1) NOT NULL,
    age_max_years NUMERIC(4,1) NOT NULL,
    sex TEXT NOT NULL CHECK (sex IN ('male', 'female', 'all', 'pregnancy', 'lactation')),
    rda_or_ai_type TEXT NOT NULL CHECK (rda_or_ai_type IN ('RDA', 'AI')),
    rda_or_ai_value NUMERIC(8,2) NOT NULL CHECK (rda_or_ai_value >= 0),
    upper_tolerable_limit_ul NUMERIC(8,2) CHECK (upper_tolerable_limit_ul >= 0),
    unit TEXT NOT NULL,
    source_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_nri_lookup ON public.nutrient_reference_intakes (nutrient_id, jurisdiction, sex);

ALTER TABLE public.nutrient_reference_intakes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access for nutrient reference intakes"
    ON public.nutrient_reference_intakes FOR SELECT
    TO authenticated, anon
    USING (true);

CREATE TABLE IF NOT EXISTS public.food_composition_items (
    id TEXT PRIMARY KEY, -- e.g. 'fdc:170417', 'off:737628064502', 'fao:density_milk'
    source_id TEXT NOT NULL REFERENCES public.scientific_sources(id) ON DELETE RESTRICT,
    food_name TEXT NOT NULL,
    food_category TEXT NOT NULL,
    data_origin TEXT NOT NULL CHECK (data_origin IN ('USDA_FDC', 'FAO_INFOODS', 'OPEN_FOOD_FACTS', 'FSSAI_IFCT')),
    serving_size_g NUMERIC(8,2) NOT NULL DEFAULT 100.0 CHECK (serving_size_g > 0),
    serving_size_unit TEXT NOT NULL DEFAULT 'g',
    mass_density_g_ml NUMERIC(5,3), -- For volume conversion per FAO Density Database
    energy_kcal NUMERIC(8,2) NOT NULL DEFAULT 0.0 CHECK (energy_kcal >= 0),
    protein_g NUMERIC(8,2) NOT NULL DEFAULT 0.0 CHECK (protein_g >= 0),
    carbohydrate_g NUMERIC(8,2) NOT NULL DEFAULT 0.0 CHECK (carbohydrate_g >= 0),
    total_fat_g NUMERIC(8,2) NOT NULL DEFAULT 0.0 CHECK (total_fat_g >= 0),
    dietary_fiber_g NUMERIC(8,2) NOT NULL DEFAULT 0.0 CHECK (dietary_fiber_g >= 0),
    phytate_mg NUMERIC(8,2), -- FAO PhyFoodComp
    phytate_to_zinc_molar_ratio NUMERIC(5,2),
    phytate_to_iron_molar_ratio NUMERIC(5,2),
    micronutrients JSONB NOT NULL DEFAULT '{}'::jsonb,
    is_verified BOOLEAN NOT NULL DEFAULT true,
    license TEXT NOT NULL DEFAULT 'Public Domain / ODbL / Open Access',
    source_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_food_comp_name_fts ON public.food_composition_items USING gin (to_tsvector('english', food_name));
CREATE INDEX IF NOT EXISTS idx_food_comp_category ON public.food_composition_items (food_category);
CREATE INDEX IF NOT EXISTS idx_food_comp_origin ON public.food_composition_items (data_origin);

ALTER TABLE public.food_composition_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access for food composition items"
    ON public.food_composition_items FOR SELECT
    TO authenticated, anon
    USING (true);

-- ------------------------------------------------------------------------------
-- 6. Safety Evidence & Hepatotoxicity (LiverTox / DailyMed)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.safety_evidence_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_id TEXT NOT NULL REFERENCES public.scientific_sources(id) ON DELETE RESTRICT,
    agent_name TEXT NOT NULL,
    agent_type TEXT NOT NULL CHECK (agent_type IN ('herbal_botanical', 'dietary_supplement', 'pharmaceutical_medication')),
    livertox_likelihood_score TEXT CHECK (
        livertox_likelihood_score IN (
            'Category A: Well known cause of clinically apparent liver injury',
            'Category B: Highly likely cause of clinically apparent liver injury',
            'Category C: Probable cause of clinically apparent liver injury',
            'Category D: Possible cause of clinically apparent liver injury',
            'Category E: Unlikely cause of clinically apparent liver injury',
            'Category X: Unknown / Insufficient data'
        )
    ),
    injury_pattern TEXT,
    fda_boxed_warning BOOLEAN NOT NULL DEFAULT false,
    adverse_reactions TEXT[] NOT NULL DEFAULT '{}',
    contraindications TEXT[] NOT NULL DEFAULT '{}',
    drug_interactions TEXT[] NOT NULL DEFAULT '{}',
    risk_summary TEXT NOT NULL,
    evidence_pmid TEXT,
    evidence_doi TEXT,
    source_url TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_safety_agent_name ON public.safety_evidence_records (agent_name);
CREATE INDEX IF NOT EXISTS idx_safety_score ON public.safety_evidence_records (livertox_likelihood_score);

ALTER TABLE public.safety_evidence_records ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access for safety evidence records"
    ON public.safety_evidence_records FOR SELECT
    TO authenticated, anon
    USING (true);

-- ------------------------------------------------------------------------------
-- 7. Genetics & Genomic Variations (GWAS Catalog & ClinVar)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.genetics_records (
    id TEXT PRIMARY KEY, -- e.g. 'rs1801133_mthfr'
    rs_id TEXT NOT NULL,
    gene_symbol TEXT NOT NULL,
    chromosome TEXT,
    position_grch38 BIGINT,
    clinical_significance TEXT CHECK (
        clinical_significance IN (
            'Pathogenic',
            'Likely pathogenic',
            'Uncertain significance',
            'Likely benign',
            'Benign',
            'Risk factor',
            'Association / Metabolic modulation'
        )
    ),
    phenotype_or_trait TEXT NOT NULL,
    risk_allele TEXT,
    odds_ratio NUMERIC(6,3),
    p_value NUMERIC(10,9),
    nutritional_actionability TEXT,
    gwas_catalog_accession TEXT,
    clinvar_variation_id TEXT,
    pubmed_id TEXT,
    source_id TEXT NOT NULL REFERENCES public.scientific_sources(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_genetics_rsid ON public.genetics_records (rs_id);
CREATE INDEX IF NOT EXISTS idx_genetics_gene ON public.genetics_records (gene_symbol);

ALTER TABLE public.genetics_records ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access for genetics records"
    ON public.genetics_records FOR SELECT
    TO authenticated, anon
    USING (true);

-- ------------------------------------------------------------------------------
-- 8. Physical Activities & MET Values
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.physical_activities (
    activity_code TEXT PRIMARY KEY, -- 5-digit code per Ainsworth et al.
    heading TEXT NOT NULL,
    specific_motion TEXT NOT NULL,
    met_value NUMERIC(4,2) NOT NULL CHECK (met_value > 0),
    intensity_category TEXT NOT NULL CHECK (intensity_category IN ('sedentary', 'light', 'moderate', 'vigorous')),
    source_reference TEXT NOT NULL DEFAULT 'Compendium of Physical Activities',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_physical_activities_heading ON public.physical_activities (heading);
CREATE INDEX IF NOT EXISTS idx_physical_activities_intensity ON public.physical_activities (intensity_category);

ALTER TABLE public.physical_activities ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access for physical activities"
    ON public.physical_activities FOR SELECT
    TO authenticated, anon
    USING (true);

-- ------------------------------------------------------------------------------
-- 9. Scientific Document Chunks (Semantic Vector Catalog)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.scientific_document_chunks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_id TEXT NOT NULL REFERENCES public.scientific_sources(id) ON DELETE RESTRICT,
    document_title TEXT NOT NULL,
    document_path TEXT NOT NULL,
    sha256_hash TEXT NOT NULL,
    page_number INT,
    section_heading TEXT,
    chunk_index INT NOT NULL DEFAULT 0,
    chunk_content TEXT NOT NULL,
    embedding extensions.vector(1536),
    license TEXT NOT NULL,
    source_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_sci_chunks_source ON public.scientific_document_chunks (source_id);
CREATE INDEX IF NOT EXISTS idx_sci_chunks_hash ON public.scientific_document_chunks (sha256_hash);
CREATE INDEX IF NOT EXISTS idx_sci_chunks_fts ON public.scientific_document_chunks USING gin (to_tsvector('english', chunk_content));
CREATE INDEX IF NOT EXISTS idx_sci_chunks_hnsw ON public.scientific_document_chunks 
    USING hnsw (embedding extensions.vector_cosine_ops) 
    WITH (m = 16, ef_construction = 64);

ALTER TABLE public.scientific_document_chunks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access for scientific document chunks"
    ON public.scientific_document_chunks FOR SELECT
    TO authenticated, anon
    USING (true);

