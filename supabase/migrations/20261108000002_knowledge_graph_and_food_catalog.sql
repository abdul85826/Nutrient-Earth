-- ==============================================================================
-- Migration: 20261108000002_knowledge_graph_and_food_catalog.sql
-- Description: Phase D Knowledge, Retrieval & Nutrition Infrastructure:
--   1. Knowledge Graph Entities (kg_entities)
--   2. Knowledge Graph Relationships (kg_relationships)
--   3. Food & Nutrient Reference Catalog (USDA FoodData Central structure)
--   4. User Nutrition Logs (Meals, food intake, macro breakdowns)
--   5. User Intelligence Feedback (RLHF / accuracy auditing)
--   6. Tool Execution Audit Log (Deterministic & AI tool trace integrity)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Knowledge Graph Entities
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.kg_entities (
    id TEXT PRIMARY KEY, -- Canonical ID e.g. 'food:spinach', 'nutrient:magnesium', 'pathway:gaba_synthesis'
    name TEXT NOT NULL,
    entity_type TEXT NOT NULL CHECK (
        entity_type IN ('food', 'nutrient', 'biological_pathway', 'biomarker', 'health_condition', 'medication', 'scientific_claim')
    ),
    mesh_id TEXT,
    description TEXT,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_kg_entities_type
    ON public.kg_entities (entity_type);

ALTER TABLE public.kg_entities ENABLE ROW LEVEL SECURITY;

-- Read-only catalog for clients; mutations restricted to administrators / migrations
CREATE POLICY "Public read access for kg entities"
    ON public.kg_entities FOR SELECT
    TO authenticated, anon
    USING (true);

-- ------------------------------------------------------------------------------
-- 2. Knowledge Graph Relationships
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.kg_relationships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_id TEXT NOT NULL REFERENCES public.kg_entities(id) ON DELETE CASCADE,
    target_id TEXT NOT NULL REFERENCES public.kg_entities(id) ON DELETE CASCADE,
    relationship_type TEXT NOT NULL CHECK (
        relationship_type IN (
            'contains_nutrient',
            'metabolizes_to',
            'upregulates',
            'inhibits',
            'requires_cofactor',
            'contraindicated_with',
            'biomarker_for',
            'modulates_condition',
            'supported_by_evidence'
        )
    ),
    evidence_pmid TEXT,
    evidence_doi TEXT,
    confidence_score NUMERIC(3,2) NOT NULL DEFAULT 1.00 CHECK (
        confidence_score BETWEEN 0.00 AND 1.00
    ),
    clinical_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_kg_rel_source
    ON public.kg_relationships (source_id);

CREATE INDEX IF NOT EXISTS idx_kg_rel_target
    ON public.kg_relationships (target_id);

CREATE INDEX IF NOT EXISTS idx_kg_rel_type
    ON public.kg_relationships (relationship_type);

ALTER TABLE public.kg_relationships ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read access for kg relationships"
    ON public.kg_relationships FOR SELECT
    TO authenticated, anon
    USING (true);

-- ------------------------------------------------------------------------------
-- 3. Food & Nutrient Reference Catalog
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.food_reference_catalog (
    fdc_id INT PRIMARY KEY,
    food_name TEXT NOT NULL,
    food_category TEXT NOT NULL,
    serving_size_g NUMERIC NOT NULL DEFAULT 100.0,
    serving_size_unit TEXT NOT NULL DEFAULT 'g',
    energy_kcal NUMERIC NOT NULL CHECK (energy_kcal >= 0),
    protein_g NUMERIC NOT NULL CHECK (protein_g >= 0),
    carbohydrate_g NUMERIC NOT NULL CHECK (carbohydrate_g >= 0),
    total_fat_g NUMERIC NOT NULL CHECK (total_fat_g >= 0),
    dietary_fiber_g NUMERIC NOT NULL DEFAULT 0.0 CHECK (dietary_fiber_g >= 0),
    micronutrients JSONB NOT NULL DEFAULT '{}'::jsonb,
    is_verified BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_food_ref_name_fts
    ON public.food_reference_catalog USING gin (to_tsvector('english', food_name));

CREATE INDEX IF NOT EXISTS idx_food_ref_category
    ON public.food_reference_catalog (food_category);

ALTER TABLE public.food_reference_catalog ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read access for food catalog"
    ON public.food_reference_catalog FOR SELECT
    TO authenticated, anon
    USING (true);

-- ------------------------------------------------------------------------------
-- 4. User Nutrition Logs (Meals & Servings)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.nutrition_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    meal_type TEXT NOT NULL CHECK (
        meal_type IN ('breakfast', 'lunch', 'dinner', 'snack', 'supplement')
    ),
    logged_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    total_calories NUMERIC NOT NULL CHECK (total_calories >= 0),
    total_protein_g NUMERIC NOT NULL CHECK (total_protein_g >= 0),
    total_carbs_g NUMERIC NOT NULL CHECK (total_carbs_g >= 0),
    total_fat_g NUMERIC NOT NULL CHECK (total_fat_g >= 0),
    meal_items JSONB NOT NULL DEFAULT '[]'::jsonb,
    photo_storage_path TEXT,
    source TEXT NOT NULL CHECK (
        source IN ('manual', 'camera_analysis', 'barcode_scan', 'voice_input')
    ),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_nutrition_logs_user_date
    ON public.nutrition_logs (user_id, logged_at DESC);

ALTER TABLE public.nutrition_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own nutrition logs"
    ON public.nutrition_logs FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can insert own nutrition logs"
    ON public.nutrition_logs FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can update own nutrition logs"
    ON public.nutrition_logs FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can delete own nutrition logs"
    ON public.nutrition_logs FOR DELETE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

-- ------------------------------------------------------------------------------
-- 5. User Intelligence Feedback (Accuracy Auditing)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.user_intelligence_feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    message_id UUID,
    rating INT NOT NULL CHECK (rating IN (-1, 1)),
    category TEXT,
    feedback_text TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_user_intel_feedback_user
    ON public.user_intelligence_feedback (user_id);

ALTER TABLE public.user_intelligence_feedback ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own feedback"
    ON public.user_intelligence_feedback FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can insert own feedback"
    ON public.user_intelligence_feedback FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- ------------------------------------------------------------------------------
-- 6. Tool Executions Audit Log
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.tool_executions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    message_id UUID,
    tool_name TEXT NOT NULL,
    input_parameters JSONB NOT NULL DEFAULT '{}'::jsonb,
    execution_output JSONB NOT NULL DEFAULT '{}'::jsonb,
    duration_ms INT NOT NULL CHECK (duration_ms >= 0),
    status TEXT NOT NULL CHECK (status IN ('success', 'failed', 'timeout')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_tool_executions_user
    ON public.tool_executions (user_id, created_at DESC);

ALTER TABLE public.tool_executions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own tool execution audit"
    ON public.tool_executions FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can insert own tool execution audit"
    ON public.tool_executions FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

