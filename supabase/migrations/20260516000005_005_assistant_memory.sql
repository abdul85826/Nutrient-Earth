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
