# Nutrient Earth — Engineering Governance Policy

## Authority
This single document is the authoritative engineering and architecture policy for Nutrient Earth in Antigravity.

## Core Directives

1. **Inspect Before Creating**
   - Search and inspect the existing codebase before creating new files or services.
   - Reuse and extend existing implementations whenever appropriate.

2. **No Bloat or Over-Abstraction**
   - Avoid speculative abstractions, unnecessary wrapper layers, duplicate services, and giant monolithic files.
   - Keep code modular, testable, and focused strictly on product requirements.

3. **Small, Reviewable Changes**
   - Implement changes in small, reviewable slices with explicit, narrow scope.
   - No unrelated refactoring or drive-by cosmetic modifications.

4. **Empirical Verification Required**
   - Run tests and static analysis (`flutter test`, `flutter analyze`) to prove correctness before claiming success.
   - Never accept assumptions in place of verified terminal output.

5. **Security, Privacy & Credentials**
   - Strictly zero secrets or credentials in source code (use `.env` and secure environment variables).
   - Enforce user-data isolation and Supabase Row Level Security (RLS) across all tables and queries.
   - Never execute destructive database or security changes without explicit authorization.
   - Enforce SSRF protection on all user-supplied URLs.

6. **Production Quality**
   - **Flutter / Dart**: Follow Clean Architecture and Riverpod state management with type-safe contracts.
   - **Backend / Supabase**: Idempotent SQL migrations, typed Edge Functions, and least-privilege policies.
   - **AI & Health Memory**: Deterministic reasoning and evidence verification over probabilistic guessing. Never fabricate citations or bypass safety guardrails.
