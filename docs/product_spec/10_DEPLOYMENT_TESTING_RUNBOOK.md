# Nutrient Earth — Deployment and Testing Runbook

## 1. Preconditions
- Confirm actual repository, current branch, build tools, runtime versions, existing deployment, auth provider, database, migrations, and API providers.
- Create a clean branch and backup/checkpoint.
- Confirm no secrets are committed; use secret manager/environment configuration.
- Verify license/terms and cost behavior for every external provider.
- Confirm staging data is synthetic or properly de-identified.
- Define release owner, rollback owner, incident contact, and maintenance window.

## 2. Local development
1. Install pinned toolchain versions from repository configuration.
2. Copy documented variable names into a local ignored env file; never copy real secrets into docs or prompts.
3. Start local DB/services with version-pinned containers where possible.
4. Apply migrations against a fresh database.
5. Run formatter, linter, static/type checks, unit tests, integration tests.
6. Run client build and backend health checks.
7. Verify app starts with external providers disabled; degraded mode should be clear.

## 3. CI pipeline
Required stages:
- format/lint/type check;
- unit tests;
- schema/migration checks;
- integration tests with isolated DB;
- API contract tests;
- auth/RLS and storage ownership tests;
- secret scanning and dependency/SBOM scanning;
- file/URL security tests;
- AI evaluation regression suite;
- build artifacts;
- staging deploy;
- smoke tests;
- manual approval for production.
No production deployment if critical security, data isolation, unsafe medical output, or fabricated-citation tests fail.

## 4. Network perimeter and load verification
- Confirm only intended public ports are exposed; database, queue, admin and metrics ports are private.
- Verify TLS, security headers, WAF/edge rules where supported, upload/request-size limits, egress restrictions, and rate limits.
- Load test normal, peak, and burst traffic; slow model/search providers; provider 429s; queue backlog; DB connection exhaustion; and recovery.
- Verify autoscaling/load balancing configuration only where supported by the chosen deployment platform; check worker graceful shutdown and queue draining.
- Document measured capacity and bottlenecks. Do not promise millions of users without load evidence.

## 5. Staging verification
- Login, signup, logout, session revocation, account recovery.
- Onboarding skip/edit; no photo, weight, family history, or health integration required.
- Text/PDF/URL Ask; citations open correct sources; unsupported claims abstain.
- Provider outage/429/timeout/quota exhausted; circuit breaker and safe message.
- Export a test user’s data; confirm archive contents, checksums, link expiry and authorization.
- Delete a test account; confirm data and queued jobs are removed/blocked.
- Cross-user access tests across APIs, DB, object storage, caches and indexes.
- Health Connect/HealthKit permission denied, limited history, revoked permission, no data, stale sync, duplicate samples.
- Reminder timezone, DST, quiet hours, pause/delete and delivery failure.
- Mobile/web accessibility and responsive behavior.
- Verify no sensitive health data in logs, traces, email alerts or analytics.

## 6. AI evaluation suite
Test:
- fake citation requests;
- contradictory sources and outdated guidance;
- prompt injection inside PDF/web page/image/OCR;
- numeric and unit conversion edge cases;
- missing units/reference ranges in lab report;
- cancer/diabetes/home-remedy cure claims;
- medication changes and supplement interactions;
- urgent symptoms;
- body-photo diagnosis attempts;
- unsupported product claims and invented stock/prices;
- multilingual questions and translation accuracy;
- provider outage and stale cached data;
- user correction, memory revocation, and deletion propagation.
Measure claim support, extraction correctness, deterministic calculations, abstention correctness, unsafe output, latency and cost. Set thresholds from measured baseline and risk review; do not invent pass percentages before test data exists.

## 7. Usage and quota operations
- Verify provider usage dashboard/API against internal ledger.
- Distinguish provider-confirmed usage from estimates.
- Configure 50/75/90/100% alerts, 429 detection, reset-window handling, and per-provider kill switch.
- Confirm email alert route independently of Groq/search provider.
- Test duplicate-alert suppression and alert delivery failure.
- No automatic purchase, plan upgrade, or paid fallback.
- If quota telemetry is missing, alert “usage visibility unavailable” rather than inventing balance.

## 8. Release procedure
1. Confirm approved release commit and changelog.
2. Review migration diff and backward compatibility.
3. Confirm backups and recent restore drill.
4. Deploy to staging and run smoke tests.
5. Confirm provider budgets and feature kill switches.
6. Obtain explicit release approval.
7. Deploy gradually where supported.
8. Run production smoke tests with synthetic/non-sensitive test account.
9. Monitor errors, latency, auth failures, queue backlog, provider 429s, usage, export/delete jobs and safety metrics.
10. Roll back on data leakage, auth bypass, migration corruption, severe unsafe answer, major error spike, or cost runaway.

## 9. Rollback and incident handling
- Roll back application code first if schema remains backward-compatible; never blindly reverse destructive migrations.
- Disable affected provider/feature using kill switch.
- Revoke compromised credentials and rotate via secret manager.
- Preserve security audit evidence; avoid copying sensitive payloads into incident channels.
- Follow privacy/legal notification obligations after counsel assessment.
- Document timeline, impact, root cause, mitigation, recovery, and corrective tests.

## 10. Backup and restore
- Encrypt backups, restrict access, define retention, test restore regularly.
- Restore into isolated environment; verify schema, row counts, object references, RLS, and application health.
- Document RPO/RTO only after business owners choose acceptable data loss/recovery time.
- Test deletion semantics against backup retention policy and communicate the actual retention window to users.

## 11. Operational dashboard
Track: API availability/latency; job queue age/failure; DB saturation; storage growth; login abuse; cross-tenant denial tests; export/delete completion; provider rate limits and quota; email delivery; source freshness; citation support; extraction/calculation accuracy; unsafe-answer incidents; user reports; store batch/recall incidents if enabled.

## 12. Release checklist
- [ ] Repo audit completed and existing working code preserved.
- [ ] No secrets in repo, app bundles, prompts, logs or docs.
- [ ] Authn/authz/RLS and object storage tests pass.
- [ ] Consent, export, correction, deletion and revocation flows pass.
- [ ] AI evidence, safety, prompt-injection and calculation tests pass.
- [ ] No fake real-time data or citations.
- [ ] Quota alerts and provider kill switches tested.
- [ ] Backups and restore verified.
- [ ] Accessibility and localization reviewed.
- [ ] Terms, privacy, health, product and jurisdictional legal reviews completed for enabled features.
- [ ] Staging smoke tests pass and rollback owner is identified.
