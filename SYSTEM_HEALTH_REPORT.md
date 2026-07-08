# Nutrient Earth System Health Report

## Overview
Analysis run on June 27, 2026. The system clean, package retrieval, and code generation (`build_runner`) run successfully. All automated tests pass (`6 tests passed`). Static analysis was performed using `flutter analyze`.

---

## 1. Critical Errors
* **None**: There are no blocking compiler errors or syntax errors that prevent code compilation.

---

## 2. Build Errors
* **None**: The build runner compiles cleanly and successfully.

---

## 3. Runtime Errors / Functional Issues (Audited & Resolved)
* **Authentication Session Synchronization**:
  - **RESOLVED**: Mapped out guest-to-cloud data migration. Google sign-in transitions successfully, trigger database updates on the fly, migrate all historical local Isar records, and update `ne_auth_mode` securely to prevent mismatched IDs.
* **Onboarding Loop & Route**:
  - **RESOLVED**: Fixed onboarding redirection. Navigation now correctly routes to `/` (Home) instead of the dead `/ai-processing` route.
  - Onboarding drafts are saved locally first to survive app restarts, and are cleanly deleted when onboarding is finalized.
* **Profile Persistence**:
  - **RESOLVED**: Constrained onboarding sliders (height: 100-220 cm, weight: 30-150 kg) to match database constraints and prevent deserialization crashes. Added defensive clamping on the slider values to prevent assertion exceptions.
* **Demo Dependency**:
  - **RESOLVED**: Eliminated demo/mock dependencies. The today dashboard now builds daily missions directly from the user's active protocol checklist plan and calculates a real active streak from the subjective daily check-in timeline.

---

## 4. Warnings (from `flutter analyze`)
* **Experimental API Usage**: Isar indexes (`getByIndex`, `deleteByIndex`, `putByIndex`, etc.) in generated schemas trigger `experimental_member_use` warnings. This is expected and safe.
* **Deprecations**:
  - Deprecated profile/health identity helpers are kept solely for backward compatibility.
  - Unused files and imports have been cleaned.

---

## 5. Mock Systems Status
* **Founder Mode Simulation**: Retained as requested to allow testing of extreme circadian/metabolic scenarios (Optimal Baseline, Low Recovery, etc.).
* **Standard Wearables Sync**: Fully functional offline-first local calculations pulling directly from real local attributes when Founder Mode is disabled.
* **Mock recommendations and mock data**: Removed. Everything on the dashboard is populated by real user-input check-ins, local draft caches, and calculated active streaks.
