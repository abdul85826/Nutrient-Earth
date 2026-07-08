create table users (
  id uuid primary key default auth.uid(),
  name text,
  age int,
  city text,
  main_problem text,
  language text default 'en',
  created_at timestamp default now()
);

create table health_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id),
  sugar int,
  bp int,
  weight int,
  energy_level int,
  stress_level int,
  created_at timestamp default now()
);

create table daily_plans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id),
  steps jsonb,
  completed boolean default false,
  created_at timestamp default now()
);

create table organ_states (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id),
  pancreas int default 30,
  heart int default 40,
  lungs int default 50,
  updated_at timestamp default now()
);

create table points (
  user_id uuid primary key references users(id),
  total int default 0
);

create table streaks (
  user_id uuid primary key references users(id),
  current_streak int default 0,
  last_active_date date
);

create table products (
  id uuid primary key default gen_random_uuid(),
  name text,
  price int,
  category text,
  benefits text,
  stock int,
  location text,
  created_at timestamp default now()
);

create table orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id),
  product_id uuid references products(id),
  amount int,
  status text,
  created_at timestamp default now()
);

create table success_stories (
  id uuid primary key default gen_random_uuid(),
  name text,
  before_value int,
  after_value int,
  days int,
  problem_type text,
  story text
);

create table flow_content (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  type text,
  topic text,
  content_url text,
  caption text,
  likes int default 0,
  created_at timestamp default now()
);
-- Table 1: users (Extending existing or replacing)
-- Assuming we want to align with the new spec strictly
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT auth.uid(),
  email TEXT NOT NULL,
  full_name TEXT,
  profile_photo_url TEXT,
  profile_completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  last_login TIMESTAMP DEFAULT NOW()
);

-- Table 2: user_profiles
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  age INTEGER NOT NULL,
  gender TEXT NOT NULL CHECK (gender IN ('male', 'female', 'other')),
  weight_kg DECIMAL(5,2) NOT NULL,
  height_cm DECIMAL(5,2) NOT NULL,
  primary_goal TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Table 3: user_symptoms
CREATE TABLE IF NOT EXISTS user_symptoms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  symptom_type TEXT NOT NULL,
  severity INTEGER CHECK (severity BETWEEN 1 AND 5),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Table 4: daily_progress
CREATE TABLE IF NOT EXISTS daily_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  tasks_completed INTEGER DEFAULT 0,
  total_tasks INTEGER DEFAULT 0,
  adherence_percentage DECIMAL(5,2) DEFAULT 0,
  energy_level INTEGER CHECK (energy_level BETWEEN 1 AND 10),
  water_intake_liters DECIMAL(5,2) DEFAULT 0,
  sleep_hours DECIMAL(5,2) DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, date)
);

-- Table 5: user_plans
CREATE TABLE IF NOT EXISTS user_plans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  condition_category TEXT NOT NULL,
  timeline_days INTEGER NOT NULL,
  plan_data JSONB NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Table 6: chat_history
CREATE TABLE IF NOT EXISTS chat_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  is_user BOOLEAN NOT NULL,
  image_url TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- RLS POLICIES
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_symptoms ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their own data" ON users FOR ALL USING (auth.uid() = id);
CREATE POLICY "Users can only access their own profile" ON user_profiles FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can only access their own symptoms" ON user_symptoms FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can only access their own progress" ON daily_progress FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can only access their own plans" ON user_plans FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can only access their own chat history" ON chat_history FOR ALL USING (auth.uid() = user_id);
-- Migration: NE Core Engine v1
-- Adds missing fields to user_profiles and daily_progress for health tracking

ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS diabetes_status TEXT,
ADD COLUMN IF NOT EXISTS activity_level TEXT,
ADD COLUMN IF NOT EXISTS sleep_hours DECIMAL(5,2),
ADD COLUMN IF NOT EXISTS diet_preference TEXT;

ALTER TABLE daily_progress
ADD COLUMN IF NOT EXISTS steps INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS symptoms_tracked JSONB DEFAULT '[]'::jsonb,
ADD COLUMN IF NOT EXISTS plan_completed BOOLEAN DEFAULT FALSE;
-- 001_users.sql
-- We extend or recreate the users table. Assuming we drop existing to rebuild according to the new spec.
-- NOTE: In production, we would use ALTER TABLE. For development, we drop and recreate.

DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE users (
    -- Identity
    id UUID PRIMARY KEY DEFAULT auth.uid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    last_active TIMESTAMP,
    
    -- Authentication
    auth_provider VARCHAR(50) DEFAULT 'email', -- email, google, apple
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    
    -- Account status
    status VARCHAR(20) DEFAULT 'active', -- active, inactive, suspended
    subscription_tier VARCHAR(20) DEFAULT 'free', -- free, pro, premium
    subscription_expires_at TIMESTAMP,
    
    -- Privacy & Permissions
    data_sharing_consent BOOLEAN DEFAULT FALSE,
    research_consent BOOLEAN DEFAULT FALSE,
    marketing_consent BOOLEAN DEFAULT FALSE,
    
    -- Metadata
    device_info JSONB, -- {platform: "ios", version: "1.2.0"}
    app_version VARCHAR(20),
    timezone VARCHAR(50),
    language VARCHAR(10) DEFAULT 'en'
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);
CREATE INDEX IF NOT EXISTS idx_users_subscription ON users(subscription_tier);

-- RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access their own data" ON users FOR ALL USING (auth.uid() = id);
-- 002_profiles.sql

DROP TABLE IF EXISTS profiles CASCADE;

CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    
    -- Basic Demographics
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    
    -- Lifestyle
    occupation VARCHAR(100),
    activity_level VARCHAR(20), -- sedentary, light, moderate, active, very_active
    stress_level VARCHAR(20), -- low, medium, high
    
    -- Goals
    primary_goal VARCHAR(50),
    secondary_goals TEXT[],
    
    -- Location
    current_city VARCHAR(100),
    current_country VARCHAR(100),
    timezone VARCHAR(50),
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON profiles(user_id);

-- RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access their own profile" ON profiles FOR ALL USING (auth.uid() = user_id);
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
-- 004_environment_logs.sql

DROP TABLE IF EXISTS environment_logs CASCADE;

CREATE TABLE environment_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    -- Location
    city VARCHAR(100),
    country VARCHAR(100),
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    
    -- Air Quality
    aqi INTEGER,
    aqi_category VARCHAR(20), -- good, moderate, unhealthy, hazardous
    pm25 DECIMAL(6,2),
    
    -- Weather
    temperature_c DECIMAL(5,2),
    humidity_percent INTEGER,
    uv_index INTEGER,
    weather_condition VARCHAR(50),
    
    -- Timestamp
    recorded_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_environment_logs_user_time ON environment_logs(user_id, recorded_at);

-- RLS
ALTER TABLE environment_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access their own environment logs" ON environment_logs FOR ALL USING (auth.uid() = user_id);
-- 005_assistant_memory.sql

DROP TABLE IF EXISTS assistant_memory CASCADE;

CREATE TABLE assistant_memory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    -- Interaction Details
    user_message TEXT NOT NULL,
    ai_response TEXT NOT NULL,
    
    -- Context
    intent VARCHAR(50),
    biological_context JSONB,
    environmental_context JSONB,
    recommendations JSONB[],
    
    -- Feedback
    user_feedback VARCHAR(20),
    feedback_rating INTEGER CHECK (feedback_rating BETWEEN 1 AND 5),
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    session_id UUID
);

CREATE INDEX IF NOT EXISTS idx_assistant_memory_user_id ON assistant_memory(user_id);
CREATE INDEX IF NOT EXISTS idx_assistant_memory_intent ON assistant_memory(intent);

-- RLS
ALTER TABLE assistant_memory ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access their own assistant memory" ON assistant_memory FOR ALL USING (auth.uid() = user_id);
-- 006_daily_metrics.sql

DROP TABLE IF EXISTS daily_metrics CASCADE;

CREATE TABLE daily_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    
    -- Sleep
    sleep_hours DECIMAL(4,2),
    sleep_quality VARCHAR(20),
    
    -- Hydration
    water_intake_ml INTEGER DEFAULT 0,
    
    -- Energy & Stress
    energy_level INTEGER CHECK (energy_level BETWEEN 1 AND 10),
    stress_level INTEGER CHECK (stress_level BETWEEN 1 AND 10),
    
    -- Habits & Compliance
    tasks_completed INTEGER DEFAULT 0,
    total_tasks INTEGER DEFAULT 0,
    
    -- Logged Symptoms
    symptoms_tracked TEXT[],
    daily_state VARCHAR(20) DEFAULT 'normal', -- low_energy, high_energy
    
    -- Metadata
    logged_at TIMESTAMP DEFAULT NOW(),
    
    UNIQUE(user_id, date)
);

CREATE INDEX IF NOT EXISTS idx_daily_metrics_user_date ON daily_metrics(user_id, date);

-- RLS
ALTER TABLE daily_metrics ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access their own daily metrics" ON daily_metrics FOR ALL USING (auth.uid() = user_id);
-- 007_onboarding_drafts.sql

DROP TABLE IF EXISTS onboarding_drafts CASCADE;

CREATE TABLE onboarding_drafts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    
    step INTEGER NOT NULL DEFAULT 0,
    data JSONB,
    
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_onboarding_drafts_user_id ON onboarding_drafts(user_id);

-- RLS
ALTER TABLE onboarding_drafts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access their own drafts" ON onboarding_drafts FOR ALL USING (auth.uid() = user_id);
-- 008_permissions.sql

DROP TABLE IF EXISTS permissions CASCADE;

CREATE TABLE permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    
    -- Hardware Permissions
    camera_enabled BOOLEAN DEFAULT FALSE,
    location_enabled BOOLEAN DEFAULT FALSE,
    notifications_enabled BOOLEAN DEFAULT FALSE,
    health_connect_enabled BOOLEAN DEFAULT FALSE,
    
    -- Data Privacy
    share_anonymous_data BOOLEAN DEFAULT FALSE,
    allow_ai_training BOOLEAN DEFAULT FALSE,
    
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_permissions_user_id ON permissions(user_id);

-- RLS
ALTER TABLE permissions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access their own permissions" ON permissions FOR ALL USING (auth.uid() = user_id);
-- 009_subscriptions.sql

DROP TABLE IF EXISTS subscriptions CASCADE;

CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    -- Subscription Details
    plan_type VARCHAR(20), -- pro, premium
    billing_cycle VARCHAR(20), -- monthly, yearly
    
    -- Dates
    started_at TIMESTAMP NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    
    -- Status
    status VARCHAR(20) DEFAULT 'active', -- active, cancelled, expired, paused
    auto_renew BOOLEAN DEFAULT TRUE,
    
    -- Trial
    is_trial BOOLEAN DEFAULT FALSE,
    trial_ends_at TIMESTAMP,
    
    -- Payment
    payment_method VARCHAR(50),
    payment_id VARCHAR(200),
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON subscriptions(status);

-- RLS
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access their own subscriptions" ON subscriptions FOR ALL USING (auth.uid() = user_id);
-- 010_notifications.sql

DROP TABLE IF EXISTS notifications CASCADE;

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    -- Notification Details
    type VARCHAR(50), -- reminder, alert, insight
    category VARCHAR(50), -- hydration, sleep, symptom
    
    -- Content
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    
    -- Scheduling
    scheduled_for TIMESTAMP NOT NULL,
    sent_at TIMESTAMP,
    
    -- Delivery
    delivery_status VARCHAR(20) DEFAULT 'pending', -- pending, sent, delivered, failed
    
    -- Interaction
    read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_scheduled ON notifications(scheduled_for);

-- RLS
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access their own notifications" ON notifications FOR ALL USING (auth.uid() = user_id);
