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
