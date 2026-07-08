-- ==========================================
-- 1. EXTEND RECOMMENDATIONS TABLE
-- ==========================================
ALTER TABLE public.recommendations 
ADD COLUMN IF NOT EXISTS type VARCHAR(50) NOT NULL DEFAULT 'action',
ADD COLUMN IF NOT EXISTS reasoning_chain TEXT[],
ADD COLUMN IF NOT EXISTS evidence_citations TEXT[],
ADD COLUMN IF NOT EXISTS missing_data TEXT[],
ADD COLUMN IF NOT EXISTS supporting_observations UUID[];

-- ==========================================
-- 2. CREATE UNDERSTANDING GRAPH TABLES
-- ==========================================
CREATE TABLE IF NOT EXISTS public.understanding_graph_nodes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    node_key VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    physiological_mechanism TEXT NOT NULL,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.understanding_graph_edges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_key VARCHAR(100) NOT NULL, -- node_key or raw observation type
    target_key VARCHAR(100) NOT NULL REFERENCES public.understanding_graph_nodes(node_key) ON DELETE CASCADE,
    relationship_type VARCHAR(50) NOT NULL, -- causes, correlates, modulates
    strength FLOAT NOT NULL DEFAULT 0.50,
    citation_key VARCHAR(100) NOT NULL, -- matches id of a knowledge_chunk
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- 3. APPLY ROW LEVEL SECURITY (RLS)
-- ==========================================
ALTER TABLE public.understanding_graph_nodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.understanding_graph_edges ENABLE ROW LEVEL SECURITY;

-- Allow public read access to authenticated users for global reference fact tables
CREATE POLICY "Allow public read access to authenticated users" 
ON public.understanding_graph_nodes 
FOR SELECT 
TO authenticated 
USING (true);

CREATE POLICY "Allow public read access to authenticated users" 
ON public.understanding_graph_edges 
FOR SELECT 
TO authenticated 
USING (true);

-- Restrict writes to administrative/service role only
CREATE POLICY "Restrict modifications to admin or service role only" 
ON public.understanding_graph_nodes 
FOR ALL 
TO service_role 
USING (true);

CREATE POLICY "Restrict modifications to admin or service role only" 
ON public.understanding_graph_edges 
FOR ALL 
TO service_role 
USING (true);

-- ==========================================
-- 4. SEED EVIDENCE BASE & GRAPH
-- ==========================================

-- Seed citations into knowledge_chunks
INSERT INTO public.knowledge_chunks (id, content, source_title, source_category, metadata)
VALUES
  (
    'study_sleep_debt_1999',
    'Accumulated sleep deficit impairs glucose metabolism and metabolic rate, and reduces recovery capability.',
    'Impact of sleep debt on metabolic and endocrine function',
    'citation',
    '{"authors": "Spiegel et al.", "journal": "Lancet", "publication_year": 1999, "doi": "10.1016/S0140-6736(99)01376-8", "url": "https://pubmed.ncbi.nlm.nih.gov/10533868/"}'::jsonb
  ),
  (
    'study_insulin_sleep_2010',
    'A single night of partial sleep deprivation induces insulin resistance in healthy subjects, lowering metabolic flux.',
    'Sleep deprivation impairs insulin sensitivity in healthy volunteers',
    'citation',
    '{"authors": "Donga et al.", "journal": "Journal of Clinical Endocrinology & Metabolism", "publication_year": 2010, "doi": "10.1210/jc.2009-2430", "url": "https://pubmed.ncbi.nlm.nih.gov/20371664/"}'::jsonb
  ),
  (
    'study_hydration_2010',
    'Adequate hydration regulates blood viscosity, plasma volume, cognitive response, and cell volume.',
    'Water, hydration, and health',
    'citation',
    '{"authors": "Popkin et al.", "journal": "Nutrition Reviews", "publication_year": 2010, "doi": "10.1111/j.1753-4887.2010.00304.x", "url": "https://pubmed.ncbi.nlm.nih.gov/20646222/"}'::jsonb
  )
ON CONFLICT (id) DO UPDATE 
SET content = EXCLUDED.content, 
    source_title = EXCLUDED.source_title, 
    source_category = EXCLUDED.source_category, 
    metadata = EXCLUDED.metadata;

-- Seed nodes into understanding_graph_nodes
INSERT INTO public.understanding_graph_nodes (node_key, name, description, physiological_mechanism, metadata)
VALUES
  (
    'sleep_debt',
    'Cumulative Sleep Deficit',
    'Measure of sleep hours lost against the physiological requirement of 8.0 hours daily.',
    'Sleep debt decreases metabolic efficiency, delays recovery times, and increases chronic stress markers.',
    '{"threshold_hours": 5.0}'::jsonb
  ),
  (
    'hydration_depth',
    'Hydration Volume Depth',
    'The proportion of daily water intake relative to the body mass hydration target.',
    'Fluid balance affects cell volume, plasma volume, and energy transport efficiencies.',
    '{"threshold_ml_per_kg": 35.0}'::jsonb
  ),
  (
    'insulin_sensitivity',
    'Metabolic Glucose Clearance',
    'The rate and efficiency of cellular glucose clearance in response to insulin secretion.',
    'Compromised sleep debt combined with low energy activity downregulates cellular insulin receptor responsiveness.',
    '{"sleep_debt_threshold_hours": 5.0}'::jsonb
  )
ON CONFLICT (node_key) DO UPDATE 
SET name = EXCLUDED.name, 
    description = EXCLUDED.description, 
    physiological_mechanism = EXCLUDED.physiological_mechanism, 
    metadata = EXCLUDED.metadata;

-- Seed edges into understanding_graph_edges
INSERT INTO public.understanding_graph_edges (source_key, target_key, relationship_type, strength, citation_key, description)
VALUES
  (
    'sleep_duration',
    'sleep_debt',
    'causes',
    0.95,
    'study_sleep_debt_1999',
    'Sleep duration directly determines the quantity of sleep debt accumulated.'
  ),
  (
    'water_intake',
    'hydration_depth',
    'causes',
    0.90,
    'study_hydration_2010',
    'Water logged directly meets the cellular hydration volume threshold.'
  ),
  (
    'sleep_debt',
    'insulin_sensitivity',
    'modulates',
    0.80,
    'study_insulin_sleep_2010',
    'High sleep debt induces systemic cortisol load, reducing glucose clearance rate.'
  )
ON CONFLICT DO NOTHING;
