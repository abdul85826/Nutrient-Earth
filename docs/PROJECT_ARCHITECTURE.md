# Nutrient Earth — Verified Project Architecture & Trust Boundaries

**Document Version:** 1.0.0  
**Status:** Audited & Verified  
**Date:** 2026-10-26  
**Auditor:** Senior Security Engineer & QA Architect  

---

## 1. System Overview & Architecture Topology

Nutrient Earth is an evidence-first nutritional biochemistry and diurnal health optimization platform. The system operates across three primary tiers:

```
[ Flutter Client Runtime (Android / iOS / Web) ]
       │
       ▼ (HTTPS / TLS 1.3 + PKCE OAuth)
[ Supabase Gateway / PostgreSQL Tier ] ──► [ Storage Engine (health-reports) ]
       │
       ▼ (Private Server-Side / Edge Function)
[ AI & Scientific Retrieval Pipeline ] ──► [ PubMed NCBI / Semantic APIs ]
```

### Component Inventory

| Component | Technology | Role | Trust Level |
| :--- | :--- | :--- | :--- |
| **Client Frontend** | Flutter 3.41+ / Dart 3.13+ | Presentation, diurnal telemetry, interactive checklists, inquiry inputs | **Untrusted** |
| **State Layer** | Riverpod 2.5.1 | Client-side reactive state orchestration | **Untrusted** |
| **Navigation** | GoRouter 14.2.0 | Declarative client routing | **Untrusted** |
| **Auth Engine** | Supabase Auth (PKCE) | User identity, JWT issuance, session management | **Trusted** |
| **Database** | PostgreSQL 15 (Supabase) | Multi-tenant relational storage, Row Level Security (RLS) | **Authoritative** |
| **Object Storage** | Supabase Storage (`health-reports`) | Encrypted storage for user health documents and lab panels | **Authoritative** |
| **Scientific Inference**| Enterprise AI Gateway | Multimodal food label synthesis and peer-reviewed literature retrieval | **Semi-Trusted** |

---

## 2. Trust Boundaries & Security Enclaves

### Enclave A: The Client Runtime (Untrusted Boundary)
* The client executes on consumer hardware (mobile devices, web browsers).
* **Threat Assumption:** Any data, state, or key placed inside the client application bundle or memory space is accessible to reverse-engineering, decompilation, and inspection.
* **Security Rule:** Absolutely zero server-side secrets (service role keys, model provider API keys, payment secret keys) may reside in the client application bundle. Only the public Supabase URL and scoped `anon` public key are permissible.

### Enclave B: The Transport Boundary
* All communications between the Flutter client and Supabase/APIs utilize **TLS 1.3** transport security.
* Authentication callbacks utilize PKCE (`AuthFlowType.pkce`) to protect against authorization code interception attacks on mobile and web platforms.

### Enclave C: Database & Row Level Security (RLS) Boundary
* The PostgreSQL database enforces tenant isolation at the kernel level using Supabase Row Level Security.
* Every query initiated by the client carries a cryptographically signed JWT. Postgres evaluates `auth.uid() = user_id` for table records.
* Users cannot access, modify, or infer another user's biometric records, inquiries, or uploaded reports.

### Enclave D: Storage Isolation Boundary
* Storage bucket `health-reports` is private (`public = false`).
* Files must be prefixed with `auth.uid()` (e.g., `health-reports/<user_id>/<report_uuid>.pdf`).
* Storage RLS policies validate that only the authenticated user owning the folder path can read or insert objects.

### Enclave E: External AI & Retrieval Boundary
* User-provided research queries and uploaded meal images represent untrusted user input.
* Inquiries must undergo length boundaries, injection filtering, and sanitization before hitting AI synthesis.
* Responses from AI models are treated as untrusted text and validated against medical disclaimer schemas before display.

---

## 3. Data Flow & Critical Journeys

### Journey 1: Diurnal Telemetry & Greeting
1. Client initializes `DiurnalService` and `TelemetryService` using local device time and cached observation telemetry.
2. If offline, the client falls back gracefully to localized diurnal contextual schedules without blocking user interaction.

### Journey 2: Scientific Research Inquiry & Evidence Synthesis
1. User enters nutritional question or provides a scientific publication URL / DOI.
2. Input is validated against length limits (< 500 chars) and SSRF blocklists (preventing internal IP queries).
3. Query is sent to the evidence pipeline, synthesizing evidence tiers (`RCT Review`, `Meta-Analysis`, `Observational Cohort`).
4. Result displays structured findings, PMID links, and prominent medical boundaries.
5. Inquiries are stored in local history cache with user-sovereign purge controls.

### Journey 3: Health Document & Lab Report Upload
1. User selects PDF or image (max 15MB).
2. Client checks MIME type (`application/pdf`, `image/png`, `image/jpeg`).
3. Client uploads to `storage.objects` under `health-reports/<auth.uid()>/<file_id>`.
4. Metadata record inserted into `public.health_reports` protected by RLS.

---

## 4. Single Points of Failure & Risk Analysis

| Component | Failure Mode | Mitigation Strategy |
| :--- | :--- | :--- |
| **Supabase Gateway** | Cloud network outage or rate-limiting | Offline client caching (`SharedPreferences`), graceful offline degraded mode |
| **AI Inference Provider** | Provider timeout or quota depletion | Deterministic peer-reviewed static knowledge fallback (`LearnRepository`) |
| **Scientific Literature API**| PubMed NCBI rate limit or throttling | In-memory claim caching, exponential backoff, static citation fallback |
| **Client Storage Leak** | Storing unencrypted secrets in shared prefs | Exclusively store ephemeral non-sensitive tokens and preference toggles |
