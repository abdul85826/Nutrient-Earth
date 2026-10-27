# Nutrient Earth — Prioritized Security Remediation Plan

**Document Version:** 1.0.0  
**Date:** 2026-10-26  
**Auditor:** Senior Security Engineer & QA Architect  

---

## Remediation Roadmap & Execution Hierarchy

Remediations are ordered according to risk severity:

```
[ Phase 1: CRITICAL Fix ] ──► SEC-01: Remove .env from client asset bundle
        │
[ Phase 2: HIGH Fixes ]   ──► SEC-02: Implement SSRF Protection on Publication URLs
        │                 ──► SEC-03: Supabase RLS Policy & Storage Deletion Hardening
        │
[ Phase 3: MEDIUM Fixes ] ──► SEC-04: Query Length Capping & Prompt Injection Defenses
        │                 ──► SEC-05: Credential Isolation & Rotation Protocol
        │
[ Phase 4: VERIFICATION ] ──► Automated Security Regression Test Suite + Static Analysis
```

---

## Action Items & File Changes

### Action 1 (Fix for SEC-01): Remove `.env` from `client/pubspec.yaml`
* **File:** `client/pubspec.yaml`
* **Change:** Delete line `- .env` under `flutter.assets`.
* **Rationale:** Prevents `.env` from ever being packaged into release APKs, IPA bundles, or web asset manifests.

### Action 2 (Fix for SEC-02 & SEC-04): Implement Security Validators in `research_pipeline_service.dart`
* **File:** `client/lib/core/services/research_pipeline_service.dart`
* **Add:**
  1. `SecurityUrlValidator.isValidScientificUrl(String url)`: Validates `https://` scheme, restricts hosts to reputable scientific journals/archives (`pubmed.ncbi.nlm.nih.gov`, `doi.org`, `nature.com`, `sciencedirect.com`, `thelancet.com`, `frontiersin.org`), and blocks loopback, private RFC 1918 IPs, and cloud metadata (`169.254.169.254`).
  2. `QuerySanitizer.sanitize(String query)`: Enforces maximum 500 characters, rejects empty/whitespace strings, and sanitizes adversarial prompt injection delimiters.

### Action 3 (Fix for SEC-03): Create Migration `20261026000001_rls_security_hardening.sql`
* **File:** `supabase/migrations/20261026000001_rls_security_hardening.sql`
* **Add:**
  1. Explicit `WITH CHECK` clauses for `public.profiles`, `public.health_measurements`, and `public.health_reports`.
  2. Add `DELETE` and `UPDATE` policies for `storage.objects` in bucket `health-reports` allowing users to delete their own uploaded documents.
  3. Ensure `file_size` on `health_reports` satisfies `file_size > 0 AND file_size <= 15728640`.

### Action 4: Automated Security Test Suite
* **File:** `client/test/security_audit_test.dart`
* **Contents:** Test SSRF blocking, test query bounds, test injection filtering, and audit assets.
