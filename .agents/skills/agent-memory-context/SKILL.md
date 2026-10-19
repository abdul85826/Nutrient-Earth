---
name: agent-memory-context
description: >-
  Agent memory and context engineering skill with Open Viking context retrieval.
  Use for designing episodic and semantic memory architectures, state compaction,
  hierarchical context caches, and cross-session retrieval.
metadata:
  author: ant-agent
  version: "1.0.0"
---

# Agent Memory & Open Viking Context Architecture

This skill defines structures for long-term agent memory, dynamic context assembly, and episodic knowledge indexing.

---

## 1. Memory Tiers

1. **Working Memory (In-Context)**:
   - Immediate conversation trajectory and tool responses.
   - Kept lean via rolling window summarization and automatic compaction near token thresholds.

2. **Episodic Memory (Task Logs & Sessions)**:
   - Stored in append-only JSONL format (`~/.ox/projects/`, transcript logs).
   - Records past decisions, user preferences, failed attempts, and error recovery steps.

3. **Semantic Memory (Knowledge Items / AGENTS.md)**:
   - Curated knowledge files (`AGENTS.md`, `README.md`, `metadata.json`).
   - Repository-specific patterns, coding standards, architecture rules.

---

## 2. Open Viking Context Assembly Pattern

The Open Viking architecture loads relevant context selectively without saturating the prompt:

```
[System Core Persona]
        │
        ├──> [Hierarchical Rules: AGENTS.md / GEMINI.md]
        │
        ├──> [Progressive Skill Registry (Names + Triggers Only)]
        │
        └──> [Dynamic Context Injector]
                 ├── Top-K Semantic Chunks (Vector Search / Grep)
                 └── Recent Episodic Summaries
```

### Context Compaction Strategy
- When conversations reach ~70% of the context window limit:
  1. Extract key milestones achieved and decisions made.
  2. Summarize discarded hypotheses or errors.
  3. Retain the initial user intent and currently pending tasks.
  4. Replace historical turns with a single structured summary block.

---

## 3. Storage & Schema Guidelines

For persistence of memory items in SQLite/Supabase:
```sql
CREATE TABLE IF NOT EXISTS agent_memory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('user_preference', 'architecture_decision', 'bug_resolution', 'domain_fact')),
    summary TEXT NOT NULL,
    detail JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_agent_memory_category ON agent_memory(category);
```
