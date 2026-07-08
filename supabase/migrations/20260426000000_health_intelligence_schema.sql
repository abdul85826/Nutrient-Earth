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
