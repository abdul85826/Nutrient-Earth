# Nutrient Earth — App Flow and Interaction Specification

## 1. First-run journey
### Screen 0 — Welcome
- One-sentence promise: “Understand your health with evidence and practical next steps.”
- Show scope: educational support, not emergency care or a diagnosis substitute.
- Actions: Create account, Sign in, Continue as guest only if guest data policy is implemented.
- Links: Privacy, Terms, accessibility, supported regions/languages.

### Screen 1 — Authentication
- OAuth: use Authorization Code + PKCE for public/native clients; validate state and nonce; exact redirect URI allowlist; never embed client secrets in app; refresh tokens stored in platform-secure storage; revoke sessions on logout/account deletion.
  - Web callback: Dynamically resolved from active browser origin (`${Uri.base.origin}/`, e.g. `http://localhost:5656/` in development) with in-app PKCE session exchange and query-param error handling.
  - Native callback: Custom app scheme `com.nutrientearth.app://login-callback` registered in `AndroidManifest.xml` and `Info.plist`.
  - Identity provider allowlist must explicitly permit web origin wildcards (`http://localhost:*/**`) and native custom schemes (`com.nutrientearth.app://**`); never fall back to unmanaged static ports (e.g. 3000).

### Screen 2 — Language and accessibility
- Language, preferred units, text size, reduced motion, captions, voice/TTS preferences.
- Language selection must affect UI and answer preference but not override the language of quoted source text without labeling translation.

### Screen 3 — Goals
Multi-select with “skip”: understand a report, nutrition, energy, movement/fitness, sleep, healthy habits, food/product comparison, family health context, other.
Do not ask for detailed health history before a relevant use case.

### Screen 4 — Basic profile (progressive)
- Preferred display name: optional.
- Date of birth or age band: collect only what age gating or feature safety requires. Prefer date of birth only if necessary; do not collect exact DOB just for personalization.
- Sex-related fields: do not require a generic “gender” field. Ask a specific field only when a feature needs it, explain why, allow “prefer not to say,” and distinguish sex assigned at birth, gender identity, pregnancy status, and hormone therapy where clinically relevant. Do not infer any of these from photos.
- Region/country: only for units, local guidance, practitioner jurisdiction, and legal rules.
- Height/weight/waist: optional, unit-aware, source/date-aware; “measured”, “self-reported”, or “estimated.” Never block core usage if missing.
- Allergies, medication/supplements, diagnoses, injuries, diet pattern, pregnancy/postpartum, accessibility needs: ask just-in-time, feature-specific, skippable, editable, and consent-aware.
- Family history: only when useful; relationship + condition + approximate onset if known. No relatives’ names/IDs by default.
- Each field displays purpose, sensitivity, “why we ask,” and delete/edit option.

### Screen 5 — Representation
- Default: neutral adjustable illustrated avatar; not a real photo.
- Options: generic avatar, customizable visual representation, skip.
- If a later feature truly requires a photo, separate consent screen must say exact purpose, what is processed, whether retained, whether used to train models (default no), deletion behavior, known limitations, and alternatives.
- Do not turn avatar selection into body-fat, race, disease, organ, or health-status inference.

### Screen 6 — Data connections
List each integration separately, initially disconnected:
- Android Health Connect
- Apple HealthKit
- Manual import of PDF/CSV/FHIR when supported
- Other wearable APIs only after terms, scopes, reliability, and privacy review.
For each: show requested data types, purpose, time range, sync cadence limitations, revoke steps, and whether data leaves the device. Ask only when user activates the relevant feature. Permission denial must not break unrelated features.

### Screen 7 — Notifications
- Default off for marketing/engagement.
- User can create reminder: title, schedule, timezone, quiet hours, channel, repeat, end date, snooze, pause/delete.
- System-generated important reminder categories must be individually explained and opt-in where feasible. No hidden recurring reminders.

### Screen 8 — Finish
Show collected fields, connected sources, consent toggles, data controls, and a “Start using Nutrient Earth” button. Profile completion is optional.

## 2. Main navigation
Five tabs: Ask, Explore, Growth, Body, Store. The user can reach Ask without completing every profile field.

### Ask flow
Input chooser → validate file/type/size → explain data processing for sensitive uploads → submit → queued/progress state → retrieval and extraction → verified answer with claim citations → follow-up / save / correct / report issue / export. If retrieval fails, say so; never fabricate citations. For unsupported formats, provide actionable alternatives.

### Explore flow
Search topic/practice → filters for evidence quality, country/tradition, goal, safety, and audience → content detail with evidence/limitations/contraindications → optional related expert listing → credential and scope display → consultation booking only through confirmed provider availability and explicit confirmation. Traditional remedy results must distinguish historical use, plausible mechanism, clinical evidence, and risk.

### Growth flow
Goals and constraints → select duration/equipment/ability → plan with exercise instructions → demonstration (licensed or generated-and-labeled) → safety check and modifications → start session → log completion/feedback → progress view. If pain, dizziness, chest pain, faintness, or other red flags are reported, stop routine flow and provide appropriate safety guidance.

### Body flow
Timeline → select data source/date/metric → source-linked observation → trend visualization → optional anatomy navigation → explanation with uncertainty and next steps. Missing data is visible; do not interpolate without labeling. The 3D anatomy view is educational and must not imply scan-like diagnosis.

### Store flow
Search/filter → product detail → compare exact attributes → testing/COA/batch and label details → suitability warnings → cart/checkout only after payment, tax, fulfillment, returns, adverse-event, recall, and regulatory workflows are implemented. No fake availability or fake reviews.

## 3. Export, deletion, and privacy flows
Settings → Your Data:
- Export data: explain scope, format (ZIP with JSON/CSV and original files where permitted), generation status, expiry of download link, and notification when ready.
- Download link: short-lived, single-use or narrowly scoped, authenticated, no public bucket; require recent re-authentication for sensitive export.
- Export should include profile, consent history, conversations, user attachments, health observations, imported records, exercise logs, reminders, product/order history, and derived data/metadata where legally permitted. Include schema/version and data dictionary.
- Delete selected data: show consequences and dependencies.
- Delete account: re-authenticate, explain legally required retention and irreversible effects, revoke sessions/tokens, cancel jobs, disable integrations, enqueue deletion across stores/backups according to documented retention schedule, and issue completion status.
- Do not claim backup deletion is instantaneous if backups expire by policy. Explain retention window and isolate deleted account data from normal access.
- Correction: preserve provenance; use append/correction records for medical history instead of silently rewriting historical clinical facts.

## 4. Error and degraded states
Every async flow: queued, processing, complete, retryable failure, permanent failure, cancelled, expired. Use correlation ID for support. Never expose raw provider errors, tokens, health payloads, or internal prompts. Show source timestamps and stale-data indicators.

## 5. Reminder and notification flows
- User-created reminders must be manually configured and easy to pause/delete.
- A system safety reminder may be generated only by a documented, reviewed rule tied to user-authorized data; show triggering evidence and uncertainty. No diagnosis-like alerts from weak inference.
- Delivery failures must be visible in settings; do not claim sent unless provider confirms.
- Push/email content must avoid sensitive health details unless user opts in.

## 6. Accessibility and localization
Keyboard/screen-reader navigation, semantic labels, scalable text, contrast, captions, reduced-motion support, localization of dates/units, RTL readiness, and plain-language error messages. Do not rely on color alone for evidence or risk levels.
