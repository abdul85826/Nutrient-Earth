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
