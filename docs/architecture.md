# Biological Intelligence Operating System (BIOS) Blueprint

This document details the high-performance architectural systems defining the Nutrient Earth BIOS infrastructure.

```mermaid
graph TD
    User([User Intake / Telemetry]) -->|Ingest| Orchestrator[Biological Orchestrator]
    
    subgraph Core Engines
        Orchestrator -->|Evaluate| EnvEngine[Environmental Engine]
        Orchestrator -->|Simulate| DigitalTwin[Digital Twin State Engine]
        Orchestrator -->|Verify Limits| RuleEngine[Adaptive Rule Engine]
    end

    subgraph Data Pipeline
        DigitalTwin -->|Extract Features| FeatureStore[(ML Feature Store)]
        Orchestrator -->|Event Bus| EventBus[Asynchronous Event Bus]
    end

    subgraph AI Retrieval (RAG)
        Orchestrator -->|Trigger Context| RAGPipeline[RAG Context Retriever]
        RAGPipeline -->|Vector Match| PgVector[(Supabase pgvector)]
    end

    subgraph Swappable LLM Logic
        Orchestrator -->|Prompt Render| PromptOrch[Prompt Orchestration]
        PromptOrch -->|Adapter Contract| LLMAdapter[Multi-Provider LLM Gateway]
    end

    EventBus -->|Async Listeners| PubSub[Event Driven Handlers]
    LLMAdapter -->|Generate Protocol| RecPipeline[Recommendation Pipeline]
    RecPipeline -->|Intervention| User
```

---

## Clean Architecture Layers

Nutrient Earth is strictly separated to guarantee modularity and swappability of all subsystems:

1. **Domain Layer (`lib/domain`)**: Holds raw immutable human biological entities, survival verification thresholds, and core persistence interfaces. Absolutely isolated from frameworks.
2. **Core Layer (`lib/core`)**: Implements foundational cross-cutting concerns:
   - **Event Bus**: Broker facilitating pub-sub events (`OnboardingCompleted`, `RecoveryRecalculated`).
   - **Errors**: Failures encapsulating precise clinical violation codes.
   - **Security**: Fingerprinting, obfuscation, encryption, and HIPAA compliance rate gates.
   - **Cache**: Fast key-value memory blocks preparing for Redis clustering.
   - **Observability**: Metrics tracers measuring engine latencies.
3. **Engines (`lib/engines`)**: The biological computing runtimes:
   - **Environmental Engine**: Evaluates climate stress multipliers based on temperature, AQI, and UV indexes.
   - **Digital Twin Engine**: Simulates baseline biological fatigue, metabolic stress, and inflammatory metrics.
   - **Rule Engine**: Clinically validates structural overrides (e.g. Zone 2 exercise boundaries under severe nervous strain).
   - **Orchestration**: Runs systemic calibration loops, firing stream events and syncing profiles.
4. **Retrieval Layer (`lib/rag`)**: Interfaces semantic memory search and clinical document ingestion matching `pgvector` parameters.
5. **AI Reasoning (`lib/ai`)**: Manages model templates, Structured JSON validation wrappers, and swappable model provider channels.

---

## Machine Learning Framework (Feature Store)

The `BiologicalFeatureStore` bridges continuous biometric feeds with automated modeling:
- **Rolling Windows**: Calculates 7-day average metrics (sleep, hydration volume) for clinical stability tracking.
- **Velocity Vectors**: Captures rate of change (e.g. fatigue slopes over a 3-day window) for predictive intervention scaling.
- **Model Registry**: Establishes registry contracts to manage shadow deployments and model traffic splits.
