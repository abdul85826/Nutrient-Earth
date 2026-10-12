# Nutrient Earth — Product Requirements Document (PRD)
**Status:** Draft for implementation planning — source of truth pending repo and stakeholder verification  
**Last researched:** 2026-10-12  
**Product:** Nutrient Earth (NE)

## 1. Product thesis
Nutrient Earth helps a person understand and improve their health using their own context, trustworthy evidence, practical behavior change, and connected records. It is not a diagnosis engine, a replacement for a licensed clinician, or an unverified wellness-content feed.

The core loop:
1. The user provides a question, goal, report, food/product image, voice input, or optional device data.
2. NE clarifies only what is necessary, explains what data it will use, and obtains permission where required.
3. The system retrieves trustworthy sources, extracts facts, calculates deterministic values where possible, verifies claims and uncertainty, and applies safety policy.
4. NE presents an actionable answer with evidence, limitations, date/context, and a path to the next step.
5. The user can save, correct, export, delete, or revoke data access.
6. With explicit permission, NE uses relevant history to personalize future answers and measure change.

## 2. Primary experience: five tabs
### Ask
Multimodal question-and-answer: text, camera/image, supported video/audio, PDF/document, URL, and voice. Responses should distinguish facts, inferences, estimates, unknowns, and recommendations. Show claim-level citations, publication/source dates, evidence-quality labels, relevant calculations, confidence/uncertainty, and up to three useful next actions. Generated images must be labeled as generated and must never be presented as documentary evidence. For a product comparison, compare the requested attributes and explicitly mark unavailable data as “not found/unknown,” never fabricate a specification.

### Explore
Evidence-led health and nutrition knowledge, recipes, food practices, culturally diverse traditions, home-care measures, and discovery of appropriately qualified professionals. Each item needs a clear evidence level and intended use. Traditional practice may be described respectfully, but no tradition—including Ayurveda or homeopathy—may be described as a proven cure without adequate evidence. For cancer, diabetes, infection, pregnancy, or other high-risk conditions, supportive habits must not be framed as substitutes for clinical care or prescribed treatment. Expert profiles require verified credentials, scope, location/jurisdiction, fee transparency, and complaint/report mechanisms before listing as verified.

### Growth
Personalized bodyweight workouts, mobility, stretching, yoga, breathing and other movement practices. Personalization uses goals, ability, equipment, time, accessibility needs, pain/injury limitations, and user feedback. Demonstrations must be safe, accurately labeled, and accessible. The system should offer easier alternatives, stopping rules, and a clear distinction between normal exertion and warning symptoms. Do not infer that a movement is safe for a user when critical information is unknown.

### Body
A personal health timeline and human-body visualization linking user-provided records, observations, measurements, goals, and permissioned device data. The 3D body is educational and navigational—not a diagnostic image. No organ or tissue should be highlighted as abnormal unless supported by a clinician-authored report or validated, explicitly scoped result. Display source, date, provenance, uncertainty, and missing-data gaps for each observation.

### Store
Product discovery and, later, commerce for supplements/nutrition products. Product pages require ingredient/label data, dosage/form, allergens, batch/lot identity where applicable, manufacturer, country, testing evidence, claim substantiation, warnings, expiry/storage, and regulatory status. A product must not be called “chemical-free” or “zero toxin”; specify tested analytes, method, limit of detection/quantification, batch, date, and lab. Paid placement cannot override suitability or evidence. Do not launch commerce until regulatory, supply-chain, quality, returns, adverse-event, and recall workflows are operational.

## 3. Cross-tab Personal Intelligence
A shared context service may connect the five tabs only according to consent and relevance. Store provenance for every health observation and every derived inference. Keep user-entered, device-imported, clinician-authored, model-inferred, and externally sourced facts distinguishable. Provide a visible “why am I seeing this?” explanation and controls to correct, hide, revoke, or delete information.

## 4. Onboarding and profile
Do not make users complete a long medical questionnaire before seeing value. Use progressive disclosure:
- Step 1: choose language, accessibility preferences, and sign-in method; explain product scope and privacy in plain language.
- Step 2: ask display name or preferred name (optional), age/date of birth only if needed for age gating or a feature, and country/region for units, local emergency guidance, and regulatory relevance.
- Step 3: ask primary goals (multi-select), such as understand reports, nutrition, fitness, sleep, energy, healthy habits, or product comparisons.
- Step 4: collect optional body measurements only when relevant: height, weight, units, measurement date, source, and whether measured or estimated. Never require weight to use Ask.
- Step 5: collect health context progressively: conditions, allergies, medications/supplements, pregnancy/postpartum status, injuries, dietary pattern, restrictions, and relevant family history only when needed for the requested feature. Each field has “prefer not to say,” purpose, edit/delete controls, and provenance.
- Step 6: optional body avatar selection. Offer (a) neutral generic avatar, (b) adjustable body-shape/skin-tone representation, or (c) optional real photo for a narrowly defined feature. Avatar choice must not affect health inference. Do not require or encourage a full-body image.
- Step 7: connect devices one provider at a time, showing exact data types and purposes before native OS permission prompts.
- Step 8: notification choices; default to off for nonessential notifications. Users can manually configure reminders and system-critical alerts separately.
- Step 9: review profile, consent, and data controls; onboarding is complete when user can reach the product, not when every field is filled.

### Photo and avatar decision
**Default recommendation:** use an adjustable illustrative avatar, not a real photo. A photo is not required to estimate body composition, diagnose disease, or personalize most routines; image-based health inferences are error-prone and create high privacy risk. If a later feature has a validated, specific use case, request a separate opt-in upload, explain what is analyzed and retained, process minimally, and let the user delete the original and derived outputs. Never infer identity, race/ethnicity, disease, body fat, nutrition deficiency, or internal anatomy from appearance alone. Any image-based measurement requires validation, calibrated uncertainty, subgroup performance testing, and regulatory review.

## 5. Family history and profile data minimization
Ask family history only when relevant to a user-requested risk explanation or clinical context; make it optional. Capture only relationship category and condition, approximate onset/age range if the user knows it, and source (“family member told me”/“medical record”/“unknown”). Do not collect family members’ names, contact details, IDs, or full records by default. Treat family history as sensitive data about the user and potentially others. Explain that it is not a diagnosis. Do not calculate or present clinical risk scores without a validated model and appropriate governance.

## 6. Real-time expectations
“Real-time” means current when a source supports it, not continuous access to every device or instant updates everywhere.
- Live web/product/weather/provider data: show retrieval timestamp and source; cache according to source freshness and licensing.
- Device health data: read on explicit permission and OS/platform capability; sync when app/platform permits; show last successful sync and gaps.
- Body records: user uploads/imports or approved integrations; do not promise automatic access to all hospital records.
- Explore: current sources and professional availability only where a trustworthy live API exists; otherwise label last verified time.
- Growth: progress updates when user completes/logs a session or an authorized data source supplies it.
- Store: current stock, price, and batch information only if commerce/provider APIs confirm it.
- Reminders: no background promise unless device notification permission and platform scheduling permit it.

## 7. Notifications and reminders
- User-created reminders: explicit time/cadence/time zone, edit/pause/delete, quiet hours, and delivery status.
- System-generated important reminders: only for a clearly defined, user-authorized event or safety-critical workflow; explain why it is important, provide snooze/dismiss controls, rate-limit, and audit the trigger. Never silently create recurring reminders from inferred health data.
- No manipulative engagement nudges, guilt-based language, or notifications that reveal sensitive health data on a lock screen by default.
- Notifications are not an emergency service and must not delay urgent care.

## 8. Non-functional requirements
- Privacy by design; least privilege; explicit granular consent.
- Accessible responsive web/PWA and later Flutter Android/iOS clients.
- API contracts versioned; migrations reversible where practical.
- Evidence/provenance and audit trail for health-related claims.
- Clear failure states and degraded-mode behavior.
- Export/delete flows that cover all user-owned data and derived data where legally permitted.
- Observability without logging raw health payloads or secrets.
- Performance and reliability targets set after baseline load tests; do not invent SLOs before measurement.

## 9. MVP boundary
Build one trustworthy vertical slice first: onboarding + account + Ask with text/PDF/URL, retrieval, claim-level citations, answer verification, safe abstention, conversation history, export/delete controls, and public web deployment. The other tabs may be introduced in gated phases; they must not ship as empty visual shells pretending to work. Device health, real-time store, expert booking, video processing, image-based body measurements, and 3D anatomical personalization each require separate acceptance gates.

## 10. Success metrics
Product quality: citation support rate, source freshness, extraction accuracy, calculation correctness, abstention correctness, unsafe-answer rate, report parsing accuracy, user correction rate, and data export/delete success.
User value: time to first useful answer, task completion, week-4 retained users, user-reported usefulness, accessibility completion, and opt-in integration usage.
Business: activated users, retention, referrals, conversion, revenue actually collected, gross margin, refund/return rate, and support burden. Views and downloads alone are not product-market fit.

## 11. Release blockers
No launch if: user data isolation is unproven; export/delete is incomplete; secrets can reach client/logs; health claims lack source provenance; severe health risks do not route safely; backup restore has not been tested; provider spend/rate alerts are not configured; or a screen claims live functionality without a functioning data source.
