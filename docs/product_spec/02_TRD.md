# Nutrient Earth — Technical Requirements Document (TRD)

## 1. Architecture decision
Use a modular monolith backend initially, with clear module boundaries and asynchronous workers for expensive jobs. Do not begin with microservices or one agent per feature. Separate logical modules from deployable services; split only after measured scaling, reliability, security, or team-ownership evidence.

### Proposed stack
- Client: Flutter/Dart for Android/iOS; responsive web/PWA path chosen explicitly after repository audit. Avoid maintaining two independent UI systems without a clear need.
- State/routing: one state-management strategy (Bloc/Cubit is the current project preference if already present); GoRouter if compatible with repo.
- Backend: Python + FastAPI + Pydantic for AI/data workloads; async jobs for PDFs, video, large files, long research.
- Canonical relational store: PostgreSQL.
- Identity: managed auth already present if secure and correctly configured; otherwise OIDC/OAuth 2.1-compatible identity provider. Never roll custom password cryptography/session protocols.
- Files: private object storage, short-lived signed URLs, content hashes, malware/type checks, retention policy.
- Cache/queue: introduce Redis-compatible cache/queue only when justified; select Valkey or another permissively licensed option if the project needs an open-source Redis-compatible server. Check exact license and version before adopting. Redis is not automatically “free/open source” for every version/license model.
- Observability: OpenTelemetry instrumentation; self-hostable metrics/logs/traces; error tracking vendor only if its quota/privacy terms fit.
- Deployment: Vercel is an option for supported web frontend workflows, not the assumed home for all backend/worker/data services. Confirm current plan, limits, runtime constraints, and total cost before selecting. Production health data needs a hosting/data-location and backup decision.

## 2. Logical modules
1. Identity & Access: account lifecycle, sessions, OAuth/OIDC callbacks, MFA where supported, recovery, device sessions.
2. Consent & Privacy: purpose-specific consents, consent version, timestamp, revocation, data export, deletion workflow.
3. Profile: user-controlled profile and progressive onboarding.
4. Health Data: observations, measurements, documents, device imports, provenance, units, timestamps, corrections.
5. Evidence Retrieval: provider adapters, source allowlists, URL safety, content extraction, deduplication, source metadata.
6. AI Orchestration: bounded workflow planner, model/provider adapters, tool allowlists, budgets, cancellation, timeouts.
7. Verification: claim-to-source mapping, contradiction detection, deterministic calculation checks, evidence-quality rubric, abstention.
8. Ask/Conversations: messages, attachments, citations, user feedback, conversation export.
9. Explore: evidence-based content, practitioner directory and verification workflow.
10. Growth: plans, exercise library, session logs, safety constraints.
11. Body: timeline, charts, 3D model metadata, observations and source-linked annotations.
12. Store: catalog, formulations, allergens, testing documents, batch/lot, order/refund/recall if commerce enabled.
13. Notifications: user-created schedules, system event rules, preferences, delivery receipts, deduplication.
14. Usage & Cost: provider usage ledger, rate-limit events, quota estimates, budgets, circuit breakers, alert delivery.
15. Admin & Audit: access review, moderation, credential review, product quality incidents, security events.

## 3. Request/data flow
1. Client sends authenticated request with request ID, idempotency key for mutation, and declared content metadata.
2. API validates authentication, authorization, size/type, consent, quota, rate limits, and feature state.
3. Files are quarantined and scanned before parsing; URL ingestion uses SSRF-safe fetcher.
4. A typed job is enqueued for long-running work. Job status endpoint returns queued/running/complete/failed/cancelled with safe error code.
5. Retrieval returns normalized sources with URL, publisher, title, dates, excerpt/content hash, retrieval time, license/retention constraints.
6. Model output is structured and untrusted; claims are mapped to source passages or deterministic computations.
7. Independent verification and domain safety policy decide answer, caveat, escalation, or abstention.
8. Persist answer and evidence links; do not persist chain-of-thought or hidden reasoning. Persist concise decision metadata, source references, model/provider/version, and evaluation outcomes.
9. Stream progress only if transport and client support it; streaming tokens are provisional until final verification. For health-sensitive responses, do not present unverified partial text as final advice.
10. Emit redacted telemetry and usage events.

## 4. AI agent/workflow design
Use a bounded orchestrator with typed domain workers, not free-roaming autonomous agents:
- Nutrition/Product
- Body/Health
- Environment/Exposure
- Behavior/Lifestyle
- Evidence/Research
A task is routed only to necessary workers. Each worker receives minimum necessary user context, approved tools, output schema, deadline, token/cost budget, and prohibited actions. An independent verifier checks claims and safety. No worker may autonomously diagnose, prescribe/change medication, order products, contact a person, or schedule a reminder without explicit user intent/authorization.

## 5. Data and API design
- REST JSON API with `/v1` version prefix; OpenAPI generated from FastAPI schemas.
- Use stable opaque IDs (UUIDv7 or UUIDv4; choose one standard).
- All timestamps stored in UTC, user timezone stored as IANA identifier.
- Units must be explicit and normalized; preserve original value/unit/source and normalized value/unit.
- Paginate with stable cursor-based pagination for growing lists.
- Mutations use idempotency keys where retries can duplicate work.
- Validate request and response schemas; reject unknown dangerous fields rather than blindly persisting.
- Avoid N+1 query patterns; add indexes from query plans, not guesses.
- Long tasks use job records and bounded retries with exponential backoff + jitter; dead-letter failures and allow safe retry.
- API errors use stable machine-readable codes, request ID, and safe human message; never expose stack traces.

## 6. File ingestion and crawling
Allowed input: user-authorized uploads and URLs the user asks to analyze, plus permitted public sources. Respect robots directives, site terms, copyright, rate limits, and data licenses. No login bypass, paywall circumvention, CAPTCHA evasion, or crawling private areas. Avoid paid crawler APIs in the initial build; self-host an open-source crawler/parser only after license and SSRF review. Prefer direct official APIs or publisher metadata when available. A user-provided URL is untrusted input: block private IPs, loopback, link-local, cloud metadata endpoints, unsafe redirects, unsupported protocols, DNS rebinding, oversized downloads, and decompression bombs.

## 7. Real-time and sync
Never label a feature “real-time” unless there is a verified source, defined freshness target, and working update mechanism. Every imported dataset includes `source`, `observed_at`, `imported_at`, `last_synced_at`, `sync_status`, and coverage limitations. Use OS background work where available but promise eventual sync, not guaranteed continuous access. For unavailable providers, show last-known timestamp and allow manual refresh.

## 8. Reliability, network perimeter, and scale
- Place public endpoints behind a maintained web application firewall (WAF) or equivalent edge protections when supported; configure request-size limits, bot/abuse controls, TLS, secure headers, and DDoS protections appropriate to the host.
- Keep databases, queue brokers, admin panels, metrics endpoints, and internal service ports off the public internet. Use private networking, firewall/security-group allowlists, and least-privilege egress.
- Apply load balancing and horizontal scaling only where the selected host/runtime supports it; workers must be stateless or use durable external state. Define graceful shutdown and queue-drain behavior.
- Set connection pool limits, worker concurrency, queue backpressure, per-user quotas, and provider concurrency caps to prevent overload cascades.
- Timeouts at every external boundary.
- Circuit breakers and per-provider concurrency limits.
- Provider fallback only when alternate provider license, privacy, and quality are approved.
- Cache public source results by normalized query and TTL; never cross-user cache personalized health data without explicit privacy-safe design.
- Durable queue for expensive jobs; idempotent consumers.
- Health checks distinguish liveness from readiness.
- Graceful degradation when search, model, weather, device, email, or storage providers fail.
- Load tests based on realistic workloads before defining capacity commitments. Test sudden traffic spikes, slow dependencies, queue buildup, database saturation, and recovery after load.

## 9. Deployment environments
Separate local, CI, staging, and production credentials/projects. No production secrets in Antigravity prompts, repository files, screenshots, tickets, or client builds. Use environment variables/secret manager and rotation. Database migrations are reviewed and tested against production-like data volume. Backups encrypted; restore drills required. Deploy canary/gradual where supported; rollback plan includes schema compatibility.

## 10. Engineering decisions still requiring repo audit
Confirm actual Flutter/backend framework, auth provider, Supabase usage, hosting, existing API keys/providers, database migrations, test coverage, and current licensing before modifying. Do not replace working infrastructure solely because this document lists a preference.
