# DATA FLOW MAP
*Generated: 2026-06-27 — Fresh Install → Guest → Onboarding → Dashboard & Migration*

---

## User Journey & Migration Trace

```
Fresh Install
  ↓ [BootstrapManager.initializeApp()]
  ↓ LocalStorageService.initialize() → Isar.open()
  ↓ IdentityManager.initialize() → generates Guest UUID → SharedPreferences
  ↓ BootstrapState.complete (bootstrapManager.state)

Login Screen (/auth)
  ↓ User taps "Continue as Guest"
  ↓ SharedPreferences.setString('ne_auth_mode', 'guest')
  ↓ IdentityManager().initialize()
  ↓ appLifecycleProvider.initializeApp()
  ↓ Routes to /onboarding (since no profile complete)

Onboarding (/onboarding)
  ↓ User fills steps (clamped slider ranges for height/weight)
  ↓ OnboardingNotifier.saveDraft() saves onboarding JSON locally to SharedPreferences first
  ↓ OnboardingNotifier.finalize() saves UserProfile/HealthIdentity to local Isar DB
  ↓ Clears local onboarding draft
  ↓ Routes to / (Home)

Authentication Transition (Google OAuth callback / signed-in event)
  ↓ Supabase onAuthStateChange triggers AuthChangeEvent.signedIn
  ↓ ensureUserRecordExists(userId, email, authProvider: 'google')
  ↓ Isar & SharedPreferences migrate records from Guest UUID to Cloud UUID
  ↓ upgradeToCloudIdentity(cloudUserId)
  ↓ Invalidates healthIdentityProvider & appUserProvider
  ↓ Refreshes today screen metrics automatically with migrated data
```

---

## Screen-by-Screen Data Classification

### 1. Today Screen — Redesigned Dashboard

| Value | Source | Classification |
|-------|--------|---------------|
| User Name | `appUserProvider` → `users` metadata / email | **SUPABASE / LOCAL ISAR** |
| Daily Missions | `actionProvider` → User's active protocol checklist | **COMPUTED LOCAL PROTOCOLS** |
| Streak | Check-in days calculated from observation timeline | **COMPUTED FROM USER TIMELINE** |
| Signals Logged | Total count of Isar timeline events | **LOCAL ISAR EVENT COUNT** |
| Calibration progress | Baseline state progress percentage | **COMPUTED METABOLIC BASELINE** |
| Primary Goal | `healthIdentityProvider` → Isar / Supabase | **LOCAL ISAR / CLOUD USER PROFILE** |
| Missing Info | `userStateEngineProvider` → Incomplete fields | **COMPUTED PROFILE QUALITY** |

### 2. Today Screen — Daily Check-In Card

| Value | Source | Classification |
|-------|--------|---------------|
| Energy, Stress, Mood, Sleep | `observationEngine` → logged subjective ratings | **LOCAL ISAR BIOLOGICAL EVENT** |

### 3. Body Screen

| Value | Source | Classification |
|-------|--------|---------------|
| Recovery, Sleep, Hydration, Stress | Baseline State / `UserProfile` metrics formulas | **COMPUTED BIOLOGICAL TWIN** |

### 4. Insights Screen

| Value | Source | Classification |
|-------|--------|---------------|
| Biological Insights | Threshold anomaly rules from user parameters | **COMPUTED RULE INSIGHTS** |
| Active Patterns | Metabolic and circadian anomalies | **COMPUTED RUNTIME ANOMALIES** |
