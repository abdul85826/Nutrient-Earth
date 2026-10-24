---
name: gbrain-skills-hub
description: >-
  Garry Tan's GBrain long-term memory graph, PGLite local database, and 75-skill hub.
  Use for persistent memory operations, cross-session fact recall, knowledge capture,
  graph synthesis, and running MCP memory verbs (recall, entity, synthesize).
metadata:
  author: ant-agent
  version: "0.60.356"
---

# GBrain — Persistent Knowledge Graph & Skills Hub

GBrain (`garrytan/gbrain`) is an opinionated, long-term memory engine and skill hub authored by Garry Tan. It eliminates context loss by maintaining a self-wiring knowledge graph powered by local PGLite (embedded Postgres).

---

## 1. Environment & Database Paths

- **Global CLI Command**: `gbrain` (globally executable via terminal)
- **Binary Path**: `C:\Users\admin\.bun\bin\gbrain.exe`
- **Database (PGLite)**: `C:\Users\admin\.gbrain\brain.pglite`
- **Content Store**: `C:\Users\admin\.gbrain\content\`
- **Packaged Skills**: 75 canonical prose skills loaded (`skills/RESOLVER.md`)

---

## 2. Core Memory Operations

### Remembering Facts
Save durable user preferences, design choices, and architectural decisions with provenance:
```bash
gbrain remember "Nutrient Earth uses Riverpod state management and Supabase RLS" --provenance arch-decision
```

### Recalling Context
Retrieve facts and related entity nodes with strict token budgets:
```bash
gbrain recall --query "Nutrient Earth architecture"
```

### Ingestion & Thought Synthesis
- **Capture Page / Note**:
  ```bash
  gbrain capture "Meeting notes or architectural spec" --slug architecture-overview
  ```
- **Multi-Hop Synthesis**:
  ```bash
  gbrain think "What are our data models and backend endpoints?"
  ```
- **Night Cycle / Autopilot**:
  Run background graph maintenance, link resolution, and deduplication:
  ```bash
  gbrain dream
  ```

---

## 3. Skills Hub Integration

GBrain bundles 75 specialized agent skills:
```bash
gbrain skills
gbrain skills --query "design"
```

### Connecting via Model Context Protocol (MCP)
GBrain runs as a standard stdio or HTTP MCP server:
```bash
gbrain serve --surface full
```
Supported MCP tools:
- `recall`: Retrieve semantic facts from knowledge base
- `remember`: Store new entity facts and observations
- `entity`: Inspect graph nodes and wikilink connections
- `synthesize`: Multi-document structured summarization
- `get_skill`: Load approved prose workflows dynamically into prompt
