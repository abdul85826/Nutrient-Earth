-- 003_biological_profiles.sql

DROP TABLE IF EXISTS biological_profiles CASCADE;

CREATE TABLE biological_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    
    date_of_birth DATE,
    gender VARCHAR(20), -- male, female, other, prefer_not_to_say
    
    -- Biological Metrics
    height_cm DECIMAL(5,2),
    weight_kg DECIMAL(5,2),
    blood_group VARCHAR(5),
    body_type VARCHAR(20), -- ectomorph, mesomorph, endomorph
    
    -- Ayurvedic Constitution (Prakriti)
    prakriti_vata INTEGER DEFAULT 0,
    prakriti_pitta INTEGER DEFAULT 0,
    prakriti_kapha INTEGER DEFAULT 0,
    
    -- Medical History Flags (NOT diagnoses)
    has_diabetes BOOLEAN DEFAULT FALSE,
    has_hypertension BOOLEAN DEFAULT FALSE,
    has_thyroid_condition BOOLEAN DEFAULT FALSE,
    has_pcos BOOLEAN DEFAULT FALSE,
    has_asthma BOOLEAN DEFAULT FALSE,
    is_pregnant BOOLEAN DEFAULT FALSE,
    is_breastfeeding BOOLEAN DEFAULT FALSE,
    
    -- Habits
    smoking_status VARCHAR(20),
    alcohol_consumption VARCHAR(20),
    diet_type VARCHAR(30),
    food_allergies TEXT[],
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_biological_profiles_user_id ON biological_profiles(user_id);

-- RLS
ALTER TABLE biological_profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access their own biological profile" ON biological_profiles FOR ALL USING (auth.uid() = user_id);
