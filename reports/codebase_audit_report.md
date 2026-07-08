# Nutrient Earth — Codebase Audit & Triage Report

This report presents a structural compliance check of the Nutrient Earth codebase (Flutter client app + Supabase backend) against the **Biological Understanding Standard**.

---

## Part 1: Executive Summary

Our codebase currently exists in a dual state: a robust, offline-first production architecture built on the **Biological Twin** model, juxtaposed with duplicate legacy directories, mocked analytics dashboards, and ungrounded LLM cloud functions. 

To transition the product to a production-ready biological understanding system, we must systematically purge all dead boilerplate and ungrounded AI layers, while refactoring active UI and service modules that violate our safety and transparency principles.

---

## Part 2: Database Schema & Supabase Triage

### 1. Database Table Classifications

| Table Name | Source Migration / SQL Schema | Classification | Rationale & Violations |
| :--- | :--- | :--- | :--- |
| **users** | `20260613120000_biological_foundation.sql` | **KEEP** | Core user identity tracking table. Fully aligned with auth. |
| **guest_profiles** | `20260613120000_biological_foundation.sql` | **KEEP** | Supports the offline-first/anonymous onboarding flow. |
| **biological_events** | `20260613120000_biological_foundation.sql` | **KEEP** | Central event log capturing observations, confidence, severity, and causality chains. Fully aligned with **Rule 1 (Data Density/Uncertainty Tracking)** and **Rule 2 (Reasoning Trails)**. |
| **biological_states** | `20260613120000_biological_foundation.sql` | **KEEP** | Stores state snapshots, supporting confidence, uncertainty, temporal decay, and vector embeddings for similarity checks. |
| **wearable_snapshots** | `20260613120000_biological_foundation.sql` | **KEEP** | Local-first sync of raw wearable JSON payloads before processing. |
| **recommendations** | `20260613120000_biological_foundation.sql` | **KEEP** | Stores pipeline recommendations, expiration dates, and execution states. |
| **timeline_snapshots** | `20260613120000_biological_foundation.sql` | **KEEP** | Compressed historical records of overall score and biological age deltas. |
| **sync_queue** | `20260613120000_biological_foundation.sql` | **KEEP** | Manages server-side offline sync conflict resolution. |
| **audit_logs** | `20260613120000_biological_foundation.sql` | **KEEP** | HIPAA-compliant log tracking data modifications. |
| **feature_flags** | `20260613120000_biological_foundation.sql` | **KEEP** | Server-side feature flag settings. |
| **user_profiles** | `001_bios_foundation.sql` (old) | **DELETE** | **Duplicate/Legacy.** Superceded by the newer normalized `profiles` and `biological_profiles` tables. Using this old schema causes structural database drift. |
| **biological_history** | `001_bios_foundation.sql` (old) | **DELETE** | **Duplicate/Legacy.** Superceded by the normalized `biological_events` and `biological_states` tables. |
| **user_symptoms** | `20260426000000_health_intelligence_schema.sql` | **DELETE** | **Legacy.** Bypassed in favor of the newer `biological_events` schema with symptom tags. |
| **daily_progress** | `20260426000000_health_intelligence_schema.sql` | **DELETE** | **Legacy.** Superceded by the `daily_metrics` table. |
| **user_plans** | `20260426000000_health_intelligence_schema.sql` | **DELETE** | **Legacy.** Bypassed in favor of the new timeline snapshots and recommendation tables. |
| **chat_history** | `20260426000000_health_intelligence_schema.sql` | **DELETE** | **Violation of Rule 3 (No Black Box).** Backing table for an ungrounded chat interface that is not wired up in the client. |
| **user_outcomes** | `001_bios_foundation.sql` (old) | **DELETE** | **Legacy.** Superceded by recording outcomes as events inside `biological_events`. |
| **wearable_readings** | `001_bios_foundation.sql` (old) | **DELETE** | **Legacy.** Bypassed in favor of `wearable_snapshots`. |
| **audit_log** | `001_bios_foundation.sql` (old) | **DELETE** | **Duplicate.** Singly-named legacy log table replaced by `audit_logs` (plural). |
| **clinical_protocols** | `20260517000000_production_framework.sql` | **DELETE** | **Legacy.** Unused mock table from a prior iteration. |
| **adherence_logs** | `20260517000000_production_framework.sql` | **DELETE** | **Legacy.** Unused mock table. |
| **ml_features** | `20260517000000_production_framework.sql` | **DELETE** | **Legacy.** Unused mock table. |
| **recovery_scores** | `20260517000000_production_framework.sql` | **DELETE** | **Legacy.** Unused mock table. |
| **knowledge_chunks** | `001_bios_foundation.sql` | **REFACTOR** | Essential for RAG, but needs vector column declarations aligned with the newer schema naming conventions. |

### 2. Row Level Security (RLS) & Policies

All active tables created in `20260613120000_biological_foundation.sql` have RLS enabled and strictly lock data access to `auth.uid() = user_id`. 
* **Guest Access Policy**: `Guest access own events` and `Guest access own states` allow reads and writes using `guest_id IS NOT NULL AND auth.role() = 'anon'`. This is a clean, compliant implementation that maintains sandbox boundary rules.
* **Audit Logs Policy**: Enforces `No user audit access (FALSE)`, making the logs immutable and read-only, which complies with HIPAA requirements.

---

## Part 3: Backend Logic & Edge Functions Triage

### 1. Edge / Cloud Functions

| Component | Path | Classification | Rationale & Violations |
| :--- | :--- | :--- | :--- |
| **aiInsight** | `supabase/functions/aiInsight/index.ts` | **DELETE** | **Violation of Rule 1 (Fabricated Certainty), Rule 2 (Explainability), and Rule 3 (No Black Box).** <br>Contains static mock rules that hardcode insights (e.g., `"Your sugar level is high and stressing your pancreas."` if `sugar > 250`). Pushes hardcoded products (`Glucose Balance Mix`). It has zero clinical grounding and presents fabricated assessments as computed biological insights. |
| **Firebase Cloud Function** | `functions/index.js` | **DELETE** | **Violation of Rule 3 (No Black Box).** <br>Calls the Grok API with a general system prompt: `"You are a smart health and nutrition assistant. Give short, practical, modern advice."` It has no local database grounding, no safety constraints, and operates as a standard black-box chat bot. |

---

## Part 4: Flutter Client App Triage

### 1. Screen & UI Component Classifications

| Screen / Widget | File Path | Classification | Rationale & Violations |
| :--- | :--- | :--- | :--- |
| **SplashScreen** | `lib/features/splash/splash_screen.dart` | **KEEP** | Core UI boot shell. Renders friendly network/initialization error failsafes. |
| **AuthScreen** | `lib/features/auth/auth_screen.dart` | **KEEP** | Handles OAuth and Guest Mode startup transitions. |
| **OnboardingScreen** | `lib/features/onboarding/onboarding_screen.dart` | **KEEP** | Guides the user through demographic and medical family history onboarding. |
| **TodayScreen** | `lib/features/today/today_screen.dart` | **KEEP** | Active daily dashboard. Properly uses `TraceabilityBottomSheet` to render explainability trails. |
| **BodyScreen** | `lib/features/body/body_screen.dart` | **KEEP** | Displays data quality, twin completeness metrics, and missing check-in signals. |
| **InsightsScreen** | `lib/features/explore/insights_screen.dart` | **KEEP** | Chronological timeline log. Highlights source and confidence of biological data. |
| **MeScreen** | `lib/features/me/me_screen.dart` | **KEEP** | User settings and demographic profile inspector. |
| **UpgradeScreen** | `lib/features/monetization/upgrade_screen.dart` | **KEEP** | Basic mock subscription paywall. |
| **AlphaWelcomeScreen** | `lib/features/alpha/alpha_welcome_screen.dart` | **KEEP** | Essential alpha consent and legal compliance gate. |
| **FeedbackHubScreen** | `lib/features/alpha/feedback_hub_screen.dart` | **KEEP** | Facilitates internal test logs exports and bug reporting. |
| **DeveloperPlaygroundScreen** | `lib/features/debug/developer_playground_screen.dart` | **KEEP** | Debug utility for executing trace sequences through the core pipeline. |
| **ExploreScreen** | `lib/features/explore/explore_screen.dart` | **DELETE** | **Bypass/Boilerplate.** Static wellness blog viewer that is not wired up in the router. Represents legacy boilerplate. |
| **FounderDashboardScreen** | `lib/features/founder/founder_dashboard_screen.dart` | **DELETE** | **Boilerplate.** Faux analytics dashboard representing fabricated active user numbers and mock charts. Has no functional purpose in a local biological client app. |
| **StressTestPage** | `lib/features/testing/stress_test_page.dart` | **DELETE** | **Boilerplate.** Mock test page executing simple animation timers rather than testing actual engines. |

### 2. State Management & Service Classifications

| Class / Provider | File Path | Classification | Rationale & Violations |
| :--- | :--- | :--- | :--- |
| **BootstrapManager** | `lib/core/services/bootstrap_manager.dart` | **KEEP** | Coordinates startup routing and guest status evaluation. |
| **IdentityManager** | `lib/core/services/identity_manager.dart` | **KEEP** | Manages local-first UUIDs and guest profile migrations. |
| **ObservationEngine** | `lib/core/services/observation_engine.dart` | **KEEP** | Handles logging of energy, sleep, mood, and stress to Isar. |
| **BaselineEngine** | `lib/core/services/baseline_engine.dart` | **KEEP** | **Crucial Biological Gate.** Analyzes check-in history to determine baseline phase (Stable vs. Determining) before running calibrations. |
| **UserStateEngine** | `lib/core/services/user_state_engine.dart` | **KEEP** | Evaluates checklist completion and data completeness percentages. |
| **LocalStorageService** | `lib/core/services/local_storage_service.dart` | **KEEP** | Local DB interface resolver. |
| **Isar Schemas** | `lib/infrastructure/local/isar_schemas.dart` | **KEEP** | Database schema models for offline storage. Fully aligned with the newer June migrations. |
| **SupabaseService** | `lib/core/services/supabase_service.dart` | **REFACTOR** | Core cloud database interface. Must be refactored because some methods write flat maps into the old `user_profiles` table layout instead of utilizing the newer `profiles` and `biological_profiles` normalized tables. |
| **GraphNotifier** | `lib/core/providers/graph_provider.dart` | **REFACTOR** | **Violation of Rule 1 (Fabricated Certainty) and Rule 3 (No Black Box).** <br>The notifier completely bypasses the LangGraph agent chain and executes a simple hardcoded local fallback rule. The fallback rules must be made transparent or integrated with the core engine pipeline rather than being isolated inside a state provider. |
| **BiologicalEngine** | `lib/engine/biological_engine.dart` | **REFACTOR** | **Violation of Rule 2 (Explainability) and Rule 4 (Real Science).** <br>Executes static calculations for allostatic load and BMI. Its recovery action suggestions are static strings (e.g., `'Drink 500ml of mineralized water'`) instead of matching data from the core `EvidenceMatchingEngine`. It should be merged/refactored into the core engine pipeline. |
| **WearableIngestionPipeline** | `lib/wearable/ingestion/wearable_ingestion_pipeline.dart` | **REFACTOR** | Provides Garmin/Oura adapter interfaces but is not wired up. Refactor to feed biometric telemetry directly into the `ObservationEngine` flow. |
| **StripeService** | `lib/core/services/stripe_service.dart` | **DELETE** | **Unused/Boilerplate.** Fully mocked payment processing class. |
| **RedisService** | `lib/core/services/redis_service.dart` | **DELETE** | **Unused/Boilerplate.** Server-side client class mistakenly committed in client project. |
| **ProductIntelligenceService** | `lib/core/services/product_intelligence_service.dart` | **DELETE** | **Violation of Rule 1.** Pushes simulated analytics (e.g. active users) to the founder dashboard. |
| **DIContainer / BiosProviders** | `lib/core/di/di_container.dart` / `lib/core/providers/bios_providers.dart` | **DELETE** | **Legacy Boilerplate.** Declares providers for long-since-deleted or bypassed classes. |
| **BiologicalScoringEngine / BehavioralEngine / etc.** | `lib/engines/...` | **DELETE** | **Legacy.** Redundant duplicates of calculations now handled in `lib/core/engine/...`. |
| **ScoringPipeline / RecommendationPipeline** | `lib/pipelines/...` | **DELETE** | **Legacy.** Unused pipeline classes from early boilerplate structure. |
| **BiologicalEngine (Core Duplicate)** | `lib/core/engine/biological_engine.dart` | **DELETE** | Duplicate definition of the calculation logic in `lib/engine/`. |

---

## Part 5: Core Engine Pipeline

The pipeline under `lib/core/engine/` is a solid, deterministic, and highly compliant implementation of our biological pipeline.

```
Reality (Check-in/Sensors) 
   ↓
ObservationEngine (Registers logs in Isar)
   ↓
BiologicalUnderstandingEngine (Computes status, data density, confidence & gaps)
   ↓
EvidenceMatchingEngine (Matches active conditions to knowledge base nodes)
   ↓
DecisionIntelligenceEngine (Sorts priorities based on severity & confidence)
   ↓
HumanAdaptationEngine (Evaluates behavioral friction & maps micro-steps)
   ↓
Action (Pushed to UI)
```

### Detailed Evaluation of Core Engines (KEEP):
1. **BiologicalUnderstandingEngine** (`lib/core/engine/understanding/biological_understanding_engine.dart`): Deterministically computes status (Optimal, Degrading, Critical) and maps data density to confidence values (e.g., 7 days of sleep data = 100% confidence). Identifies missing data signals as gaps, strictly complying with **Rule 1 (Fabricated Certainty)**.
2. **EvidenceMatchingEngine** (`lib/core/engine/knowledge/evidence_matching_engine.dart`): Cross-references degrading biological domains with clinical knowledge structures in `KnowledgeRepository`, ensuring all insights are anchored in science, satisfying **Rule 2 (Explainability)**.
3. **DecisionIntelligenceEngine** (`lib/core/engine/decision/decision_intelligence_engine.dart`): Calculates priority weights by balancing severity and data confidence:
   $$\text{Priority} = (\text{Severity} \times 0.7) + (\text{Confidence} \times 0.3)$$
   If confidence is below 0.5, it sets the readiness level to `lowConfidence` and recommends `'collect_more_data'` rather than fabricating an intervention, satisfying **Rule 1**.
4. **HumanAdaptationEngine** (`lib/core/engine/adaptation/human_adaptation_engine.dart`): Models user behavioral momentum and friction, scaling back recommendation size to matches the user's current capacity (e.g., converting a high-friction protocol into a micro-step if adherence probability falls below 60%).

---

## Part 6: Detailed Rule Violations

The following detailed descriptions outline violations of the **5 Biological Understanding Rules** within files marked `DELETE` or `REFACTOR`:

### 1. Violation of Rule 1 (No Fabricated Certainty)
* **`supabase/functions/aiInsight/index.ts` (Edge Function)**: Fabricates clinical states directly. If a user logs `sugar > 250`, it responds with a fixed diagnosis (`"Your sugar level is high and stressing your pancreas."`) without knowing if the user is fasting, post-prandial, or if this is a single reading error. It operates with 100% false certainty.
* **`lib/core/providers/graph_provider.dart` (GraphNotifier)**: Bypasses the active LangGraph/agent pipeline. When data is missing, it falls back to a static, hardcoded state estimation instead of raising uncertainty bounds or declaring a data gap.

### 2. Violation of Rule 2 (Every Conclusion Must Be Explainable)
* **`lib/engine/biological_engine.dart`**: Calculates metabolic loads and recovery scores via closed static functions. When a user taps a calculated score, there is no underlying trail or data point hierarchy to show *why* the score was given—violating the traceability standard.

### 3. Violation of Rule 3 (No Black Box)
* **`functions/index.js` (Firebase Cloud Function)**: Feeds raw, ungrounded prompts straight to Grok-beta:
  `messages: [{role: "system", content: "You are a smart health and nutrition assistant. Give short, practical, modern advice."}]`
  This lacks local domain knowledge constraints, patient baseline contexts, or validation, letting the model hallucinate recommendations with zero grounding.

### 4. Violation of Rule 4 (Simple Language, Real Science)
* **`supabase/functions/aiInsight/index.ts` (Edge Function)**: Recommends proprietary products (`Glucose Balance Mix`, `Heart Calm Blend`, `Energy Rise Elixir`) to address serious physiological markers like elevated blood pressure or high glucose, prioritizing commerce over objective science.

### 5. Violation of Rule 5 (No Fear, No Shame, No Hype)
* **`lib/features/founder/founder_dashboard_screen.dart`**: Contains hyped analytics and fabricated active user numbers (e.g. 1,245 active today) intended to impress stakeholders rather than objectively mirroring system status.

---

## Part 7: Action Plan & Safe Cleanup Path

To clean up the codebase safely without breaking active workflows or tests:

1. **Phase 1: DB Cleanup (Supabase)**
   * Drop obsolete tables: `user_symptoms`, `daily_progress`, `user_plans`, `chat_history`, `user_outcomes`, `wearable_readings`, `audit_log`, `clinical_protocols`, `adherence_logs`, `ml_features`, `recovery_scores`.
   * Keep the active table structures defined in the `20260613120000_biological_foundation.sql` migration.
   
2. **Phase 2: Backend Cloud Cleanup**
   * Delete `supabase/functions/aiInsight` directory.
   * Delete root-level `functions/` directory (Firebase).
   
3. **Phase 3: Client App Directory Purge**
   * Delete redundant folders: `lib/engines/` and `lib/pipelines/`.
   * Delete duplicate files: `lib/core/engine/biological_engine.dart`.
   * Delete dead services: `lib/core/services/stripe_service.dart`, `lib/core/services/redis_service.dart`, `lib/core/services/product_intelligence_service.dart`.
   * Remove references in `lib/core/di/di_container.dart` and `lib/core/providers/bios_providers.dart`, then delete these provider configuration files.
   * Delete unused screens: `lib/features/explore/explore_screen.dart`, `lib/features/founder/` folder, and `lib/features/testing/` folder.
   
4. **Phase 4: Client Code Refactoring**
   * Refactor `SupabaseService` to map profile edits to the normalized `profiles` and `biological_profiles` tables.
   * Refactor `GraphNotifier` in `lib/core/providers/graph_provider.dart` to query outputs from the core deterministic `PipelineOrchestrator` run, linking UI twin visualization to real pipeline outputs instead of bypassed mock states.
   * Merge `lib/engine/biological_engine.dart` into `lib/core/engine/understanding/biological_understanding_engine.dart`, aligning allostatic load math with data density weights.
   * Update the GoRouter configuration in `lib/core/router/app_router.dart` to remove routes for deleted pages (e.g., explore dashboard, founder analytics).
