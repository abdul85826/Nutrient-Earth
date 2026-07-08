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
