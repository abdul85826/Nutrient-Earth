# NUTRIENT EARTH: MASTER PROJECT HANDOFF

This document is the absolute source of truth for the Nutrient Earth project. If you are a new AI agent reading this, it contains the entire context, architecture, stack, rules, and priorities of the project. Read it completely before writing any code.

==================================================

## SECTION 1: PROJECT IDENTITY

*   **Project Name:** Nutrient Earth
*   **Vision:** To build the fundamental infrastructure that future AI systems will use to understand, optimize, and interact with human biology.
*   **Mission:** Create a capital-efficient, offline-first, privacy-respecting "Biological Operating System" that unifies disparate wearable data streams into a single, understandable source of truth.
*   **Long-Term Goal:** To become the standard contract layer between human biology and AI interventions.
*   **Product Philosophy:** Calm intelligence. We deliver actionable, evidence-based recommendations, not endless dashboards or annoying chatbots. 
*   **Target Users:** High-performers, biohackers, and individuals who want objective, data-driven optimization of their biology without being overwhelmed by metrics.
*   **Differentiation:** Deterministic safety. LLMs are used for *translation and refinement*, not for raw generation of medical/health advice. The underlying `BiologicalTwin` and `RecommendationEngine` are strict, typed, and fully deterministic.

==================================================

## SECTION 2: CURRENT STATUS

*   **Current Phase Completed:** Phase K.1 (Compilation Fixes & Android/Web Execution Authorization).
*   **Beta Readiness Status:** **92/100 (APPROVED FOR BETA)**. The MVP architecture is frozen and feature complete.
*   **Architecture Maturity:** Core Foundation is fully built. We have working implementations from local storage (Isar) up to the LangGraph orchestration layer.
*   **Known Blockers:** Compilation blockers (Isar JS large integer limits on web) have just been resolved. We are moving to emulator/physical device validation.
*   **Known Risks:** 
    1. Synchronous serialization of the massive `BiologicalTwinSnapshot` on the main thread may cause UI stutter on older devices.
    2. LLM Hallucinations during the `ExplanationAgent` phase if the JSON representation of the biological twin is too deep.

==================================================

## SECTION 3: COMPLETE ARCHITECTURE

### 1. Bootstrap Layer
*   **Purpose:** Orchestrates app startup, permissions, schema migrations, and local storage initialization.
*   **Files:** `lib/core/bootstrap/app_bootstrap.dart`, `BootstrapManager`.
*   **Status:** Complete. Handles Web/Mobile splits effectively and mitigates startup loops.

### 2. Identity Layer
*   **Purpose:** Manages Supabase Auth, UUID generation, and session state.
*   **Files:** `lib/core/services/supabase_service.dart`, `IsarIdentity`.
*   **Status:** Complete.

### 3. Guest Mode
*   **Purpose:** Allows users to interact with the app without an internet connection or Supabase account.
*   **Files:** `IsarIdentity` (isGuest flag).
*   **Status:** Complete.

### 4. Offline Layer
*   **Purpose:** Ensures the app remains 100% functional without an internet connection.
*   **Files:** Local interceptors, fallback logic.
*   **Status:** Complete. LangGraph degrades gracefully to local rigid templates if LLM APIs are unreachable.

### 5. Isar Layer
*   **Purpose:** High-performance, offline-first local database.
*   **Files:** `lib/infrastructure/local/isar_schemas.g.dart`, `lib/core/services/isar_service.dart`.
*   **Status:** Complete. Downgraded to Isar 3.0.5 for web support. Automated 53-bit JS precision clamping via `scripts/fix_isar_web.dart`.

### 6. Event System
*   **Purpose:** Ingests raw data from wearables.
*   **Files:** `lib/domain/models/events/...`
*   **Status:** Complete.

### 7. Timeline Engine
*   **Purpose:** Chronologically orders and normalizes disparate biological events.
*   **Files:** `TimelineEngine`.
*   **Status:** Complete.

### 8. Biological Twin
*   **Purpose:** The single source of truth. A living, unified snapshot of the user's biology derived from the Timeline Engine.
*   **Files:** `lib/domain/models/biological_twin/biological_models.dart`.
*   **Status:** Complete.

### 9. Intelligence Core
*   **Purpose:** Detects active patterns, anomalies, and calculates system-wide confidence scores based on data recency and quality.
*   **Files:** `IntelligenceCore`, `SafetyEngine`, `TrustEngine`.
*   **Status:** Complete.

### 10. Recommendation Engine
*   **Purpose:** Deterministically matches biological states to evidence-based interventions from the Knowledge Layer.
*   **Files:** `RecommendationEngine`.
*   **Status:** Complete.

### 11. Knowledge Layer
*   **Purpose:** The immutable library of scientific evidence, mechanisms of action, and intervention protocols.
*   **Files:** `KnowledgeBase`.
*   **Status:** Complete.

### 12. Trust Layer
*   **Purpose:** Ensures no recommendation violates user safety boundaries or conflicting protocols.
*   **Files:** `TrustEngine`, `SafetyEngine`.
*   **Status:** Complete.

### 13. LangGraph Layer
*   **Purpose:** Orchestrates the LLM to translate deterministic recommendations into calm, human-friendly insights.
*   **Files:** `lib/engine/langgraph/nutrient_earth_graph.dart`, `agents.dart`, `graph_state.dart`.
*   **Status:** Complete.

### 14. UI Layer
*   **Purpose:** Presents the data. Maximum 3 recommendations, 1 primary action. Calm interface.
*   **Files:** `TodayScreen`, `BodyScreen`, `InsightsScreen`.
*   **Status:** Complete.

==================================================

## SECTION 4: DOMAIN MODELS

*   **Biological States:** `BiologicalTwinSnapshot`, `HeartRateProfile`, `SleepProfile`, `RecoveryProfile`, `StressProfile`, `ActivePattern`, `ActiveAnomaly`.
*   **Events:** `BiometricEvent`, `WearableSyncEvent`, `UserLogEvent`.
*   **Recommendations:** `CandidateIntervention`, `ValidatedRecommendation`, `SuppressedRecommendation`.
*   **Knowledge Objects:** `ScientificProtocol`, `EvidenceReference`, `MechanismOfAction`.
*   **Wearable Models:** `WearableProvider`, `ProviderContract` (Apple Health, Oura, Garmin, Fitbit, WHOOP).
*   **Graph Models:** `GraphState`, `GraphExecutionLog`, `PromptRegistry`.

==================================================

## SECTION 5: DATABASE

*   **Platform:** Supabase (PostgreSQL).
*   **Schema:** 
    *   `users` (id, email, is_guest, created_at)
    *   `biometric_events` (id, user_id, provider, metric_type, value, timestamp)
    *   `twin_snapshots` (id, user_id, state_json, generated_at)
*   **Indexes:** B-Trees on `user_id` and `timestamp`. `pgvector` indexes prepared for future knowledge search.
*   **RLS (Row Level Security):** Strict policies ensuring `auth.uid() == user_id`. Guest data is purely local until synced.
*   **Migrations:** Managed via standard Supabase CLI migrations folder.

==================================================

## SECTION 6: LANGGRAPH

*   **GraphState:** The mutable state object carrying the `BiologicalTwinSnapshot`, `ActiveRecommendations`, and `ConfidenceProfile`. No LLM memory. State resets every execution.
*   **InsightAgent:** Generates factual observations based purely on the `ActivePatterns` array.
*   **RecommendationAgent:** Takes the output of the deterministic `RecommendationEngine` and formats it for presentation.
*   **ExplanationAgent:** Translates the rigid mechanism-of-action templates into human-friendly "Why?" text.
*   **Execution Flow:** `Snapshot` -> `InsightAgent` -> `RecommendationAgent` -> `[SafetyEngine Check]` -> `ExplanationAgent` -> `UI`.
*   **Safety Flow:** The `SafetyEngine` physically intercepts state between the Recommendation and Explanation agents. Any intervention contradicting an active medical or exertion protocol is forcefully removed and appended to the `GraphExecutionLog` as suppressed.

==================================================

## SECTION 7: TECH STACK

*   **Frontend:** Flutter (Dart).
*   **Backend:** Supabase (Auth, Postgres, Realtime, Storage).
*   **Local Storage:** Isar Database (v3.0.5 for web support).
*   **AI Compute:** Modal (Serverless Python), OpenRouter (API Gateway).
*   **LLMs:** Llama-3-70B (Primary), GPT-4o / Claude 3.5 Sonnet (Fallbacks).
*   **Hosting:** Vercel (Web), Cloudflare (DNS/Edge Cache).

*   **Rejected Technologies:** 
    *   Local GPU / Docker (Too heavy for thin-client founder workflow).
    *   Kubernetes (Overkill).
    *   Firebase / MongoDB (NoSQL is bad for relational health events).
    *   Pinecone (Using Supabase `pgvector` instead).
*   **Postponed Technologies:** Multi-region replication, complex microservices.
*   **Future Technologies:** Proprietary model fine-tuning.

==================================================

## SECTION 8: BUGS AND BLOCKERS

1.  **TrustEngine import issue:** RESOLVED. Pathing corrected.
2.  **Isar Web compatibility issue:** RESOLVED. Isar downgraded to 3.0.5. Automated `fix_isar_web.dart` script deployed to clamp 64-bit integers to JS-safe 53-bit integers.
3.  **Model constructor mismatches:** RESOLVED. Schema drift handled.
4.  **Onboarding continueLabel issue:** RESOLVED. Late initialization bug fixed.
5.  **Analyzer Warnings:** Minor dependency warnings exist (`analyzer` package mismatch), but `flutter analyze` shows zero critical project logic errors.
6.  **Technical Debt:** 
    *   `BiologicalTwinSnapshot` JSON serialization for LLMs is currently crude. LLMs may hallucinate deeply nested generic JSON. We need a markdown serializer for prompts.
    *   Heavy processing blocks the main thread on older devices. Needs Dart `Isolate` refactoring.

==================================================

## SECTION 9: PRODUCT PHILOSOPHY

**What Nutrient Earth IS NOT:**
*   It is NOT a generic fitness tracker.
*   It is NOT a chatbot you converse with.
*   It is NOT a dashboard that spams you with raw red/green numbers.
*   It is NOT an unconstrained "Agent Swarm" making blind medical guesses.

**What Nutrient Earth IS:**
*   A Biological Operating System.
*   Calm intelligence. The UI is quiet until an intervention is necessary.
*   Evidence-based guidance. Every recommendation maps directly to an immutable scientific protocol.

==================================================

## SECTION 10: NEXT PRIORITIES

*   **Priority 1:** Fix compilation *(COMPLETED)*
*   **Priority 2:** Android build *(COMPLETED)*
*   **Priority 3:** Android emulator testing *(CURRENT TARGET)*
*   **Priority 4:** Physical device testing
*   **Priority 5:** 5 beta users
*   **Priority 6:** 10 beta users
*   **Priority 7:** Wearable integrations (Connecting the contracts to live Apple/Oura APIs)

==================================================

## SECTION 11: STRICT RULES

1.  **Biological Twin is Source of Truth:** AI agents NEVER read raw wearable data. They only read the processed `BiologicalTwinSnapshot`.
2.  **No Recommendation Without Evidence:** Every insight must link to a `KnowledgeBase` reference.
3.  **No Recommendation Without Confidence:** If data is stale, the UI must explain the low confidence state, not invent a pattern.
4.  **Offline-First:** The app must launch, load the twin, and provide the determinist baseline without an internet connection.
5.  **Guest-First:** Users must be able to explore the UI and mock states before creating an account.
6.  **Human Simplicity:** Maximum 3 recommendations per day. 1 primary action.
7.  **No Agent Sprawl:** No autonomous web-browsing agents. No 10-agent swarms. Stick to the linear, observable LangGraph pipeline.
8.  **No Unnecessary Complexity:** Capital efficiency and execution speed are paramount. Use managed services and serverless until $1M+ ARR.

==================================================

## SECTION 12: FOUNDER NOTES

**To the next AI Assistant:**
Welcome to Nutrient Earth. We are building the foundational API for human biology.

**Where we are:** The core architecture is frozen. The app compiles. We just survived a brutal one-month roadblock regarding local database JS-compatibility, but we are through it. We are now in Phase K (Beta Validation).

**What matters:** Stability, deterministic safety, and a calm, trustworthy user experience. Do not get distracted by flashy new AI frameworks. 

**What must never change:** The strict separation between the deterministic `BiologicalTwin` (the hard truth) and the LLM `LangGraph` (the translator). We do not let LLMs guess biological states. If you introduce a hallucination vector into the health recommendations, the product dies. Keep it safe, keep it offline-first, keep it simple. Proceed directly to Priority 3.
