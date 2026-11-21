-- ==============================================================================
-- Nutrient Earth — Evidence Integrity, Scientific Verification & Continuous Update Engine
-- Migration: 20261121000002_evidence_integrity_and_verification_engine.sql
--
-- Provisions:
-- 1. Universal 25-Domain Research Taxonomy & Research Questions (PICO/PECO)
-- 2. Publication Provenance, Versions, Retractions & Corrections
-- 3. Design-Specific Methodological Assessments (RoB 2, ROBINS-I, AMSTAR 2, SYRCLE, GRADE)
-- 4. Human Evidence vs Preclinical Mechanism Separation
-- 5. Canonical Claims & Opposing Evidence Graph
-- 6. Publishing Gate State Machine & High-Impact Human Review Log
-- 7. Continuous Knowledge Change Propagation & Recommendation Dependencies
-- 8. 11-Part Editorial Direct-Answer Structure
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Universal 25-Domain Research Taxonomy
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.research_taxonomies (
    id TEXT PRIMARY KEY, -- e.g. 'domain_01_nutrition', 'domain_04_cookware', 'domain_18_cancer'
    domain_number INT NOT NULL UNIQUE CHECK (domain_number BETWEEN 1 AND 25),
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    subdomains TEXT[] NOT NULL DEFAULT '{}',
    exposure_categories TEXT[] NOT NULL DEFAULT '{}',
    biological_targets TEXT[] NOT NULL DEFAULT '{}',
    primary_methodologies TEXT[] NOT NULL DEFAULT '{}',
    update_cadence TEXT NOT NULL DEFAULT 'daily', -- 'daily', 'weekly', 'biweekly'
    source_allowlist TEXT[] NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Seed the canonical 25 domains
INSERT INTO public.research_taxonomies (domain_number, id, name, description, subdomains, primary_methodologies)
VALUES
(1, 'domain_01_nutrition', 'Nutrition & Macronutrient Kinetics', 'Protein kinetics, carbohydrate digestion, lipid metabolism, energy balance', ARRAY['protein_kinetics', 'glycemic_index', 'lipid_transport', 'metabolic_adaptation'], ARRAY['RoB 2', 'AMSTAR 2', 'GRADE']),
(2, 'domain_02_micronutrients', 'Micronutrients & Phytochemicals', 'Vitamins, minerals, polyphenols, bioavailability, chelation', ARRAY['magnesium_chelates', 'vitamin_d_endocrine', 'iron_absorption', 'flavonoid_metabolites'], ARRAY['RoB 2', 'GRADE']),
(3, 'domain_03_food_processing', 'Food Processing & Culinary Physics', 'Thermal kinetics, boiling vs steaming, antinutrient reduction, sprouting', ARRAY['phytate_degradation', 'oxalate_leaching', 'protein_denaturation', 'maillard_reaction'], ARRAY['GRADE', 'Controlled Trial']),
(4, 'domain_04_cookware', 'Cookware, Utensils & Food Contact Materials', 'Cast iron, stainless steel, non-stick PTFE/PFAS, copper, clay, heavy metal leaching', ARRAY['iron_migration', 'ptfe_pyrolysis', 'acidic_reactivity', 'earthenware_porosity'], ARRAY['Food Toxicology', 'GRADE']),
(5, 'domain_05_plastics', 'Plastics, Microplastics & Nanoplastics', 'Cutting boards, beverage containers, polymer shedding, cellular internalization', ARRAY['polypropylene_fragmentation', 'nanoplastic_gut_barrier', 'dietary_ingestion_rate'], ARRAY['Environmental Assay', 'ROBINS-I']),
(6, 'domain_06_endocrine_disruptors', 'Endocrine Disruptors & Everyday Chemicals', 'Phthalates, bisphenols (BPA/BPS), parabens, pesticide residues, hormone receptors', ARRAY['bpa_leaching', 'phthalate_adipogenesis', 'pesticide_dietary_intake'], ARRAY['ROBINS-I', 'GRADE']),
(7, 'domain_07_environmental', 'Environmental Exposures, Air Quality & Particulates', 'Particulate matter (PM2.5/PM10), ozone, indoor air quality, exercise thresholds', ARRAY['pm25_vascular_inflammation', 'aqi_respiratory_strain', 'voc_indoor_ventilation'], ARRAY['ROBINS-I', 'Epidemiology']),
(8, 'domain_08_heavy_metals', 'Heavy Metals & Water Toxicology', 'Lead, arsenic, cadmium, mercury in drinking water, spices, and cacao', ARRAY['lead_neurotoxicity', 'arsenic_rice_uptake', 'cadmium_renal_accumulation'], ARRAY['Toxicology Assay', 'ROBINS-I']),
(9, 'domain_09_light_photobiology', 'Light, Photobiology & Circadian Entrainment', 'Morning natural sunlight, melanopsin, blue photons (480nm), retinal ganglion cells', ARRAY['iprgc_activation', 'melatonin_suppression', 'car_cortisol_awakening'], ARRAY['RoB 2', 'Chronobiology Trial']),
(10, 'domain_10_sleep_somnology', 'Sleep Architecture & Somnology', 'Slow-wave sleep (SWS), REM, adenosine clearance, glymphatic wash, sleep hygiene', ARRAY['adenosine_receptor_kinetics', 'glymphatic_clearance', 'core_body_temperature'], ARRAY['RoB 2', 'Polysomnography GRADE']),
(11, 'domain_11_exercise_physiology', 'Exercise Physiology & Skeletal Muscle Adaptation', 'Hypertrophy, mitochondrial biogenesis, soleus pushups, GLUT4, Zone 2 endurance', ARRAY['glut4_translocation', 'ampk_phosphorylation', 'soleus_oxidative_metabolism'], ARRAY['RoB 2', 'AMSTAR 2']),
(12, 'domain_12_gym_biomechanics', 'Gym Equipment, Biomechanics & Injury Prevention', 'Resistance profiles, joint moment arms, eccentric loading, spinal shear forces', ARRAY['lumbar_shear', 'knee_flexion_torque', 'tendon_remodeling'], ARRAY['Biomechanics', 'ROBINS-I']),
(13, 'domain_13_clothing_textiles', 'Clothing, Textiles & Dermal Absorption', 'Synthetic fabrics, microplastic shedding, azo dyes, flame retardants, skin friction', ARRAY['polyester_microfiber', 'azo_dye_transdermal', 'thermoregulatory_breathability'], ARRAY['Dermal Toxicology', 'ROBINS-I']),
(14, 'domain_14_footwear_gait', 'Footwear, Gait & Musculoskeletal Alignment', 'Toe spring, drop, barefoot mechanics, plantar fascia, proprioceptive feedback', ARRAY['plantar_intrinsic_muscle', 'arch_stiffness', 'cadence_knee_load'], ARRAY['RoB 2', 'Gait Kinematics']),
(15, 'domain_15_jewellery_metals', 'Jewellery, Metals & Cutaneous Sensitization', 'Nickel contact dermatitis, cobalt, chromium, piercing hygiene, silver oxidation', ARRAY['nickel_allergic_dermatitis', 'sweat_acid_corrosion', 'hypoallergenic_alloys'], ARRAY['Dermatology Guidelines', 'ROBINS-I']),
(16, 'domain_16_bowel_health', 'Bowel Health, Motility & Stool Biomarkers', 'Bristol stool chart, transit time, colonic fermentation, SCFAs, bile acid binding', ARRAY['transit_time_isabgol', 'scfa_butyrate_colonocytes', 'osmotic_motility'], ARRAY['RoB 2', 'GRADE']),
(17, 'domain_17_renal_hydration', 'Renal Function, Hydration & Urination Dynamics', 'Urine specific gravity, electrolyte clearance, GFR, nephron load, diurnal volume', ARRAY['osmolality_markers', 'diurnal_aldosterone_vasopressin', 'electrolyte_balance'], ARRAY['Clinical Chemistry', 'GRADE']),
(18, 'domain_18_cancer_research', 'Cancer Biology, Carcinogenesis & Epidemiology', 'IARC hazard tiers, human epidemiological evidence, mutagenicity, lifestyle risk', ARRAY['iarc_group_1_vs_2b', 'acrylamide_dietary_dose', 'nitrosamine_formation', 'colorectal_fiber'], ARRAY['IARC Monograph', 'GRADE', 'ROBINS-I']),
(19, 'domain_19_dna_epigenetics', 'DNA Integrity, Epigenetics & Telomere Biology', 'Base oxidation (8-OHdG), DNA repair, methylation, histone acetylation, telomerase', ARRAY['oxidative_dna_damage', 'parp_dna_repair', 'folate_one_carbon_metabolism'], ARRAY['Mechanistic Assay', 'Human Trial']),
(20, 'domain_20_organ_systems', 'Organ Systems (Cardiovascular, Hepatic, Metabolic)', 'Endothelial flow-mediated dilation, hepatic steatosis, insulin sensitivity, ApoB', ARRAY['flow_mediated_dilation', 'hepatic_de_novo_lipogenesis', 'apob_clearance'], ARRAY['RoB 2', 'AMSTAR 2', 'GRADE']),
(21, 'domain_21_pharmacokinetics', 'Pharmaceutical Pharmacokinetics & Supplements', 'Half-life, bioavailability, CYP450 metabolism, supplement-drug interactions', ARRAY['cyp3a4_inhibition', 'first_pass_clearance', 'chelate_dissociation_kinetics'], ARRAY['Pharmacokinetics', 'RoB 2']),
(22, 'domain_22_traditional_ayush', 'Traditional, Ancestral & AYUSH Living Practices', 'Ritucharya, Dinacharya, Agni, millets (Ragi/Bajra), fermentation, earthen cookware', ARRAY['ayurgomics_prakriti', 'ragi_calcium_bioavailability', 'kanji_lactic_fermentation'], ARRAY['AYUSH Guidelines', 'Integrative Clinical Review']),
(23, 'domain_23_oral_health', 'Oral Microbiome & Dentition Health', 'Nitric oxide salivary pathway, Streptococcus mutans, fluoride vs hydroxyapatite', ARRAY['salivary_nitrate_reduction', 'enamel_remineralization', 'oral_periodontal_axis'], ARRAY['RoB 2', 'GRADE']),
(24, 'domain_24_ergonomics', 'Occupational & Household Ergonomics', 'Sedentary interruption, sit-stand desks, monitor gaze angle, eye strain (20-20-20)', ARRAY['postural_muscle_activity', 'ciliary_muscle_fatigue', 'lumbar_disc_pressure'], ARRAY['Ergonomics Trial', 'ROBINS-I']),
(25, 'domain_25_longevity', 'Longevity, Cellular Senescence & Autophagy', 'Sirtuins, NAD+ flux, intermittent fasting, rapamycin mechanisms, healthspan', ARRAY['nad_salvage_pathway', 'autophagy_flux', 'senescent_sasp_reduction'], ARRAY['RoB 2', 'Translational Biology', 'GRADE'])
ON CONFLICT (domain_number) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    subdomains = EXCLUDED.subdomains,
    primary_methodologies = EXCLUDED.primary_methodologies;

-- ------------------------------------------------------------------------------
-- 2. Structured Research Questions (PICO/PECO)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.research_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    taxonomy_domain_id TEXT NOT NULL REFERENCES public.research_taxonomies(id) ON DELETE RESTRICT,
    canonical_question TEXT NOT NULL,
    population_type TEXT NOT NULL DEFAULT 'general_adults', -- 'general_adults', 'athletes', 'older_adults', 'in_vitro'
    exposure_or_intervention TEXT NOT NULL,
    comparator TEXT,
    primary_outcome_measured TEXT NOT NULL,
    study_designs_targeted TEXT[] NOT NULL DEFAULT '{"randomized_controlled_trial", "systematic_review", "cohort_study"}',
    search_query_strings JSONB NOT NULL DEFAULT '{}'::jsonb, -- queries for PubMed, OpenAlex, Europe PMC
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'paused', 'archived')),
    last_searched_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_research_questions_domain ON public.research_questions(taxonomy_domain_id);

-- ------------------------------------------------------------------------------
-- 3. Publication Provenance, Versions & Retraction Engine
-- ------------------------------------------------------------------------------
-- Extend public.scientific_publications with retraction/correction tracking
ALTER TABLE public.scientific_publications
    ADD COLUMN IF NOT EXISTS is_retracted BOOLEAN NOT NULL DEFAULT false,
    ADD COLUMN IF NOT EXISTS retraction_date TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS retraction_reason TEXT,
    ADD COLUMN IF NOT EXISTS retraction_notice_url TEXT,
    ADD COLUMN IF NOT EXISTS is_corrected BOOLEAN NOT NULL DEFAULT false,
    ADD COLUMN IF NOT EXISTS correction_notice_doi TEXT,
    ADD COLUMN IF NOT EXISTS expression_of_concern BOOLEAN NOT NULL DEFAULT false,
    ADD COLUMN IF NOT EXISTS analysis_scope TEXT NOT NULL DEFAULT 'full_text' CHECK (analysis_scope IN ('full_text', 'abstract_only', 'preregistration_only')),
    ADD COLUMN IF NOT EXISTS publisher_name TEXT,
    ADD COLUMN IF NOT EXISTS conflict_of_interest_statement TEXT,
    ADD COLUMN IF NOT EXISTS funding_source_disclosed TEXT;

CREATE INDEX IF NOT EXISTS idx_scientific_pub_retraction ON public.scientific_publications(is_retracted) WHERE is_retracted = true;

-- ------------------------------------------------------------------------------
-- 4. Design-Specific Methodological Assessments (RoB 2, ROBINS-I, AMSTAR 2, SYRCLE)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.publication_assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    publication_id UUID NOT NULL REFERENCES public.scientific_publications(id) ON DELETE CASCADE,
    assessment_tool TEXT NOT NULL CHECK (
        assessment_tool IN ('rob_2', 'robins_i', 'amstar_2', 'robis', 'quadas_2', 'syrcle', 'expert_critique')
    ),
    -- Common Assessment Domains
    overall_risk_of_bias TEXT NOT NULL CHECK (
        overall_risk_of_bias IN ('low_risk', 'some_concerns', 'high_risk', 'critical_risk', 'unclear')
    ),
    randomization_score TEXT,      -- For RoB 2
    deviations_score TEXT,         -- For RoB 2 / ROBINS-I
    missing_data_score TEXT,       -- Missing outcome data
    measurement_score TEXT,        -- Measurement of the outcome
    selective_reporting_score TEXT,-- Selection of reported results
    confounding_score TEXT,        -- Specifically for observational (ROBINS-I)
    systematic_search_score TEXT,  -- For AMSTAR 2 / ROBIS
    animal_random_housing TEXT,    -- For SYRCLE
    assessed_by TEXT NOT NULL DEFAULT 'nutrient_earth_verifier_v2',
    assessment_notes TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_pub_assessments_pub ON public.publication_assessments(publication_id);

-- ------------------------------------------------------------------------------
-- 5. GRADE Outcome-Specific Assessments (Body of Evidence Certainty)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.evidence_assessments_grade (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question_id UUID REFERENCES public.research_questions(id) ON DELETE SET NULL,
    outcome_name TEXT NOT NULL,
    number_of_studies INT NOT NULL,
    total_participants INT,
    study_designs_included TEXT[] NOT NULL,
    -- 5 Downgrade Domains (0 = none, -1 = serious, -2 = very serious)
    risk_of_bias_downgrade INT NOT NULL DEFAULT 0 CHECK (risk_of_bias_downgrade BETWEEN -2 AND 0),
    inconsistency_downgrade INT NOT NULL DEFAULT 0 CHECK (inconsistency_downgrade BETWEEN -2 AND 0),
    indirectness_downgrade INT NOT NULL DEFAULT 0 CHECK (indirectness_downgrade BETWEEN -2 AND 0),
    imprecision_downgrade INT NOT NULL DEFAULT 0 CHECK (imprecision_downgrade BETWEEN -2 AND 0),
    publication_bias_downgrade INT NOT NULL DEFAULT 0 CHECK (publication_bias_downgrade BETWEEN -2 AND 0),
    -- 3 Upgrade Domains (+1 = large effect, +2 = very large)
    large_effect_upgrade INT NOT NULL DEFAULT 0 CHECK (large_effect_upgrade BETWEEN 0 AND 2),
    dose_response_upgrade INT NOT NULL DEFAULT 0 CHECK (dose_response_upgrade BETWEEN 0 AND 1),
    residual_confounding_upgrade INT NOT NULL DEFAULT 0 CHECK (residual_confounding_upgrade BETWEEN 0 AND 1),
    -- Final GRADE Certainty
    final_certainty TEXT NOT NULL CHECK (
        final_certainty IN ('high', 'moderate', 'low', 'very_low')
    ),
    justification_summary TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- ------------------------------------------------------------------------------
-- 6. Canonical Claims & Human vs Mechanism Separation
-- ------------------------------------------------------------------------------
-- Extend public.scientific_claims with mandatory safety classifications
ALTER TABLE public.scientific_claims
    ADD COLUMN IF NOT EXISTS claim_uid TEXT UNIQUE,
    ADD COLUMN IF NOT EXISTS evidence_tier TEXT NOT NULL DEFAULT 'human_trial' CHECK (
        evidence_tier IN (
            'human_systematic_review',
            'human_randomized_trial',
            'human_observational_cohort',
            'clinical_practice_guideline',
            'preclinical_animal_model',
            'in_vitro_cellular_assay',
            'computational_mechanistic_model',
            'traditional_empirical_treatise'
        )
    ),
    -- Mandatory Human Separation Check
    ADD COLUMN IF NOT EXISTS is_human_evidence BOOLEAN NOT NULL DEFAULT true,
    ADD COLUMN IF NOT EXISTS is_preclinical_only BOOLEAN NOT NULL DEFAULT false,
    ADD COLUMN IF NOT EXISTS cancer_hazard_distinction JSONB, -- { hazard_class, route, dose_threshold, absolute_risk_estimate }
    ADD COLUMN IF NOT EXISTS dna_damage_vs_outcome_distinction JSONB, -- { dna_mutation_observed, repair_active, clinical_disease_proven }
    ADD COLUMN IF NOT EXISTS absolute_effect_size TEXT,
    ADD COLUMN IF NOT EXISTS clinical_relevance_rating TEXT DEFAULT 'moderate', -- 'negligible', 'moderate', 'high_clinical_impact'
    ADD COLUMN IF NOT EXISTS verification_version INT NOT NULL DEFAULT 1,
    -- Publishing Gate Status
    ADD COLUMN IF NOT EXISTS publishing_status TEXT NOT NULL DEFAULT 'APPROVED' CHECK (
        publishing_status IN (
            'DISCOVERED',
            'SOURCE_VERIFIED',
            'EXTRACTED',
            'EVIDENCE_ASSESSED',
            'CLAIM_VERIFIED',
            'SAFETY_REVIEWED',
            'APPROVED',
            'PUBLISHED',
            'REJECTED',
            'WITHHELD',
            'NEEDS_HUMAN_REVIEW',
            'SUPERSEDED',
            'CORRECTED',
            'RETRACTED',
            'ARCHIVED'
        )
    ),
    ADD COLUMN IF NOT EXISTS reviewed_by TEXT DEFAULT 'autonomous_integrity_verifier',
    ADD COLUMN IF NOT EXISTS reviewed_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
    ADD COLUMN IF NOT EXISTS requires_human_signoff BOOLEAN NOT NULL DEFAULT false;

CREATE INDEX IF NOT EXISTS idx_claims_publishing_status ON public.scientific_claims(publishing_status);
CREATE INDEX IF NOT EXISTS idx_claims_evidence_tier ON public.scientific_claims(evidence_tier, is_human_evidence);

-- ------------------------------------------------------------------------------
-- 7. Publishing Gate Audit Trail & State Transitions
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.publishing_gate_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    claim_id UUID REFERENCES public.scientific_claims(id) ON DELETE CASCADE,
    article_id UUID,
    from_state TEXT NOT NULL,
    to_state TEXT NOT NULL,
    transition_reason TEXT NOT NULL,
    actor_id TEXT NOT NULL DEFAULT 'system_gatekeeper',
    gate_checks_passed JSONB NOT NULL DEFAULT '{}'::jsonb,
    is_blocked BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_gate_log_claim ON public.publishing_gate_log(claim_id);

-- ------------------------------------------------------------------------------
-- 8. Continuous Knowledge Change Propagation & Recommendation Dependencies
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.recommendation_dependencies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recommendation_identifier TEXT NOT NULL, -- e.g. 'rec_post_run_protein_timing', 'rec_cast_iron_tomatoes'
    supporting_claim_id UUID NOT NULL REFERENCES public.scientific_claims(id) ON DELETE CASCADE,
    dependency_criticality TEXT NOT NULL DEFAULT 'critical' CHECK (dependency_criticality IN ('critical', 'supportive', 'supplementary')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE TABLE IF NOT EXISTS public.knowledge_change_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type TEXT NOT NULL CHECK (
        event_type IN ('retraction_detected', 'correction_detected', 'contradiction_emerged', 'guideline_updated', 'new_meta_analysis')
    ),
    publication_id UUID REFERENCES public.scientific_publications(id) ON DELETE SET NULL,
    affected_claim_ids UUID[] NOT NULL DEFAULT '{}',
    affected_recommendations TEXT[] NOT NULL DEFAULT '{}',
    previous_state TEXT NOT NULL,
    updated_state TEXT NOT NULL,
    change_summary TEXT NOT NULL,
    requires_user_notification BOOLEAN NOT NULL DEFAULT false,
    is_reconciled BOOLEAN NOT NULL DEFAULT false,
    reconciled_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_change_events_type ON public.knowledge_change_events(event_type, is_reconciled);

-- ------------------------------------------------------------------------------
-- 9. 11-Part Editorial Direct-Answer Structure
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.scientific_editorial_articles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    claim_id UUID REFERENCES public.scientific_claims(id) ON DELETE SET NULL,
    domain_id TEXT NOT NULL REFERENCES public.research_taxonomies(id) ON DELETE RESTRICT,
    title TEXT NOT NULL,
    -- The 11 Strict Editorial Fields
    part_01_direct_answer TEXT NOT NULL,
    part_02_what_research_found TEXT NOT NULL,
    part_03_who_was_studied TEXT NOT NULL,
    part_04_exposure_or_intervention TEXT NOT NULL,
    part_05_what_result_means TEXT NOT NULL,
    part_06_what_result_does_not_prove TEXT NOT NULL,
    part_07_practical_actions TEXT[] NOT NULL DEFAULT '{}',
    part_08_evidence_certainty TEXT NOT NULL, -- 'High (RCT Meta-Analysis)', 'Moderate', 'Preliminary / In-Vitro'
    part_09_important_limitations TEXT NOT NULL,
    part_10_original_sources JSONB NOT NULL DEFAULT '[]'::jsonb, -- array of { title, authors, year, doi, pmid, url }
    part_11_last_verified_date DATE NOT NULL DEFAULT CURRENT_DATE,
    
    publishing_status TEXT NOT NULL DEFAULT 'APPROVED' CHECK (
        publishing_status IN ('DRAFT', 'NEEDS_REVIEW', 'APPROVED', 'PUBLISHED', 'ARCHIVED', 'RETRACTED')
    ),
    version INT NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_editorial_domain ON public.scientific_editorial_articles(domain_id, publishing_status);

-- ------------------------------------------------------------------------------
-- RLS Security Policies
-- ------------------------------------------------------------------------------
ALTER TABLE public.research_taxonomies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.research_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.publication_assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.evidence_assessments_grade ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.publishing_gate_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommendation_dependencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.knowledge_change_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scientific_editorial_articles ENABLE ROW LEVEL SECURITY;

-- Public read access for taxonomies, approved claims, and published editorial articles
CREATE POLICY "Public read for research taxonomies"
    ON public.research_taxonomies FOR SELECT TO authenticated, anon USING (true);

CREATE POLICY "Public read for published editorial articles"
    ON public.scientific_editorial_articles FOR SELECT TO authenticated, anon
    USING (publishing_status = 'PUBLISHED');

CREATE POLICY "Public read for publication assessments"
    ON public.publication_assessments FOR SELECT TO authenticated, anon USING (true);

CREATE POLICY "Public read for grade assessments"
    ON public.evidence_assessments_grade FOR SELECT TO authenticated, anon USING (true);

-- Service role full access for workers and verifiers
CREATE POLICY "Service role full access for publishing gate"
    ON public.publishing_gate_log FOR ALL TO service_role USING (true);

CREATE POLICY "Service role full access for knowledge change events"
    ON public.knowledge_change_events FOR ALL TO service_role USING (true);

CREATE POLICY "Service role full access for editorial articles"
    ON public.scientific_editorial_articles FOR ALL TO service_role USING (true);
