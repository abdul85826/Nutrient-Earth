# Nutrient Earth Database Schema Documentation

This document contains the complete SQL structure mapping for the distributed Biological Operating System (BIOS).

## Schema Migration Script
Refer to the official Supabase migration: [20260517000000_production_framework.sql](file:///c:/Users/Abdul/Documents/NE_App/Nutrient_Earth/supabase/migrations/20260517000000_production_framework.sql)

## Key Entities
1. **users**: Tracks Core identity, onboarding state and registration parameters.
2. **user_profiles**: High-level dynamic activity and wellness goals.
3. **biological_profiles**: Core biomedical stats (height, weight, gender, digestive patterns, occupational stress parameters).
4. **daily_checkins**: Real-time hydration, sleep, stress, steps, and energy fluctuations.
5. **environmental_logs**: Ingestion of AQI, UV, temperature, pollen, and geolocation tracking.
6. **recovery_scores**: Biological engine output aggregates (fatigue index, inflammation index, sleep debt, nervous system strain).
7. **clinical_protocols**: RAG semantic database storing scientific research and vector embeddings for contextual recommendations.
8. **recommendations**: Custom tailored biological interventions linked to scientific protocols.
9. **ml_features**: Time-series features extracted for ML inference.
