# Nutrient Earth — Backend Schema and Data Governance

## 1. Principles
PostgreSQL is the canonical relational store unless repo audit proves otherwise. Normalize core records; denormalize only for measured read paths. Use migrations, foreign keys, constraints, and ownership checks. Health facts are append-oriented: corrections must preserve history and provenance. All user-owned rows require authorization and tenant isolation tests.

## 2. Core tables (logical schema; exact SQL follows repository conventions)
### Identity and consent
- `users`: `id`, `auth_subject`, `status`, `created_at`, `updated_at`, `deleted_at`; no password field if external identity provider manages credentials.
- `user_profiles`: `user_id` PK/FK, `display_name`, `locale`, `timezone`, `country_code`, `preferred_units`, `accessibility_preferences`, timestamps.
- `profile_attributes`: `id`, `user_id`, `attribute_key`, `value_json`, `unit`, `source_type`, `observed_at`, `recorded_at`, `confidence/quality metadata`, `supersedes_id`; restrict allowed keys and value schema.
- `consent_records`: `id`, `user_id`, `purpose`, `data_categories`, `provider`, `policy_version`, `granted_at`, `revoked_at`, `source_ui_version`; immutable audit record.
- `integration_connections`: `id`, `user_id`, `provider`, `scopes`, `status`, encrypted token reference (never raw token in logs), `connected_at`, `last_sync_at`, `revoked_at`.
- `user_sessions` only if the identity system requires app-level session metadata; never duplicate auth-provider secrets.

### Health and documents
- `health_observations`: `id`, `user_id`, `observation_type`, `value_numeric`, `value_text`, `unit`, `reference_range_json`, `effective_at`, `recorded_at`, `source_type`, `source_id`, `original_value`, `original_unit`, `quality_flags`, `supersedes_id`.
- `health_conditions`: user-entered/clinician-sourced condition with provenance and status; do not model AI inference as confirmed diagnosis.
- `medications`: user-reported medication/supplement, normalized ingredient where possible, dose as entered, start/end dates, source and confidence; no medication changes by AI.
- `allergies`: substance, reaction if known, severity if clinician-recorded, source, timestamps.
- `family_history_items`: relationship category, condition, approximate onset/age range, source, optional notes; no relative name/contact/identifier by default.
- `documents`: `id`, `user_id`, `object_key`, `media_type`, `size_bytes`, `sha256`, `scan_status`, `processing_status`, `retention_class`, timestamps.
- `document_extractions`: document id, parser/model version, extracted structured data, page/region references, confidence, verification status.
- `device_observations`: source provider, external record id/hash, data type, start/end, value/unit, source device, sync batch id, deduplication key.
- `sync_runs`: provider, user id, requested scopes, start/end, cursor, status, counts, error code, coverage start, next eligible sync time.

### AI, evidence, and conversation
- `conversations`: `id`, `user_id`, title, created/updated timestamps, retention state.
- `messages`: `id`, `conversation_id`, role, content reference/body, content classification, model/provider/version, created_at; do not store hidden chain-of-thought.
- `message_attachments`: message id, document id or object reference, safe metadata.
- `sources`: canonical URL, normalized URL, title, publisher, published_at, retrieved_at, source type, license/retention metadata, content hash, trust classification.
- `evidence_passages`: source id, passage text/reference, offsets/page, content hash, extraction version.
- `claims`: claim id, normalized claim, claim type, risk level, verification status, created_at.
- `claim_evidence`: claim id, passage id, relation (supports/contradicts/context), reviewer/verifier version, notes.
- `answer_runs`: request id, workflow version, model/provider versions, retrieval status, verification status, safety outcome, cost estimate, duration, final status.
- `user_feedback`: user id, answer/message id, feedback type, optional text, created_at; redact sensitive free text in telemetry.
- `calculation_records`: input references, formula/version, units, output, rounding, verifier status; deterministic code owns arithmetic.

### Product, exercise, expert, notifications
- `exercise_catalog`, `exercise_variants`, `workout_plans`, `workout_sessions`, `workout_session_events`: include difficulty, contraindication notes, media license, version, completion, user feedback.
- `practitioners`, `practitioner_credentials`, `credential_verifications`, `consultation_slots`, `bookings`, `reviews`, `complaints`: credential evidence, jurisdiction, scope, verification timestamp and expiry; never imply verified if expired.
- `products`, `product_ingredients`, `product_claims`, `product_documents`, `product_batches`, `batch_test_results`, `suppliers`, `orders`, `order_items`, `refunds`, `adverse_events`, `recalls`. Use immutable batch/test records and audit all status changes.
- `reminders`: owner, source (`user` or `system_rule`), rule id, title, schedule, timezone, channel, status, consent reference, next run.
- `notification_deliveries`: reminder/event id, provider, status, attempts, delivery receipt, error code; no sensitive content in logs.
- `provider_usage_events`: provider, credential reference, endpoint/model, request count, tokens/credits when available, cost, HTTP status, remaining/reset headers, request id, timestamp.
- `quota_alerts`: threshold, period, dedupe key, sent/acknowledged status.
- `audit_events`: actor, subject, action, resource type/id, reason, timestamp, request id; no raw payload/secrets.

## 3. Data rules
- `user_id` ownership enforced at service layer and database RLS where supported.
- Use foreign keys, unique constraints, check constraints, and indexes intentionally.
- Never trust `user_id` supplied in request body; derive from authenticated principal.
- Store clinical measurements with units and source. Do not compare unlike units.
- Use UTC timestamps plus user timezone for schedules.
- External provider tokens stored in secret manager or encrypted token vault, not plain DB fields.
- Store raw uploaded file in private object storage; database stores object key/hash/metadata only.
- Short-lived signed URLs; no permanent public URLs for health documents.
- Avoid embedding personal health data in search indexes without access filtering and deletion propagation.
- Derived profile summaries must retain provenance and have a recompute/delete policy.
- Data deletion must cover primary DB, object storage, caches, vector indexes, analytics, queues, and vendor processors according to documented retention and legal obligations.

## 4. Export and deletion schema
- `data_export_jobs`: user, requested scope, format, status, object key, expires_at, checksum, created_at, completed_at, error code.
- `data_deletion_jobs`: user, requested scope, status, started_at, completed_at, retention exceptions, subsystem statuses, audit reference.
- Export package manifest includes schema version, generated timestamp, included/excluded categories, file checksums, and known retention limitations.
- Downloads require authorization, recent re-authentication, short-lived signed URLs, and audit events.

## 5. Index and query design
Initial candidates subject to `EXPLAIN ANALYZE`: `(user_id, effective_at DESC)` on observations; `(user_id, created_at DESC)` on conversations; unique provider external IDs scoped to user; `(status, next_run_at)` for reminders/jobs; `(provider, occurred_at DESC)` for usage; `(product_id, batch_code)` for batch traceability. Add GIN indexes only for demonstrated JSON/full-text query needs. Avoid indexes that make high-write tables unnecessarily expensive.

## 6. Row-level security and authorization tests
For each table, test: owner can read/write permitted rows; other user cannot read/write; unauthenticated user cannot access; service role is server-only; admin access is audited and reason-bound; revoked consent blocks future sync/use; deleted user cannot retrieve exports or continue jobs. Test nested joins and storage policies, not just top-level queries.

## 7. Retention and medical history
Define retention per category with legal review. Do not delete historical medical data silently. Preserve correction/audit metadata. Where deletion is requested, remove data unless a specific lawful retention exception applies; explain the exception and retention period. Do not use “we keep everything forever” as a default.
