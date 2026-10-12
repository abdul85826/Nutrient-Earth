# Nutrient Earth — UI/UX Design Brief

## 1. Design principle
Calm, precise, evidence-forward, respectful, and accessible. Avoid “medical certainty” visual language when the data is incomplete. A beautiful interface must not conceal uncertainty or pretend a nonfunctional tab is live.

## 2. Information hierarchy
Every health-related answer/detail page should make these visible in order:
1. Direct answer or user goal.
2. What is known from the user's supplied/permissioned data.
3. Evidence and source citations.
4. What remains unknown or uncertain.
5. Safe, practical next steps.
6. Relevant limitations and escalation guidance.
7. Source/data freshness and controls.

## 3. Core design system
Define tokens centrally in `BRAND_AND_DESIGN_SYSTEM.md`:
- **Color Roles**: Primary Botanical Evergreen (`#0E382B`), Interactive Evergreen Light (`#1B4332`), Obsidian Forest Text (`#112019`), Luminous Lime Illumination (`#B4F35E`), Warm Ivory Canvas (`#FBF9F4`), Elevated Surface White (`#FFFFFF`), Subtle Cream (`#F3EFE6`), Subtle Border (`#E3DDD3`).
- **Luminous Illumination Constraint**: The logo's luminous lime halo is reserved for brand entrance, verification badges, and completion moments; never used as full-screen glow or continuous pulsing loops.
- **Typography**: Dual-font architecture—High-Contrast Display Serif (`Playfair Display` or `Georgia`) for editorial titles, and Functional Sans-Serif (`Inter` or `Roboto`) for reading prose, tabular biometric data, and controls.
- **Geometry & Spacing**: 4dp spatial grid scale (4, 8, 12, 16, 20, 24, 32, 48, 64dp); 16dp primary card radius, 12dp input radius, 999dp pill radius. Minimum 48dp touch targets.
- **Contrast**: Full WCAG 2.1 AAA compliance for primary text (12.6:1) and AA for secondary metadata (5.2:1) over Warm Ivory.

## 4. Five-field structure
Each of the five fields possesses a distinct product role, visual layout, and component inventory:
- **Ask (Field 1 — Research & Personal Intelligence)**: Primary flagship destination. Quiet scientific workspace with central `NEResearchComposer`, editorial answer hierarchy, inline clickable citations `[1]`, verified source drawer, and immediate deterministic clinical red-flag triage.
- **Explore (Field 2 — Scientific Knowledge Discovery)**: Editorial scientific journal. Structured taxonomy (Vitamins, Minerals, Amino Acids, Botanicals), evidence grade badges (Grade A, B, C, Traditional), and pharmacokinetics detail sheets. Never a conversational prompt clone.
- **Growth (Field 3 — Habits & Lifestyle Progress)**: Calm circadian workspace. Day-timed protocols (Morning Solar Exposure, Hydration, Protein Pacing, Postprandial Ambulation), non-punitive weekly consistency matrix, and zero anxiety-inducing streak breaks.
- **Body (Field 4 — Health Memory & Physiology)**: Sovereign health record. Tabular biomarker ledger with clinical reference intervals, 6-system physiological anatomical map, provenance tags (`Lab PDF`, `Wearable`), and cryptographic data export console.
- **Store (Field 5 — Product & Formulation Intelligence)**: Impartial formulation benchmark catalog. Complete ingredient transparency, bioavailable elemental yields, allergen disclosure, and third-party laboratory seals (USP, NSF). Direct checkout is permanently disabled.

## 5. Evidence components
- Citation chip opens source metadata: title, publisher, publication date, access date, link, relevant passage, and source type.
- Evidence quality label must have a defined rubric and explanatory tooltip; it is not a probability that the answer is true.
- Distinguish “supported by source,” “calculated,” “inferred,” “reported by user,” “not verified,” and “unknown.”
- A generated visual carries a persistent “AI-generated illustration” label.
- A product claim must link to product-specific evidence, not a generic homepage.

## 6. Onboarding UX
Progressive, skippable, one purpose per screen. Show progress but do not punish skipping. Ask for name, age/DOB, sex-related details, height/weight, health conditions, medications, allergies, family history, and photo only when a specific feature needs them. Use a “Why we ask” explanation beside sensitive fields. Never default a sensitive field from inference. Use “prefer not to say” where appropriate.

## 7. Body/avatar UX
Default to a neutral illustrated body/avatar with configurable presentation. Offer no-photo path permanently. Never make body shape or skin tone a proxy for diagnosis, risk, race, or health. Real-photo features require separate consent, visible processing purpose, retention controls, and a deletion path. Do not show false precision or medical heatmaps from a photograph.

## 8. Real-time and stale data
Every live/connected card displays “Updated [time]” and a freshness state. Distinguish live provider data, last synced device data, manually entered data, and stale/unknown. Include refresh and source details. If a provider is offline, show last-known data without implying current state.

## 9. Notifications and reminders
Settings should show every active reminder, origin (user-created/system rule), schedule, timezone, channel, last delivery, pause/delete controls. Lock-screen notification content defaults to privacy-preserving generic text. Marketing notifications off by default.

## 10. Required states
For every screen, design: initial/empty, loading, success, partial data, stale data, permission denied, offline, provider rate-limited, failed retry, permanent failure, and accessibility mode. Long-running jobs need progress stages without fake percentage estimates.

## 11. UI acceptance
- No fabricated numbers, ratings, citations, or availability.
- Every claim of “connected,” “synced,” “verified,” or “tested” has a backend-supported state.
- Focus order and screen-reader names are tested.
- Charts expose text summaries and data tables.
- All consent and data-control screens are reachable without support intervention.
