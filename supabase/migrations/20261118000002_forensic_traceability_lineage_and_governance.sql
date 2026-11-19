-- ==============================================================================
-- Migration: 20261118000002_forensic_traceability_lineage_and_governance.sql
-- Description: Advanced Systems Engineering Controls:
--              1. End-to-End Forensic Traceability (OpenTelemetry-compatible)
--              2. Knowledge Lineage Graph (Relational Provenance & Impact Analysis)
--              3. Governed Bitemporal Memory Lifecycle & Recomputation Tracking
--              4. Decision Traceability (Structured rationale without CoT leaks)
--              5. Zero-Trust Security, Least Privilege & Consent Ledger
--              6. Reproducible AI Execution Records & Model Governance
--              7. Transactional Outbox for Durable Job Execution
--              8. Idempotency Keys & Content Integrity
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. FORENSIC TRACES & SPANS (OpenTelemetry-Compatible Trace Ledger)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.forensic_traces (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trace_id TEXT NOT NULL,
    request_id TEXT NOT NULL,
    session_id TEXT,
    actor_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    tenant_id TEXT NOT NULL DEFAULT 'default',
    entry_operation_type TEXT NOT NULL,
    service_version TEXT NOT NULL DEFAULT '2.0.0',
    status TEXT NOT NULL CHECK (status IN ('started', 'succeeded', 'failed', 'cancelled')),
    start_time TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    end_time TIMESTAMPTZ,
    duration_ms INT,
    error_summary TEXT,
    correlation_identifiers JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_forensic_traces_trace_id ON public.forensic_traces(trace_id);
CREATE INDEX IF NOT EXISTS idx_forensic_traces_actor ON public.forensic_traces(actor_id, start_time DESC);
CREATE INDEX IF NOT EXISTS idx_forensic_traces_status ON public.forensic_traces(status, start_time DESC);

ALTER TABLE public.forensic_traces ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own forensic traces"
    ON public.forensic_traces FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = actor_id);

CREATE POLICY "Users can insert own forensic traces"
    ON public.forensic_traces FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = actor_id OR actor_id IS NULL);

-- Trace Spans (Sub-operations across services, specialists, and models)
CREATE TABLE IF NOT EXISTS public.trace_spans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trace_id TEXT NOT NULL,
    span_id TEXT NOT NULL,
    parent_span_id TEXT,
    operation_name TEXT NOT NULL,
    service_component TEXT NOT NULL, -- e.g. 'orchestrator', 'food_science', 'multimodal_gateway'
    status TEXT NOT NULL CHECK (status IN ('ok', 'error', 'cancelled')),
    start_time TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    end_time TIMESTAMPTZ,
    duration_ms INT,
    sanitized_attributes JSONB DEFAULT '{}'::jsonb, -- Strict NO PII / NO SECRETS
    error_details JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_trace_span UNIQUE (trace_id, span_id)
);

CREATE INDEX IF NOT EXISTS idx_trace_spans_trace ON public.trace_spans(trace_id, start_time);
CREATE INDEX IF NOT EXISTS idx_trace_spans_op ON public.trace_spans(service_component, operation_name);

ALTER TABLE public.trace_spans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view spans of own traces"
    ON public.trace_spans FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.forensic_traces t
            WHERE t.trace_id = trace_spans.trace_id
              AND t.actor_id = (SELECT auth.uid())
        )
    );

-- ------------------------------------------------------------------------------
-- 2. KNOWLEDGE LINEAGE GRAPH (Relational Provenance & Impact Analysis)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.knowledge_lineage_nodes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    node_type TEXT NOT NULL CHECK (
        node_type IN (
            'user_input',
            'extracted_fact',
            'personal_memory_version',
            'retrieved_context',
            'evidence_document',
            'scientific_claim',
            'evidence_assessment',
            'decision_record',
            'recommendation_task',
            'outcome_telemetry'
        )
    ),
    entity_id TEXT NOT NULL, -- Logical ID of target entity
    entity_table TEXT NOT NULL, -- Target table name
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    content_hash_sha256 TEXT NOT NULL,
    transformation_version TEXT NOT NULL DEFAULT '1.0',
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_lineage_node UNIQUE (node_type, entity_id)
);

CREATE INDEX IF NOT EXISTS idx_lineage_nodes_user ON public.knowledge_lineage_nodes(user_id, node_type);
CREATE INDEX IF NOT EXISTS idx_lineage_nodes_entity ON public.knowledge_lineage_nodes(entity_table, entity_id);

ALTER TABLE public.knowledge_lineage_nodes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own lineage nodes"
    ON public.knowledge_lineage_nodes FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id OR user_id IS NULL);

-- Directed Provenance Edges (Many-to-Many Relationships)
CREATE TABLE IF NOT EXISTS public.knowledge_lineage_edges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_node_id UUID NOT NULL REFERENCES public.knowledge_lineage_nodes(id) ON DELETE CASCADE,
    target_node_id UUID NOT NULL REFERENCES public.knowledge_lineage_nodes(id) ON DELETE CASCADE,
    relationship_type TEXT NOT NULL CHECK (
        relationship_type IN (
            'extracted_from',
            'versioned_as',
            'retrieved_for',
            'corroborates',
            'contradicts',
            'influenced_by',
            'resulted_in',
            'superseded_by'
        )
    ),
    transformation_applied TEXT,
    confidence_weight NUMERIC(3,2) NOT NULL DEFAULT 1.00 CHECK (confidence_weight BETWEEN 0.00 AND 1.00),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_lineage_edge UNIQUE (source_node_id, target_node_id, relationship_type)
);

CREATE INDEX IF NOT EXISTS idx_lineage_edges_source ON public.knowledge_lineage_edges(source_node_id);
CREATE INDEX IF NOT EXISTS idx_lineage_edges_target ON public.knowledge_lineage_edges(target_node_id);

ALTER TABLE public.knowledge_lineage_edges ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view lineage edges for own nodes"
    ON public.knowledge_lineage_edges FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.knowledge_lineage_nodes n
            WHERE (n.id = source_node_id OR n.id = target_node_id)
              AND (n.user_id = (SELECT auth.uid()) OR n.user_id IS NULL)
        )
    );

-- Recursive Provenance Traversal Function: Downstream Impact Analysis
CREATE OR REPLACE FUNCTION public.get_downstream_impact(p_root_node_id UUID, p_max_depth INT DEFAULT 5)
RETURNS TABLE (
    depth INT,
    node_id UUID,
    node_type TEXT,
    entity_id TEXT,
    entity_table TEXT,
    relationship_type TEXT
)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    WITH RECURSIVE impact_tree AS (
        -- Anchor member
        SELECT 
            1 AS depth,
            e.target_node_id AS node_id,
            n.node_type,
            n.entity_id,
            n.entity_table,
            e.relationship_type
        FROM public.knowledge_lineage_edges e
        JOIN public.knowledge_lineage_nodes n ON n.id = e.target_node_id
        WHERE e.source_node_id = p_root_node_id

        UNION ALL

        -- Recursive member
        SELECT 
            it.depth + 1,
            e.target_node_id AS node_id,
            n.node_type,
            n.entity_id,
            n.entity_table,
            e.relationship_type
        FROM impact_tree it
        JOIN public.knowledge_lineage_edges e ON e.source_node_id = it.node_id
        JOIN public.knowledge_lineage_nodes n ON n.id = e.target_node_id
        WHERE it.depth < p_max_depth
    )
    SELECT DISTINCT ON (node_id) 
        depth, node_id, node_type, entity_id, entity_table, relationship_type
    FROM impact_tree
    ORDER BY node_id, depth;
$$;

-- ------------------------------------------------------------------------------
-- 3. GOVERNED MEMORY LIFECYCLE & DEPENDENCY RECOMPUTATION
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.memory_lifecycle_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fact_id UUID NOT NULL REFERENCES public.bitemporal_personal_facts(id) ON DELETE CASCADE,
    version_id UUID REFERENCES public.bitemporal_fact_versions(id) ON DELETE SET NULL,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL CHECK (
        event_type IN (
            'created',
            'superseded',
            'corrected',
            'corroborated',
            'disputed',
            'soft_deleted',
            'purged'
        )
    ),
    actor_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    previous_value JSONB,
    new_value JSONB,
    rationale TEXT NOT NULL,
    correction_reference TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_memory_events_fact ON public.memory_lifecycle_events(fact_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_memory_events_user ON public.memory_lifecycle_events(user_id, created_at DESC);

ALTER TABLE public.memory_lifecycle_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own memory lifecycle events"
    ON public.memory_lifecycle_events FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

-- Memory Dependency Tracking Table (Identifies derived artifacts requiring recomputation)
CREATE TABLE IF NOT EXISTS public.memory_dependencies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    source_fact_id UUID NOT NULL REFERENCES public.bitemporal_personal_facts(id) ON DELETE CASCADE,
    source_version_id UUID REFERENCES public.bitemporal_fact_versions(id) ON DELETE SET NULL,
    dependent_entity_type TEXT NOT NULL CHECK (
        dependent_entity_type IN (
            'summary',
            'vector_embedding',
            'baseline_metric',
            'recommendation_template',
            'active_today_card',
            'movement_task'
        )
    ),
    dependent_entity_id TEXT NOT NULL,
    recomputation_status TEXT NOT NULL DEFAULT 'valid' CHECK (
        recomputation_status IN ('valid', 'stale_pending_recompute', 'recomputing', 'recomputed', 'invalidated_purged')
    ),
    invalidation_reason TEXT,
    stale_at TIMESTAMPTZ,
    recomputed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_memory_dependency UNIQUE (source_fact_id, dependent_entity_type, dependent_entity_id)
);

CREATE INDEX IF NOT EXISTS idx_memory_deps_stale ON public.memory_dependencies(user_id, recomputation_status)
    WHERE recomputation_status = 'stale_pending_recompute';

ALTER TABLE public.memory_dependencies ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own memory dependencies"
    ON public.memory_dependencies FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

-- Trigger: On fact correction/supersession, mark dependencies as stale
CREATE OR REPLACE FUNCTION public.trg_mark_memory_dependencies_stale()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.memory_dependencies
    SET recomputation_status = 'stale_pending_recompute',
        invalidation_reason = 'Upstream fact superseded or corrected by event: ' || NEW.event_type,
        stale_at = timezone('utc'::text, now())
    WHERE source_fact_id = NEW.fact_id
      AND recomputation_status = 'valid';
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_memory_lifecycle_mark_stale ON public.memory_lifecycle_events;
CREATE TRIGGER on_memory_lifecycle_mark_stale
    AFTER INSERT ON public.memory_lifecycle_events
    FOR EACH ROW
    WHEN (NEW.event_type IN ('superseded', 'corrected', 'soft_deleted', 'purged'))
    EXECUTE FUNCTION public.trg_mark_memory_dependencies_stale();

-- ------------------------------------------------------------------------------
-- 4. DECISION TRACEABILITY (Structured Explanations Without CoT Leaks)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.decision_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trace_id TEXT NOT NULL,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    recommendation_id TEXT NOT NULL,
    user_objective TEXT NOT NULL,
    context_snapshot_ref JSONB NOT NULL DEFAULT '{}'::jsonb,
    personal_state_version TEXT NOT NULL,
    retrieved_evidence_refs JSONB NOT NULL DEFAULT '[]'::jsonb,
    applicable_safety_rules JSONB NOT NULL DEFAULT '[]'::jsonb,
    dietary_constraints JSONB NOT NULL DEFAULT '[]'::jsonb,
    relevant_preferences JSONB NOT NULL DEFAULT '[]'::jsonb,
    calculation_references JSONB NOT NULL DEFAULT '{}'::jsonb,
    selected_recommendation JSONB NOT NULL,
    alternatives_considered JSONB NOT NULL DEFAULT '[]'::jsonb, -- Includes rejection reasons
    confidence_score NUMERIC(3,2) NOT NULL DEFAULT 1.00 CHECK (confidence_score BETWEEN 0.00 AND 1.00),
    uncertainty_disclosure TEXT NOT NULL,
    decision_policy_version TEXT NOT NULL DEFAULT '2026.11.1',
    model_execution_ref TEXT,
    final_delivered_output TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_decision_records_user ON public.decision_records(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_decision_records_trace ON public.decision_records(trace_id);

ALTER TABLE public.decision_records ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own decision records"
    ON public.decision_records FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can insert own decision records"
    ON public.decision_records FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- ------------------------------------------------------------------------------
-- 5. REPRODUCIBLE AI EXECUTION RECORDS & GOVERNANCE
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ai_execution_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trace_id TEXT NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    model_provider TEXT NOT NULL, -- e.g. 'gemini', 'groq', 'deepseek', 'local_deterministic'
    model_identifier TEXT NOT NULL, -- e.g. 'gemini-1.5-pro', 'llama-3.3-70b-versatile'
    model_version TEXT,
    prompt_template_id TEXT NOT NULL,
    prompt_template_version TEXT NOT NULL,
    system_policy_version TEXT NOT NULL,
    input_schema_version TEXT NOT NULL DEFAULT '1.0',
    output_schema_version TEXT NOT NULL DEFAULT '1.0',
    context_references JSONB NOT NULL DEFAULT '[]'::jsonb,
    retrieved_document_versions JSONB NOT NULL DEFAULT '[]'::jsonb,
    tool_allowlist_used JSONB NOT NULL DEFAULT '[]'::jsonb,
    tool_executions JSONB NOT NULL DEFAULT '[]'::jsonb,
    calculation_version TEXT NOT NULL DEFAULT '1.0',
    safety_policy_version TEXT NOT NULL DEFAULT '2026.11.1',
    input_hash_sha256 TEXT NOT NULL,
    output_hash_sha256 TEXT NOT NULL,
    is_deterministic BOOLEAN NOT NULL DEFAULT false,
    execution_duration_ms INT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_ai_exec_trace ON public.ai_execution_records(trace_id);
CREATE INDEX IF NOT EXISTS idx_ai_exec_model ON public.ai_execution_records(model_provider, model_identifier);

ALTER TABLE public.ai_execution_records ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own AI execution records"
    ON public.ai_execution_records FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id OR user_id IS NULL);

-- Governance Version Registry
CREATE TABLE IF NOT EXISTS public.governance_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type TEXT NOT NULL CHECK (
        entity_type IN ('model', 'prompt_template', 'system_policy', 'safety_rule', 'tool_definition', 'embedding_model')
    ),
    entity_identifier TEXT NOT NULL,
    version TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('draft', 'canary', 'active', 'deprecated', 'revoked')),
    evaluation_score NUMERIC(4,3),
    release_notes TEXT,
    approved_by TEXT,
    approved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_governance_version UNIQUE (entity_type, entity_identifier, version)
);

ALTER TABLE public.governance_versions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All authenticated users can read governance versions"
    ON public.governance_versions FOR SELECT
    TO authenticated
    USING (true);

-- ------------------------------------------------------------------------------
-- 6. PURPOSE-BASED CONSENT LEDGER (Zero-Trust Privacy)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.user_consent_ledger (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    purpose TEXT NOT NULL CHECK (
        purpose IN (
            'clinical_telemetry_sync',
            'bitemporal_memory_profiling',
            'proactive_nudges_circadian',
            'food_intolerance_analysis',
            'anonymized_research_contribution'
        )
    ),
    purpose_version TEXT NOT NULL DEFAULT '1.0',
    is_granted BOOLEAN NOT NULL,
    granted_at TIMESTAMPTZ,
    revoked_at TIMESTAMPTZ,
    ip_hash_sha256 TEXT,
    user_agent_category TEXT,
    audit_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_consent_ledger_user ON public.user_consent_ledger(user_id, purpose, is_granted);

ALTER TABLE public.user_consent_ledger ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own consent ledger"
    ON public.user_consent_ledger FOR ALL
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- ------------------------------------------------------------------------------
-- 7. TRANSACTIONAL OUTBOX FOR DURABLE JOB EXECUTION
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.transactional_outbox (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trace_id TEXT NOT NULL,
    aggregate_type TEXT NOT NULL, -- e.g. 'memory', 'research', 'notification', 'recommendation'
    aggregate_id TEXT NOT NULL,
    event_type TEXT NOT NULL,
    payload JSONB NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (
        status IN ('pending', 'processing', 'completed', 'failed', 'dead_letter')
    ),
    retry_count INT NOT NULL DEFAULT 0,
    max_retries INT NOT NULL DEFAULT 5,
    next_retry_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    locked_until TIMESTAMPTZ,
    locked_by TEXT,
    dead_letter_reason TEXT,
    idempotency_key TEXT UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_outbox_pending ON public.transactional_outbox(status, next_retry_at)
    WHERE status IN ('pending', 'failed');

ALTER TABLE public.transactional_outbox ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own outbox events"
    ON public.transactional_outbox FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.forensic_traces t
            WHERE t.trace_id = transactional_outbox.trace_id
              AND t.actor_id = (SELECT auth.uid())
        )
    );

-- ------------------------------------------------------------------------------
-- 8. IDEMPOTENCY KEYS (Deduplication & Transaction Integrity)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.idempotency_keys (
    key TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    endpoint_or_operation TEXT NOT NULL,
    request_hash_sha256 TEXT NOT NULL,
    response_payload JSONB,
    status TEXT NOT NULL CHECK (status IN ('in_flight', 'completed', 'failed')),
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_idempotency_expires ON public.idempotency_keys(expires_at);

ALTER TABLE public.idempotency_keys ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view and check own idempotency keys"
    ON public.idempotency_keys FOR ALL
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);
