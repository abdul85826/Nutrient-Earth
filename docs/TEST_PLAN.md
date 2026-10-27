# Nutrient Earth — Comprehensive Quality & Security Test Plan

**Document Version:** 1.0.0  
**Date:** 2026-10-26  
**Auditor:** QA Architect & Staff Reliability Engineer  

---

## 1. Test Strategy Overview

The testing strategy adheres to the Clean Architecture pyramid:
1. **Unit Tests (Domain & Services):** Diurnal logic, telemetry calculation, URL SSRF security validation, prompt sanitization.
2. **Widget Tests (Presentation):** Rendering of UI components, interactive checklists, modals, semantic labels, touch target verification.
3. **Integration Tests (End-to-End User Journeys):** Full TodayScreen flow, navigation drawer traversal, inquiry submission, state updates.
4. **Security & Boundary Tests (Defensive):** Negative cases, malformed URLs, prompt injection payloads, oversized inputs.

---

## 2. Test Suite Inventory

### Suite 1: DiurnalService & Greeting Tests (`today_screen_test.dart`)
- `test`: Morning greeting formatting (6:00 - 11:59).
- `test`: Afternoon greeting formatting (12:00 - 16:59).
- `test`: Evening greeting formatting (17:00 - 4:59).
- `testWidgets`: `DynamicGreetingCard` renders diurnal date, personalized name, and botanical message.

### Suite 2: Telemetry & Metrics Tests (`today_screen_test.dart`)
- `testWidgets`: `TelemetryStrip` displays time, AQI badge, temperature, and streak days.
- `testWidgets`: Metric items wrap touch targets in accessible semantics.

### Suite 3: Daily Plan & Task Checklists (`today_screen_test.dart`)
- `testWidgets`: Checklist tasks render title, note, scheduled time.
- `testWidgets`: Tapping task triggers toggle and increments completed counter label.
- `testWidgets`: Semantics indicate checkbox status and accessible hints.

### Suite 4: Research Pipeline & Evidence Synthesis (`today_screen_test.dart`)
- `test`: `ResearchPipelineService` synthesizes inquiry with valid citations and disclaimers.
- `testWidgets`: `ResearchResultModal` displays inquiry, evidence score, PMID badges, and actionable buttons.

### Suite 5: Data Sovereignty & Privacy Controls (`today_screen_test.dart`)
- `testWidgets`: `PrivacyDataModal` presents TLS 1.3 badge, RLS isolation assurances, export action, cache purge action, and irreversible deletion safeguards.

### Suite 6: Security & Penetration Testing Suite (`security_audit_test.dart`)
- `test`: Rejection of malicious loopback URLs (`http://127.0.0.1`, `http://localhost`).
- `test`: Rejection of cloud metadata IP addresses (`http://169.254.169.254`).
- `test`: Rejection of RFC 1918 private subnets (`10.0.0.1`, `192.168.1.1`).
- `test`: Acceptance of legitimate scientific domains (`https://pubmed.ncbi.nlm.nih.gov`, `https://doi.org`).
- `test`: Query length bounding (rejection/truncation of queries exceeding 500 characters).
- `test`: Prompt injection sanitization (stripping adversarial system override tokens).

---

## 3. Test Execution Commands

```bash
# Execute static analysis
flutter analyze

# Execute full automated test suite
flutter test

# Execute test suite with code coverage
flutter test --coverage
```
