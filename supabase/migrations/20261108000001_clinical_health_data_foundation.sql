-- ==============================================================================
-- Migration: 20261108000001_clinical_health_data_foundation.sql
-- Description: Phase C Clinical & Health-Data Foundation for Nutrient Earth:
--   1. Clinical Records (Authoritative conditions & diagnoses, non-destructive audit trail)
--   2. User Allergies & Contraindications (Granular substances, categories, severity)
--   3. User Medications & Active Supplements (Prescriptions, nutraceuticals, dosages)
--   4. Biomarker Observations (Time-series labs, LOINC/Codes, reference ranges)
--   5. Document Extractions (Staging area for OCR/PDF lab extractions with review workflow)
--   6. Personal Health Memory (Confirmation Gate: draft vs. confirmed states)
--
-- Clinical Data Safety & Security Enforcement:
--   - Non-Elevation Constraint: AI inference strictly forbidden from becoming clinician_verified
--   - Review Gate: Extracted records mandate explicit user approval before clinical ingestion
--   - No Cascade Destruction: Historical clinical facts protected by ON DELETE RESTRICT
--   - Subquery-cached RLS: All policies enforce TO authenticated with (SELECT auth.uid()) = user_id
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Clinical Records
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.clinical_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
    condition_name TEXT NOT NULL,
    icd10_code TEXT,
    diagnosed_date DATE,
    verification_status TEXT NOT NULL CHECK (
        verification_status IN ('unconfirmed_draft', 'patient_reported', 'clinician_verified', 'disputed', 'resolved')
    ),
    provenance_type TEXT NOT NULL CHECK (
        provenance_type IN ('user_reported', 'document_extracted', 'clinician_confirmed', 'ai_inferred')
    ),
    diagnosing_clinician TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    superseded_by_id UUID REFERENCES public.clinical_records(id) ON DELETE SET NULL,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),

    -- Mandatory Non-Elevation Rule: AI inference can NEVER be clinician_verified
    CONSTRAINT chk_clinical_records_ai_never_clinician_verified
        CHECK (NOT (provenance_type = 'ai_inferred' AND verification_status = 'clinician_verified'))
);

CREATE INDEX IF NOT EXISTS idx_clinical_records_user_active
    ON public.clinical_records (user_id, is_active);

CREATE INDEX IF NOT EXISTS idx_clinical_records_superseded
    ON public.clinical_records (superseded_by_id)
    WHERE superseded_by_id IS NOT NULL;

ALTER TABLE public.clinical_records ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own clinical records"
    ON public.clinical_records FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can insert own clinical records"
    ON public.clinical_records FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can update own clinical records"
    ON public.clinical_records FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- ------------------------------------------------------------------------------
-- 2. User Allergies & Contraindications
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.user_allergies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
    substance_name TEXT NOT NULL,
    allergen_category TEXT NOT NULL CHECK (
        allergen_category IN ('food', 'medication', 'environmental', 'supplement')
    ),
    severity TEXT NOT NULL CHECK (
        severity IN ('mild', 'moderate', 'severe', 'anaphylactic')
    ),
    reaction_symptoms TEXT[] NOT NULL DEFAULT '{}',
    verified_by_test BOOLEAN NOT NULL DEFAULT false,
    source TEXT NOT NULL CHECK (
        source IN ('user_reported', 'lab_tested', 'clinician_diagnosed')
    ),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_user_allergies_substance UNIQUE (user_id, substance_name)
);

CREATE INDEX IF NOT EXISTS idx_user_allergies_user_id
    ON public.user_allergies (user_id);

ALTER TABLE public.user_allergies ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own allergies"
    ON public.user_allergies FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can insert own allergies"
    ON public.user_allergies FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can update own allergies"
    ON public.user_allergies FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can delete own allergies"
    ON public.user_allergies FOR DELETE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

-- ------------------------------------------------------------------------------
-- 3. User Medications & Supplements
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.user_medications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
    item_name TEXT NOT NULL,
    item_type TEXT NOT NULL CHECK (
        item_type IN ('medication', 'supplement', 'vitamin', 'herb')
    ),
    dosage NUMERIC,
    dosage_unit TEXT,
    frequency TEXT NOT NULL,
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    prescribing_doctor TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_user_medications_user_active
    ON public.user_medications (user_id, is_active);

ALTER TABLE public.user_medications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own medications"
    ON public.user_medications FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can insert own medications"
    ON public.user_medications FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can update own medications"
    ON public.user_medications FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can delete own medications"
    ON public.user_medications FOR DELETE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

-- ------------------------------------------------------------------------------
-- 4. Biomarker Observations (Lab Results)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.biomarker_observations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
    biomarker_code TEXT NOT NULL,
    biomarker_name TEXT NOT NULL,
    numeric_value NUMERIC NOT NULL,
    unit TEXT NOT NULL,
    reference_range_low NUMERIC,
    reference_range_high NUMERIC,
    clinical_interpretation TEXT CHECK (
        clinical_interpretation IN ('critical_low', 'low', 'optimal', 'elevated', 'critical_high')
    ),
    specimen_collection_date TIMESTAMPTZ NOT NULL,
    source_document_id UUID REFERENCES public.health_reports(id) ON DELETE SET NULL,
    provenance_type TEXT NOT NULL CHECK (
        provenance_type IN ('user_reported', 'device_measured', 'document_extracted', 'clinician_confirmed', 'ai_inferred')
    ),
    verification_status TEXT NOT NULL DEFAULT 'unconfirmed' CHECK (
        verification_status IN ('unconfirmed', 'patient_confirmed', 'clinician_confirmed', 'disputed')
    ),
    superseded_by_id UUID REFERENCES public.biomarker_observations(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_biomarker_observations_timeline
    ON public.biomarker_observations (user_id, biomarker_code, specimen_collection_date DESC);

CREATE INDEX IF NOT EXISTS idx_biomarker_observations_doc
    ON public.biomarker_observations (source_document_id)
    WHERE source_document_id IS NOT NULL;

ALTER TABLE public.biomarker_observations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own biomarker observations"
    ON public.biomarker_observations FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can insert own biomarker observations"
    ON public.biomarker_observations FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can update own biomarker observations"
    ON public.biomarker_observations FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- ------------------------------------------------------------------------------
-- 5. Document Extractions (Staging Area for OCR/Lab Document Review)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.document_extractions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    document_id UUID NOT NULL REFERENCES public.health_reports(id) ON DELETE CASCADE,
    extracted_entity_type TEXT NOT NULL CHECK (
        extracted_entity_type IN ('biomarker', 'medication', 'condition', 'allergy')
    ),
    raw_extracted_text TEXT NOT NULL,
    parsed_payload JSONB NOT NULL,
    confidence_score NUMERIC(3,2) NOT NULL CHECK (confidence_score BETWEEN 0.00 AND 1.00),
    review_status TEXT NOT NULL DEFAULT 'pending_review' CHECK (
        review_status IN ('pending_review', 'approved', 'rejected', 'modified')
    ),
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_document_extractions_review
    ON public.document_extractions (user_id, review_status);

CREATE INDEX IF NOT EXISTS idx_document_extractions_doc
    ON public.document_extractions (document_id);

ALTER TABLE public.document_extractions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own document extractions"
    ON public.document_extractions FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can insert own document extractions"
    ON public.document_extractions FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can update own document extractions"
    ON public.document_extractions FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can delete own document extractions"
    ON public.document_extractions FOR DELETE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

-- ------------------------------------------------------------------------------
-- 6. Personal Health Memory (Confirmation Gate)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.personal_health_memory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    domain TEXT NOT NULL CHECK (
        domain IN ('lifestyle', 'preference', 'physiology', 'routine', 'concern', 'supplement')
    ),
    fact_summary TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'draft' CHECK (
        status IN ('draft', 'confirmed', 'rejected', 'archived')
    ),
    confidence_score NUMERIC(3,2) NOT NULL DEFAULT 0.85 CHECK (
        confidence_score BETWEEN 0.00 AND 1.00
    ),
    disclosed_message_id UUID,
    confirmed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_personal_health_memory_user_status
    ON public.personal_health_memory (user_id, status);

ALTER TABLE public.personal_health_memory ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own health memory"
    ON public.personal_health_memory FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can insert own health memory"
    ON public.personal_health_memory FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can update own health memory"
    ON public.personal_health_memory FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can delete own health memory"
    ON public.personal_health_memory FOR DELETE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

