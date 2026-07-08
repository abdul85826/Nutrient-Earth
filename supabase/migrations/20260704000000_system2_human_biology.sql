-- =========================================================================
-- SYSTEM 2: HUMAN BIOLOGY ENGINE SCHEMA
-- =========================================================================

-- 1. Create Core Tables

CREATE TABLE IF NOT EXISTS public.body_systems (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.organs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    system_id UUID REFERENCES public.body_systems(id) ON DELETE CASCADE,
    display_name VARCHAR(100) NOT NULL,
    scientific_name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    position VARCHAR(100) NOT NULL,
    anatomy TEXT NOT NULL,
    blood_supply TEXT NOT NULL,
    innervation TEXT NOT NULL,
    image_url TEXT,
    model_3d_ref TEXT,
    future_ml_features JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.organ_functions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organ_id UUID REFERENCES public.organs(id) ON DELETE CASCADE,
    function_name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.organ_relationships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_organ_id UUID REFERENCES public.organs(id) ON DELETE CASCADE,
    target_organ_id UUID REFERENCES public.organs(id) ON DELETE CASCADE,
    relationship_type VARCHAR(100) NOT NULL, -- feedback_loop, metabolic_pathway, etc.
    description TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_organ_relationship UNIQUE(source_organ_id, target_organ_id, relationship_type)
);

CREATE TABLE IF NOT EXISTS public.organ_biomarkers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organ_id UUID REFERENCES public.organs(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    normal_range VARCHAR(100) NOT NULL,
    unit VARCHAR(50) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.organ_symptoms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organ_id UUID REFERENCES public.organs(id) ON DELETE CASCADE,
    symptom_name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    severity_level INTEGER DEFAULT 1 CHECK (severity_level BETWEEN 1 AND 5),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.organ_diseases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organ_id UUID REFERENCES public.organs(id) ON DELETE CASCADE,
    disease_name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    clinical_markers TEXT[] DEFAULT '{}'::TEXT[],
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.organ_nutrients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organ_id UUID REFERENCES public.organs(id) ON DELETE CASCADE,
    nutrient_name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    recommended_daily_intake VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.organ_hormones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organ_id UUID REFERENCES public.organs(id) ON DELETE CASCADE,
    hormone_name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    physiological_role TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.organ_medications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organ_id UUID REFERENCES public.organs(id) ON DELETE CASCADE,
    medication_name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    mechanism_of_action TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.organ_lab_tests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organ_id UUID REFERENCES public.organs(id) ON DELETE CASCADE,
    test_name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    standard_thresholds TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.organ_wearables (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organ_id UUID REFERENCES public.organs(id) ON DELETE CASCADE,
    metric_name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    frequency VARCHAR(50) NOT NULL, -- realtime, hourly, daily, etc.
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.medical_references (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    authors TEXT NOT NULL,
    journal VARCHAR(255) NOT NULL,
    publication_year INTEGER NOT NULL,
    doi VARCHAR(100),
    url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.organ_references (
    organ_id UUID REFERENCES public.organs(id) ON DELETE CASCADE,
    reference_id UUID REFERENCES public.medical_references(id) ON DELETE CASCADE,
    PRIMARY KEY (organ_id, reference_id)
);

-- =========================================================================
-- 2. Apply Row Level Security (RLS)
-- =========================================================================

ALTER TABLE public.body_systems ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organ_functions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organ_relationships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organ_biomarkers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organ_symptoms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organ_diseases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organ_nutrients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organ_hormones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organ_medications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organ_lab_tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organ_wearables ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.medical_references ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organ_references ENABLE ROW LEVEL SECURITY;

-- Anonymous and Authenticated read permissions for reference schemas
CREATE POLICY "Allow public select on body_systems" ON public.body_systems FOR SELECT USING (true);
CREATE POLICY "Allow public select on organs" ON public.organs FOR SELECT USING (true);
CREATE POLICY "Allow public select on organ_functions" ON public.organ_functions FOR SELECT USING (true);
CREATE POLICY "Allow public select on organ_relationships" ON public.organ_relationships FOR SELECT USING (true);
CREATE POLICY "Allow public select on organ_biomarkers" ON public.organ_biomarkers FOR SELECT USING (true);
CREATE POLICY "Allow public select on organ_symptoms" ON public.organ_symptoms FOR SELECT USING (true);
CREATE POLICY "Allow public select on organ_diseases" ON public.organ_diseases FOR SELECT USING (true);
CREATE POLICY "Allow public select on organ_nutrients" ON public.organ_nutrients FOR SELECT USING (true);
CREATE POLICY "Allow public select on organ_hormones" ON public.organ_hormones FOR SELECT USING (true);
CREATE POLICY "Allow public select on organ_medications" ON public.organ_medications FOR SELECT USING (true);
CREATE POLICY "Allow public select on organ_lab_tests" ON public.organ_lab_tests FOR SELECT USING (true);
CREATE POLICY "Allow public select on organ_wearables" ON public.organ_wearables FOR SELECT USING (true);
CREATE POLICY "Allow public select on medical_references" ON public.medical_references FOR SELECT USING (true);
CREATE POLICY "Allow public select on organ_references" ON public.organ_references FOR SELECT USING (true);

-- Restrict mutations to admin/service role
CREATE POLICY "Admin write body_systems" ON public.body_systems FOR ALL TO service_role USING (true);
CREATE POLICY "Admin write organs" ON public.organs FOR ALL TO service_role USING (true);
CREATE POLICY "Admin write organ_functions" ON public.organ_functions FOR ALL TO service_role USING (true);
CREATE POLICY "Admin write organ_relationships" ON public.organ_relationships FOR ALL TO service_role USING (true);
CREATE POLICY "Admin write organ_biomarkers" ON public.organ_biomarkers FOR ALL TO service_role USING (true);
CREATE POLICY "Admin write organ_symptoms" ON public.organ_symptoms FOR ALL TO service_role USING (true);
CREATE POLICY "Admin write organ_diseases" ON public.organ_diseases FOR ALL TO service_role USING (true);
CREATE POLICY "Admin write organ_nutrients" ON public.organ_nutrients FOR ALL TO service_role USING (true);
CREATE POLICY "Admin write organ_hormones" ON public.organ_hormones FOR ALL TO service_role USING (true);
CREATE POLICY "Admin write organ_medications" ON public.organ_medications FOR ALL TO service_role USING (true);
CREATE POLICY "Admin write organ_lab_tests" ON public.organ_lab_tests FOR ALL TO service_role USING (true);
CREATE POLICY "Admin write organ_wearables" ON public.organ_wearables FOR ALL TO service_role USING (true);
CREATE POLICY "Admin write medical_references" ON public.medical_references FOR ALL TO service_role USING (true);
CREATE POLICY "Admin write organ_references" ON public.organ_references FOR ALL TO service_role USING (true);

-- =========================================================================
-- 3. Indexes for Optimized Query Performance
-- =========================================================================

CREATE INDEX IF NOT EXISTS idx_organs_system_id ON public.organs(system_id);
CREATE INDEX IF NOT EXISTS idx_organ_functions_organ_id ON public.organ_functions(organ_id);
CREATE INDEX IF NOT EXISTS idx_organ_relationships_src ON public.organ_relationships(source_organ_id);
CREATE INDEX IF NOT EXISTS idx_organ_relationships_tgt ON public.organ_relationships(target_organ_id);
CREATE INDEX IF NOT EXISTS idx_organ_biomarkers_organ_id ON public.organ_biomarkers(organ_id);
CREATE INDEX IF NOT EXISTS idx_organ_symptoms_organ_id ON public.organ_symptoms(organ_id);
CREATE INDEX IF NOT EXISTS idx_organ_diseases_organ_id ON public.organ_diseases(organ_id);
CREATE INDEX IF NOT EXISTS idx_organ_nutrients_organ_id ON public.organ_nutrients(organ_id);
CREATE INDEX IF NOT EXISTS idx_organ_hormones_organ_id ON public.organ_hormones(organ_id);
CREATE INDEX IF NOT EXISTS idx_organ_medications_organ_id ON public.organ_medications(organ_id);
CREATE INDEX IF NOT EXISTS idx_organ_lab_tests_organ_id ON public.organ_lab_tests(organ_id);
CREATE INDEX IF NOT EXISTS idx_organ_wearables_organ_id ON public.organ_wearables(organ_id);

-- =========================================================================
-- 4. Seed Data (Nervous, Cardiovascular, Endocrine, Respiratory, Digestive, Renal)
-- =========================================================================

-- Seed Body Systems
INSERT INTO public.body_systems (id, name, description) VALUES
  ('11111111-1111-1111-1111-111111111111', 'Cardiovascular System', 'Coordinates blood flow, heart contractions, and peripheral gas transport.'),
  ('22222222-2222-2222-2222-222222222222', 'Nervous System', 'Processes high-level cognitive, sensory, and autonomic signaling.'),
  ('33333333-3333-3333-3333-333333333333', 'Endocrine & Metabolic System', 'Regulates systemic hormones, glucose homeostasis, and metabolic rate.'),
  ('44444444-4444-4444-4444-444444444444', 'Respiratory System', 'Manages gas exchange, ventilation, and oxygenation levels.'),
  ('55555555-5555-5555-5555-555555555555', 'Digestive System', 'Controls digestive motility, nutrient absorption, and microbiome balance.'),
  ('66666666-6666-6666-6666-666666666666', 'Renal System', 'Regulates fluid balance, blood pressure controls, and filtration rate.')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description;

-- Seed Organs
INSERT INTO public.organs (id, system_id, display_name, scientific_name, description, position, anatomy, blood_supply, innervation, model_3d_ref, future_ml_features) VALUES
  (
    'a1111111-a111-a111-a111-a11111111111',
    '11111111-1111-1111-1111-111111111111',
    'Heart',
    'Cor',
    'Four-chambered muscular pump that drives blood circulation.',
    'Mediastinum (left-center chest)',
    'Myocardium wall, four valves (tricuspid, pulmonary, mitral, aortic), pericardial sac.',
    'Left and right coronary arteries, coronary sinus.',
    'Vagus nerve (parasympathetic), Sympathetic trunk (T1-T4 cardiac nerves).',
    'assets/models/heart.glb',
    '["stroke_volume_prediction", "hrv_stress_response"]'::jsonb
  ),
  (
    'b2222222-b222-b222-b222-b22222222222',
    '22222222-2222-2222-2222-222222222222',
    'Brain',
    'Encephalon',
    'The central organ of the nervous system, responsible for conscious and autonomic controls.',
    'Cranial cavity',
    'Cerebrum (lobes), cerebellum, brainstem (pons, medulla), ventricles.',
    'Internal carotid arteries, vertebral arteries, Circle of Willis.',
    'Cranial Nerves I-XII, sympathetic and parasympathetic tracts.',
    'assets/models/brain.glb',
    '["cognitive_fatigue_index", "circadian_rhythm_sync"]'::jsonb
  ),
  (
    'c3333333-c333-c333-c333-c33333333333',
    '55555555-5555-5555-5555-555555555555',
    'Liver',
    'Hepar',
    'Primary metabolic and detoxification organ in the human body.',
    'Right upper abdominal quadrant',
    'Right, left, caudate, and quadrate lobes; lobules, hepatocytes.',
    'Hepatic artery proper, hepatic portal vein.',
    'Celiac plexus, Vagus nerve.',
    'assets/models/liver.glb',
    '["detox_recovery_rate", "lipogenesis_ratio"]'::jsonb
  ),
  (
    'd4444444-d444-d444-d444-d44444444444',
    '44444444-4444-4444-4444-444444444444',
    'Lungs',
    'Pulmo',
    'Paired respiratory organs responsible for carbon dioxide clearance and oxygen intake.',
    'Bilateral thoracic cavity',
    'Right lung (3 lobes), left lung (2 lobes), bronchi, bronchial tree, alveoli.',
    'Pulmonary arteries, bronchial arteries.',
    'Pulmonary plexus (Vagus nerve and sympathetic fibers).',
    'assets/models/lungs.glb',
    '["respiratory_efficiency", "aqi_irritation_index"]'::jsonb
  ),
  (
    'e5555555-e555-e555-e555-e55555555555',
    '66666666-6666-6666-6666-666666666666',
    'Kidneys',
    'Ren',
    'Bilateral filtration organs regulating electrolytes and systemic blood volume.',
    'Retroperitoneal space (T12-L3)',
    'Renal cortex, renal pyramids, renal pelvis, nephrons (glomerulus, tubules).',
    'Renal arteries.',
    'Renal plexus.',
    'assets/models/kidneys.glb',
    '["electrolyte_clearance_model", "hydration_regulatory_score"]'::jsonb
  ),
  (
    'f6666666-f666-f666-f666-f66666666666',
    '33333333-3333-3333-3333-333333333333',
    'Pancreas',
    'Pancreas',
    'Glandular organ possessing both exocrine digestive and endocrine blood glucose roles.',
    'Epigastric region (behind stomach)',
    'Head, neck, body, tail; acinar cells (digestive), Islets of Langerhans (insulin/glucagon).',
    'Splenic artery, superior mesenteric artery, pancreaticoduodenal arteries.',
    'Celiac plexus, Vagus nerve.',
    'assets/models/pancreas.glb',
    '["insulin_secretion_responsiveness", "glycemic_volatility"]'::jsonb
  ),
  (
    'g7777777-g777-g777-g777-g77777777777',
    '55555555-5555-5555-5555-555555555555',
    'Gut',
    'Intestinum',
    'The gastrointestinal tract including small and large intestines, mucosal barrier, and microbiome.',
    'Abdominal cavity',
    'Duodenum, jejunum, ileum, cecum, colon, rectum, epithelial barrier, enteric plexuses.',
    'Superior and inferior mesenteric arteries.',
    'Enteric Nervous System (ENS), Myenteric and Submucosal plexuses.',
    'assets/models/gut.glb',
    '["dysbiosis_probability", "nutrient_absorption_ratio"]'::jsonb
  )
ON CONFLICT (id) DO UPDATE SET 
  system_id = EXCLUDED.system_id, 
  display_name = EXCLUDED.display_name, 
  scientific_name = EXCLUDED.scientific_name, 
  description = EXCLUDED.description, 
  position = EXCLUDED.position, 
  anatomy = EXCLUDED.anatomy, 
  blood_supply = EXCLUDED.blood_supply, 
  innervation = EXCLUDED.innervation, 
  model_3d_ref = EXCLUDED.model_3d_ref, 
  future_ml_features = EXCLUDED.future_ml_features;

-- Seed Organ Functions
INSERT INTO public.organ_functions (organ_id, function_name, description) VALUES
  ('a1111111-a111-a111-a111-a11111111111', 'Circulation', 'Pumps oxygenated blood to peripheral organ structures and deoxygenated blood to the lungs.'),
  ('b2222222-b222-b222-b222-b22222222222', 'Cognitive Control', 'Manages high-level conscious thinking, memory encoding, motor execution, and emotional responses.'),
  ('b2222222-b222-b222-b222-b22222222222', 'Autonomic Homeostasis', 'Regulates involuntary physiological baselines (heart rate, thermoregulation, pupil responses).'),
  ('c3333333-c333-c333-c333-c33333333333', 'Xenobiotic Cleansing', 'Breaks down metabolic waste, medications, alcohol, and external toxins.'),
  ('c3333333-c333-c333-c333-c33333333333', 'Glycogen Storage', 'Converts serum glucose into glycogen storage and releases it when blood glucose levels fall.'),
  ('d4444444-d444-d444-d444-d44444444444', 'Gas Exchange', 'Diffuses oxygen into the capillary beds and removes carbon dioxide gas from the circulatory loop.'),
  ('e5555555-e555-e555-e555-e55555555555', 'Urine Concentration', 'Filters nitrogenous metabolic waste products and concentrates them into urine.'),
  ('f6666666-f666-f666-f666-f66666666666', 'Glucose Regulation', 'Senses blood glucose level changes and secretes insulin or glucagon respectively.'),
  ('g7777777-g777-g777-g777-g77777777777', 'Absorption', 'Absorbs minerals, amino acids, and fatty acids through intestinal villi into the bloodstream.');

-- Seed Organ Relationships
INSERT INTO public.organ_relationships (source_organ_id, target_organ_id, relationship_type, description) VALUES
  ('g7777777-g777-g777-g777-g77777777777', 'b2222222-b222-b222-b222-b22222222222', 'Gut-Brain Axis', 'Bidirectional signaling via the vagus nerve and microbiome neurotransmitter precursors affecting mood.'),
  ('a1111111-a111-a111-a111-a11111111111', 'e5555555-e555-e555-e555-e55555555555', 'Cardiorenal Loop', 'Systolic blood pressure drives glomerular filtration; kidney renin secretion regulates systemic vascular resistance.'),
  ('f6666666-f666-f666-f666-f66666666666', 'c3333333-c333-c333-c333-c33333333333', 'Insulin-Glycogen Loop', 'Pancreatic insulin tells hepatocytes to cease gluconeogenesis and activate glycogen storage pathways.');

-- Seed Organ Biomarkers
INSERT INTO public.organ_biomarkers (organ_id, name, description, normal_range, unit) VALUES
  ('a1111111-a111-a111-a111-a11111111111', 'Cardiac Troponin T', 'Regulatory protein specific to cardiac muscles, released upon cell necrosis.', '0.0 - 0.014', 'ng/mL'),
  ('b2222222-b222-b222-b222-b22222222222', 'S100B', 'Glial-derived calcium binding protein indicating BBB disruption.', '0.0 - 0.12', 'mcg/L'),
  ('c3333333-c333-c333-c333-c33333333333', 'ALT', 'Alanine Aminotransferase; intracellular enzyme released during hepatic stress.', '7 - 56', 'U/L'),
  ('d4444444-d444-d444-d444-d44444444444', 'SP-D', 'Surfactant Protein D; indicator of alveolar epithelial integrity.', '0 - 110', 'ng/mL'),
  ('e5555555-e555-e555-e555-e55555555555', 'Serum Creatinine', 'Metabolic byproduct of muscle creatine breakdown cleared exclusively by glomerular filtration.', '0.6 - 1.2', 'mg/dL'),
  ('f6666666-f666-f666-f666-f66666666666', 'HbA1c', 'Glycated hemoglobin representing average 3-month blood glucose concentration.', '4.0 - 5.6', '%'),
  ('g7777777-g777-g777-g777-g77777777777', 'Fecal Calprotectin', 'Neutrophil-derived calcium binding protein indicating mucosal wall inflammation.', '0 - 50', 'mcg/g');

-- Seed Organ Symptoms
INSERT INTO public.organ_symptoms (organ_id, symptom_name, description, severity_level) VALUES
  ('a1111111-a111-a111-a111-a11111111111', 'Angina', 'Substernal pressure or squeezing chest pain due to myocardial ischemia.', 4),
  ('b2222222-b222-b222-b222-b22222222222', 'Cognitive Fog', 'Lethargy, slow processing speeds, and mild memory retrieval deficits.', 2),
  ('c3333333-c333-c333-c333-c33333333333', 'Jaundice', 'Yellow tinting of sclera and skin caused by hyperbilirubinemia.', 4),
  ('d4444444-d444-d444-d444-d44444444444', 'Dyspnea', 'Air hunger or subjective difficulty drawing a breath.', 3),
  ('e5555555-e555-e555-e555-e55555555555', 'Oliguria', 'Low urine volume indicating compromised filtration output.', 4),
  ('f6666666-f666-f666-f666-f66666666666', 'Polydipsia', 'Abnormally high thirst levels linked to high plasma glucose concentration.', 2),
  ('g7777777-g777-g777-g777-g77777777777', 'Meteorism', 'Gastrointestinal distension and flatulence due to abnormal fermentation.', 2);

-- Seed Organ Diseases
INSERT INTO public.organ_diseases (organ_id, disease_name, description, clinical_markers) VALUES
  ('a1111111-a111-a111-a111-a11111111111', 'Myocardial Infarction', 'Necrosis of myocardium due to acute blockage of coronary arteries.', '{"Troponin T elevation", "ST elevation"}'),
  ('b2222222-b222-b222-b222-b22222222222', 'Ischemic Stroke', 'Neuronal death resulting from focal lack of cerebral blood perfusion.', '{"Diffusion restrictions on MRI", "S100B elevation"}'),
  ('c3333333-c333-c333-c333-c33333333333', 'Metabolic Dysfunction-Associated Steatohepatitis', 'Hepatic inflammation and fat accumulation leading to fibrosis.', '{"ALT elevation", "Fibroscan score"}');

-- Seed Organ Nutrients
INSERT INTO public.organ_nutrients (organ_id, nutrient_name, description, recommended_daily_intake) VALUES
  ('a1111111-a111-a111-a111-a11111111111', 'Coenzyme Q10', 'Antioxidant cofactor in mitochondrial ETC crucial for high ATP demand in heart myocytes.', '100 - 200 mg'),
  ('b2222222-b222-b222-b222-b22222222222', 'Docosahexaenoic Acid (DHA)', 'Omega-3 structural fatty acid essential for cerebral phospholipid membranes.', '250 - 500 mg'),
  ('c3333333-c333-c333-c333-c33333333333', 'Choline', 'Lecithin precursor essential for packaging VLDLs and preventing hepatic lipid accumulation.', '425 - 550 mg');

-- Seed Organ Hormones
INSERT INTO public.organ_hormones (organ_id, hormone_name, description, physiological_role) VALUES
  ('a1111111-a111-a111-a111-a11111111111', 'Atrial Natriuretic Peptide', 'Peptide hormone secreted by atrial myocytes in response to high stretch forces.', 'Triggers renal sodium excretion, reducing blood volume.'),
  ('b2222222-b222-b222-b222-b22222222222', 'Melatonin', 'Indoleamine hormone synthesized by the pineal gland in dark phases.', 'Regulates circadian phase alignment and induces sleep.'),
  ('f6666666-f666-f666-f666-f66666666666', 'Insulin', 'Anabolic peptide hormone secreted by beta cells of the Islets of Langerhans.', 'Enables glucose uptake in skeletal muscles and suppresses hepatic gluconeogenesis.');

-- Seed Organ Medications
INSERT INTO public.organ_medications (organ_id, medication_name, description, mechanism_of_action) VALUES
  ('a1111111-a111-a111-a111-a11111111111', 'Metoprolol', 'Beta-1 selective adrenergic antagonist.', 'Blocks catecholamine responses in cardiac myocytes, reducing heart rate and blood pressure.'),
  ('f6666666-f666-f666-f666-f66666666666', 'Metformin', 'Biguanide blood-glucose lowering medication.', 'Activates AMPK pathway, downregulating hepatic gluconeogenesis and enhancing peripheral insulin sensitivity.');

-- Seed Organ Lab Tests
INSERT INTO public.organ_lab_tests (organ_id, test_name, description, standard_thresholds) VALUES
  ('a1111111-a111-a111-a111-a11111111111', 'Electrocardiogram', '12-lead electrical tracing of heart conduction signals.', 'PR Interval: 120-200ms, QRS Duration: <100ms'),
  ('e5555555-e555-e555-e555-e55555555555', 'Glomerular Filtration Rate', 'Calculated volume of fluid filtered by renal capillaries per minute.', 'Optimal: >90 mL/min/1.73m2');

-- Seed Organ Wearables
INSERT INTO public.organ_wearables (organ_id, metric_name, description, frequency) VALUES
  ('a1111111-a111-a111-a111-a11111111111', 'Heart Rate Variability', 'Root mean square of successive RR interval differences (rMSSD).', 'realtime'),
  ('b2222222-b222-b222-b222-b22222222222', 'Sleep Phase Duration', 'Calculated duration spent in deep, light, and REM sleep cycles.', 'daily'),
  ('d4444444-d444-d444-d444-d44444444444', 'Respiratory Rate', 'Breaths drawn per minute during resting states.', 'realtime');

-- Seed Medical References
INSERT INTO public.medical_references (id, title, authors, journal, publication_year, doi, url) VALUES
  ('ref_heart_001', 'Heart Rate Variability: Standards of Measurement and Clinical Use', 'Task Force of ESC and NASPE', 'Circulation', 1996, '10.1161/01.CIR.93.5.1043', 'https://pubmed.ncbi.nlm.nih.gov/8598087/'),
  ('ref_brain_001', 'Synaptic Plasticity and Memory', 'Martin et al.', 'Annual Review of Neuroscience', 2000, '10.1146/annurev.neuro.23.1.649', 'https://pubmed.ncbi.nlm.nih.gov/10837165/');

-- Seed Organ Reference Junction Links
INSERT INTO public.organ_references (organ_id, reference_id) VALUES
  ('a1111111-a111-a111-a111-a11111111111', 'ref_heart_001'),
  ('b2222222-b222-b222-b222-b22222222222', 'ref_brain_001');
