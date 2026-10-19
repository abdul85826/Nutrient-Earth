---
name: diagram-design
description: >-
  Visual diagrams, architectural charts, and system design modeling.
  Use when generating Mermaid.js diagrams, sequence diagrams, ERDs, state machines,
  user flow charts, and component dependency graphs.
metadata:
  author: ant-agent
  version: "1.0.0"
---

# Diagram Design & Architecture Visualization

This skill provides guidelines and templates for generating clear, high-density Mermaid diagrams, architecture maps, and system workflows.

---

## 1. Syntax Rules for Antigravity & Markdown

To prevent rendering errors in markdown viewers:
- **Quote labels containing special characters**: Use `id["Client (Browser)"]` instead of `id[Client (Browser)]`.
- **Avoid raw HTML in node text**: Use plain strings or Markdown formatting inside quoted strings.
- **Direction Flow**: Use `TD` (Top-Down) for deep pipelines or `LR` (Left-to-Right) for lifecycle states and sequences.

---

## 2. Diagram Templates

### Architecture & Service Flow (Flowchart)
```mermaid
graph TD
    User["User / Client App"] -->|HTTPS / PKCE| API["API Gateway / Edge Router"]
    API --> Auth["Supabase Auth"]
    API --> DB[("PostgreSQL / RLS")]
    API --> AI["Agent Intelligence Service"]
    AI --> Model["LLM Inference / Reasoning"]
    AI --> ToolCache[("Tools & Knowledge Memory")]
```

### Authentication & Authorization Sequence
```mermaid
sequenceDiagram
    autonumber
    actor User
    participant Client as Flutter Client
    participant Auth as Supabase Auth
    participant DB as Postgres DB

    User->>Client: Clicks "Sign In"
    Client->>Auth: Request PKCE Auth URL
    Auth-->>Client: Return OAuth URL & Code Challenge
    Client->>User: Opens Browser / Webview
    User->>Auth: Authorizes Credentials
    Auth-->>Client: Deep Link with Auth Code
    Client->>Auth: Exchange Code + Verifier
    Auth-->>Client: Session Tokens (JWT + Refresh)
    Client->>DB: Query Protected Data (Bearer JWT)
    DB-->>Client: Return Authorized Rows (RLS filtered)
```

### Entity Relationship Diagram (ERD)
```mermaid
erDiagram
    USER ||--o{ PROFILE : has
    USER ||--o{ HEALTH_RECORD : owns
    HEALTH_RECORD ||--o{ BIOMARKER : contains
    
    USER {
        uuid id PK
        string email
        timestamptz created_at
    }
    HEALTH_RECORD {
        uuid id PK
        uuid user_id FK
        string record_type
        jsonb metadata
    }
```
