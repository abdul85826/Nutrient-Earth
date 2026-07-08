-- Drop obsolete legacy tables from Nutrient Earth BIOS database.
-- Relies on Phase 1 client service refactoring having been successfully verified.

DROP TABLE IF EXISTS user_symptoms CASCADE;
DROP TABLE IF EXISTS daily_progress CASCADE;
DROP TABLE IF EXISTS user_plans CASCADE;
DROP TABLE IF EXISTS chat_history CASCADE;
DROP TABLE IF EXISTS user_outcomes CASCADE;
DROP TABLE IF EXISTS wearable_readings CASCADE;
DROP TABLE IF EXISTS audit_log CASCADE;
DROP TABLE IF EXISTS clinical_protocols CASCADE;
DROP TABLE IF EXISTS adherence_logs CASCADE;
DROP TABLE IF EXISTS ml_features CASCADE;
DROP TABLE IF EXISTS recovery_scores CASCADE;
DROP TABLE IF EXISTS biological_history CASCADE;
DROP TABLE IF EXISTS user_profiles CASCADE;
