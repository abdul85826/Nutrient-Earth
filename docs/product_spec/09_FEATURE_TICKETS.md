# Nutrient Earth — Feature Ticket List and Acceptance Gates

## Delivery rule
Antigravity must first inspect the existing repository and produce a read-only audit. Do not overwrite working files, change dependencies, rotate credentials, or run destructive migrations without explicit approval. Create a branch/checkpoint before changes. Every ticket needs acceptance criteria, tests, and a rollback note.

## EPIC 0 — Repository and product baseline
**NE-0001 Repository inventory**
- Inspect project tree, framework versions, entry points, environment files (names only, never values), dependencies, tests, CI, deployment, auth, DB schema/migrations, provider integrations.
- Acceptance: inventory report; no source modifications; no secret values printed.

**NE-0002 Dependency/license audit**
- Produce SBOM, license inventory, outdated/vulnerable package report, transitive dependency review.
- Acceptance: no unreviewed license/critical vulnerability in release path.

**NE-0003 Provider inventory**
- Identify existing Groq/weather/other APIs by code references and env variable names; verify usage, quota source, license, privacy, and fallback.
- Acceptance: provider registry completed without exposing credentials.

**NE-0004 Design system freeze & five-field UX specification**
- Establish authoritative brand tokens from official emblem; define dual-font typography; specify five distinct field UX models; deliver Google Stitch design brief.
- Acceptance: `BRAND_AND_DESIGN_SYSTEM.md`, `FIVE_FIELD_UX_SPECIFICATION.md`, and `STITCH_IMPLEMENTATION_BRIEF.md` committed; 100% WCAG contrast verified; no code or API modifications in design phase.

## EPIC 1 — Identity, profile, consent
**NE-0101 Authentication and session audit**
- Confirm OIDC/OAuth provider and secure flow; validate PKCE/state/nonce/redirect URI/session behavior.
- Acceptance: auth tests pass; no client secrets; session revocation tested.

**NE-0102 Progressive onboarding**
- Implement language, goals, optional profile, just-in-time sensitive questions, skip/edit flows.
- Acceptance: user can reach Ask without providing weight, photo, family history, or device access.

**NE-0103 Consent ledger**
- Purpose-specific consent, versioning, revocation, audit history.
- Acceptance: revoked integration cannot initiate new sync or use data for new personalization.

**NE-0104 Avatar options**
- Default neutral illustrative avatar; customizable and skippable; no health inference from appearance.
- Acceptance: no photo required; no model inference from avatar data.

## EPIC 2 — Ask evidence vertical slice
**NE-0201 Text query API**
- Auth, rate limit, request IDs, typed response.
- Acceptance: unauthorized access denied; request is traceable.

**NE-0202 Retrieval adapter**
- Source metadata, allowed-source rules, safe URL fetch, deduplication, timestamps.
- Acceptance: SSRF suite passes; every source has provenance.

**NE-0203 PDF/document ingestion**
- Private upload, type/size validation, malware scan, extraction job, page references.
- Acceptance: unsupported/malicious/oversized files rejected safely.

**NE-0204 Claim verification**
- Claim-to-passage mapping, contradiction handling, unsupported claim rejection.
- Acceptance: no citation generated without a real source; failed verification yields caveat/abstention.

**NE-0205 Answer UI**
- Evidence cards, source dates, uncertainty, calculation labels, follow-ups, correction/report action.
- Acceptance: stale/unavailable retrieval is visible.

**NE-0206 Groq adapter verification**
- Verify actual model IDs, rate limits, provider terms, timeouts, usage metering, and fallback.
- Acceptance: API key server-side; no assumption of unlimited/free usage.

## EPIC 3 — Data rights and security
**NE-0301 Export job**
- Export JSON/CSV and user-owned attachments with manifest/checksums.
- Acceptance: cross-user export impossible; signed download expires; re-auth required.

**NE-0302 Deletion workflow**
- Delete account/data across DB, files, caches, queues, indexes, vendors; record lawful retention exceptions.
- Acceptance: deletion status truthful; backup retention disclosed.

**NE-0303 RLS and authorization suite**
- Test every user-owned table, storage object, nested query, and service role.
- Acceptance: cross-tenant read/write tests pass.

**NE-0304 Secret and telemetry controls**
- Secret scan; PII/health payload redaction; no raw prompt/body in error alerts.
- Acceptance: automated tests prove redaction.

## EPIC 4 — Cost, rate limits, and alerts
**NE-0401 Usage ledger**
- Track requests, tokens/credits where available, status codes, estimates and provider-confirmed usage separately.
- Acceptance: estimates visibly labeled.

**NE-0402 Quota circuit breaker**
- 50/75/90/100 thresholds; provider-specific limits; 429/Retry-After handling; kill switch.
- Acceptance: no auto-purchase; noncritical work throttled at configured threshold.

**NE-0403 Alert email**
- Independent delivery provider; deduplicated alerts; verified domain and deliverability.
- Acceptance: alert path works when AI/search provider is unavailable; no sensitive payload in email.

## EPIC 5 — Five tabs, gated by real functionality
**NE-0501 Explore evidence catalog**
- Evidence grade, risks, source metadata, traditions/clinical evidence distinction.
- Acceptance: no cure claims without adequate evidence.

**NE-0502 Practitioner verification**
- Credential documents, jurisdiction/scope, verification expiry, complaint process.
- Acceptance: unverified/expired profiles cannot display “verified.”

**NE-0503 Growth routines**
- Exercise safety rules, alternatives, media licensing, session logging.
- Acceptance: red-flag symptoms interrupt routine flow.

**NE-0504 Body timeline**
- Source-linked observations, units, dates, gaps, correction history.
- Acceptance: no inferred diagnosis or invented measurements.

**NE-0505 Health Connect adapter**
- Least-permission data types; permission denial and revocation paths; sync timestamps.
- Acceptance: only granted data read; history/background access declared only if needed and approved.

**NE-0506 HealthKit adapter**
- Entitlements, purpose strings, per-type authorization, limited-history handling.
- Acceptance: no assumption that missing data means user denied permission or has no data.

**NE-0507 3D anatomy**
- Licensed/owned anatomy assets; source-linked annotations; accessible fallback.
- Acceptance: visualization explicitly educational; no unsupported organ status.

**NE-0508 Store catalog and quality**
- Ingredients, allergens, batch testing, COA, claims, recall state.
- Acceptance: no product sale until compliance/quality/returns/recall gates pass.

**NE-0509 Store checkout**
- Payment provider, tax, order fulfillment, refund and adverse-event workflows.
- Acceptance: payment state is provider-confirmed; idempotent webhooks and reconciliation.

## EPIC 6 — Real-time and reminders
**NE-0601 Freshness model**
- Per-provider freshness target and timestamps.
- Acceptance: stale provider data never labeled live.

**NE-0602 User reminders**
- Explicit schedule, timezone, quiet hours, pause/delete, delivery status.
- Acceptance: no hidden recurring reminder.

**NE-0603 System safety notifications**
- Reviewed rules, user authorization, source evidence, dedupe, lock-screen privacy.
- Acceptance: no unsupported diagnosis-like alerts; audit rule version and trigger.

## EPIC 7 — Reliability and release
**NE-0701 Observability**
- Request IDs, traces, metrics, redacted logs, provider status.
- Acceptance: no raw health payloads or secrets in logs.

**NE-0702 Backup/restore**
- Encrypted backups, restore drill, RPO/RTO decided from business requirements.
- Acceptance: successful documented restore into isolated environment.

**NE-0703 CI and security tests**
- Formatting, lint, type checks, unit/integration/e2e, dependency and secret scans.
- Acceptance: release blocked on critical failures.

**NE-0704 Deployment runbook**
- Staging, migrations, smoke tests, rollback, incident owner.
- Acceptance: reproducible deployment without exposing secrets.

## Suggested sequencing
P0 repository audit and security baseline → P1 auth/consent/data rights → P2 Ask evidence vertical slice → P3 quota alerts and deployment → P4 Explore/Growth/Body incrementally → P5 device integrations → P6 Store/commerce only after regulatory and operational gates.
