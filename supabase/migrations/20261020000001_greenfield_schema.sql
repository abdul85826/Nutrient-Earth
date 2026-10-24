-- ==============================================================================
-- Nutrient Earth V2 Greenfield Database Schema & RLS Security Policies
-- ==============================================================================

-- 1. Profiles Table
CREATE TABLE IF NOT EXISTS public.profiles (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT NOT NULL,
    age INT NOT NULL CHECK (age >= 0 AND age <= 125),
    biological_sex TEXT NOT NULL,
    primary_goals TEXT[] NOT NULL DEFAULT '{}',
    activity_level TEXT NOT NULL,
    dietary_preference TEXT NOT NULL,
    budget_constraint TEXT NOT NULL,
    willingness_to_change TEXT NOT NULL,
    known_conditions TEXT[] NOT NULL DEFAULT '{}',
    active_supplements TEXT[] NOT NULL DEFAULT '{}',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update own profile"
    ON public.profiles FOR ALL
    USING (auth.uid() = user_id);

-- 2. Health Measurements Table
CREATE TABLE IF NOT EXISTS public.health_measurements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    metric_name TEXT NOT NULL,
    category TEXT NOT NULL,
    current_value NUMERIC NOT NULL,
    unit TEXT NOT NULL,
    target_value NUMERIC NOT NULL,
    normal_range_min NUMERIC,
    normal_range_max NUMERIC,
    data_source TEXT NOT NULL CHECK (data_source IN ('measured', 'userReported', 'aiEstimated')),
    last_updated TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    history JSONB NOT NULL DEFAULT '[]'::jsonb,
    note TEXT DEFAULT ''
);

ALTER TABLE public.health_measurements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can access own health measurements"
    ON public.health_measurements FOR ALL
    USING (auth.uid() = user_id);

-- 3. Health Reports (Sensitive Documents)
CREATE TABLE IF NOT EXISTS public.health_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    filename TEXT NOT NULL,
    storage_path TEXT NOT NULL,
    file_type TEXT NOT NULL,
    file_size INT NOT NULL CHECK (file_size <= 15728640), -- Max 15MB
    summary TEXT,
    uploaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.health_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can access own uploaded health reports"
    ON public.health_reports FOR ALL
    USING (auth.uid() = user_id);

-- 4. AI Conversations & Messages
CREATE TABLE IF NOT EXISTS public.ai_conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.ai_conversations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can access own conversations"
    ON public.ai_conversations FOR ALL
    USING (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS public.ai_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES public.ai_conversations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    is_user BOOLEAN NOT NULL,
    content TEXT NOT NULL,
    sources JSONB DEFAULT '[]'::jsonb,
    evidence_quality TEXT,
    uncertainty TEXT,
    practical_next_steps TEXT[] DEFAULT '{}',
    missing_information_questions TEXT[] DEFAULT '{}',
    attached_report_id UUID REFERENCES public.health_reports(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.ai_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can access own conversation messages"
    ON public.ai_messages FOR ALL
    USING (auth.uid() = user_id);

-- 5. Tab 2 Content: Learn Articles, Exercise Routines, Store Products
CREATE TABLE IF NOT EXISTS public.learn_content (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    category TEXT NOT NULL,
    summary TEXT NOT NULL,
    content TEXT NOT NULL,
    reading_time_minutes INT NOT NULL,
    evidence_score INT NOT NULL CHECK (evidence_score >= 0 AND evidence_score <= 100),
    primary_source_citation TEXT NOT NULL,
    is_peer_reviewed BOOLEAN NOT NULL DEFAULT TRUE,
    published_date DATE NOT NULL,
    key_takeaways TEXT[] NOT NULL DEFAULT '{}'
);

ALTER TABLE public.learn_content ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access for learn content"
    ON public.learn_content FOR SELECT
    USING (true);

CREATE TABLE IF NOT EXISTS public.exercise_routines (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    target_goal TEXT NOT NULL,
    difficulty_level TEXT NOT NULL,
    duration_minutes INT NOT NULL,
    equipment_needed TEXT[] NOT NULL DEFAULT '{}',
    movements JSONB NOT NULL DEFAULT '[]'::jsonb,
    injury_modifications TEXT DEFAULT '',
    scientific_rationale TEXT DEFAULT ''
);

ALTER TABLE public.exercise_routines ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access for exercise routines"
    ON public.exercise_routines FOR SELECT
    USING (true);

CREATE TABLE IF NOT EXISTS public.store_products (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    currency TEXT NOT NULL DEFAULT 'USD',
    rating NUMERIC(3, 2) NOT NULL DEFAULT 5.0,
    review_count INT NOT NULL DEFAULT 0,
    summary TEXT NOT NULL,
    verified_specs TEXT[] NOT NULL DEFAULT '{}',
    third_party_cert TEXT DEFAULT '',
    ingredients_or_components TEXT[] NOT NULL DEFAULT '{}',
    transparent_pricing_breakdown TEXT DEFAULT ''
);

ALTER TABLE public.store_products ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access for store products"
    ON public.store_products FOR SELECT
    USING (true);

-- 6. Storage Bucket Configuration for Health Reports
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'health-reports',
    'health-reports',
    false,
    15728640, -- 15MB
    ARRAY['application/pdf', 'image/png', 'image/jpeg']
)
ON CONFLICT (id) DO NOTHING;

-- Isolated Storage RLS
CREATE POLICY "Users can upload their own reports"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'health-reports' AND
        (storage.foldername(name))[1] = auth.uid()::text
    );

CREATE POLICY "Users can view their own reports"
    ON storage.objects FOR SELECT
    USING (
        bucket_id = 'health-reports' AND
        (storage.foldername(name))[1] = auth.uid()::text
    );
