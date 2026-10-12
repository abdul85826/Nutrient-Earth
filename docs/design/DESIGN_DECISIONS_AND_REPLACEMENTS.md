# Nutrient Earth — Design Decisions & Replacements Register

## Executive Summary

This register records every design, architectural, and visual specification decision established during the brand freeze and five-field UX design strategy. It explicitly documents previous assumptions or ambiguities across existing product documentation, the new approved standard, the affected documents, the technical rationale, and the downstream implementation constraints.

---

## 1. Decision & Replacement Ledger

| # | Previous Decision or Wording | New Approved Decision | Document & Section Affected | Rationale | Downstream Implementation Impact | Approval Status |
|---|---|---|---|---|---|---|
| **01** | General "green and ivory" palette with unspecified shades and ad-hoc secondary colors. | **Authoritative Botanical Evergreen System**: Primary Botanical Evergreen (`#0E382B`), Luminous Lime Illumination (`#B4F35E`), Warm Ivory Canvas (`#FBF9F4`), Obsidian Forest Text (`#112019`). | `docs/design/BRAND_AND_DESIGN_SYSTEM.md`; `04_UI_UX_DESIGN_BRIEF.md` §3 | Sampled directly from the official Nutrient Earth brand emblem. Ensures WCAG AAA contrast (12.6:1 for text) and serene botanical authority. | Replaces ad-hoc theme colors; establishes static tokens for Flutter theme and Stitch prototypes. | **Approved (Brand Authority)** |
| **02** | Luminous halo treated as possible full-screen glow or continuous pulsing card effect. | **Strictly Restrained Illumination**: The luminous lime ring (`#B4F35E`) is reserved strictly for the splash entrance, brand emblem, verified citation badges, and active research completion rings. Forbidden as background wallpaper or continuous pulsing loops. | `docs/design/BRAND_AND_DESIGN_SYSTEM.md` §3.6; `04_UI_UX_DESIGN_BRIEF.md` §3 | Continuous neon or glowing effects cause ocular fatigue and look like ungrounded crypto/gaming apps. Restrained use preserves clinical dignity. | Constrains animations in Flutter and Stitch to static or momentary transitions. | **Approved** |
| **03** | Generic serif or system font for entire application. | **Dual-Font Typographic Architecture**: High-contrast Display Serif (`Playfair Display` or `Georgia`) reserved for editorial titles, welcome headers, and answer summaries. Functional Sans-Serif (`Inter` or `Roboto`) for reading prose, controls, citations, and tabular data. | `docs/design/BRAND_AND_DESIGN_SYSTEM.md` §4; `04_UI_UX_DESIGN_BRIEF.md` §3 | Serif ensures editorial elegance reflecting the brand logo's classical craftsmanship; sans-serif ensures data legibility for dosage, lab values, and citations. | Flutter `ThemeData` and web font bundle configure both fonts; forbids serif in dense data tables. | **Approved** |
| **04** | Ambiguity on whether all 5 tabs should be built simultaneously or have identical conversational layouts. | **Ask-First Phasing & Five Distinct Field Layouts**: Field 1 (Ask) is the mandatory first implementation milestone. Explore, Growth, Body, and Store must have bespoke layouts (Journal, Circadian Checklist, Biomarker Ledger, Formulation Catalog) and must **never** be copies of Ask. | `docs/design/FIVE_FIELD_UX_SPECIFICATION.md`; `01_PRD.md` §1; `09_FEATURE_TICKETS.md` Epic 1 | Prevents empty cloned tabs and ensures each product field delivers distinct, non-redundant user value. | Stitch batching and Flutter development focus 100% on Ask first before expanding to other fields. | **Approved** |
| **05** | Ambiguity on whether users must complete a full profile or onboarding questionnaire before accessing research. | **Non-Blocking Ask Entry**: Users land directly on the Ask research workspace (`/ask`) upon successful authentication or guest entry. Profile completion is progressive, skippable, and just-in-time. | `docs/design/BRAND_AND_DESIGN_SYSTEM.md` §7; `03_APP_FLOW.md` §1 | Forcing users through multi-screen medical questionnaires before returning value destroys user trust and causes onboarding churn. | GoRouter defaults to `/ask`; onboarding flow is skippable at every step. | **Approved** |
| **06** | Vague loading states with potential simulated percentage indicators ("85% complete"). | **Deterministic Progress States Only**: Loading states must display honest, deterministic stage text (e.g. *"Querying PubMed clinical trials..."*) with a subtle skeleton shimmer. Fake progress bars, countdown timers, and percentage wheels are strictly banned. | `docs/design/FIVE_FIELD_UX_SPECIFICATION.md` §1.5; `08_AI_GUARDRAILS.md` §4 | Manufacturing progress percentages deceives users and violates scientific transparency. | Network/retrieval orchestrators emit discrete stage events, not simulated percentages. | **Approved** |
| **07** | Potential for store checkout or purchasing without validated supply chain. | **Impartial Formulation Intelligence Only**: Store acts as a chemical and nutritional facts evaluation tool. Direct purchasing and payment gateways remain completely disabled until certified logistics are approved. | `docs/design/FIVE_FIELD_UX_SPECIFICATION.md` §5; `02_TRD.md` §2 | Prevents predatory supplement commercialization and preserves independent scientific credibility. | Disables Stripe/Razorpay checkout buttons; focuses UI on formulation analysis and certificates of analysis. | **Approved** |
| **08** | Visual feedback on emergency queries potentially mixed with AI chat. | **Deterministic Clinical Emergency Red Flag Triage**: Acute symptoms (cardiac, stroke, respiratory distress, anaphylaxis, crisis) trigger an immediate, high-priority Surgical Crimson card (`#BA1A1A`) with emergency dialer links, completely bypassing AI text generation. | `docs/design/FIVE_FIELD_UX_SPECIFICATION.md` §1.3; `08_AI_GUARDRAILS.md` §2 | Eliminates patient harm from AI hallucinations during life-threatening acute medical emergencies. | Integrated directly into `MedicalSafetyGuard` in client and backend prior to any LLM prompt construction. | **Approved (Non-Negotiable Safety)** |

---

## 2. Downstream Implementation Impact Summary

1. **Flutter Client Layer (`client/lib/`)**:
   - `NEColors` and `NeTokens` in `client/lib/core/design_system/tokens/ne_tokens.dart` will be unified with the authoritative color palette (`#0E382B`, `#B4F35E`, `#FBF9F4`, `#112019`).
   - Reusable components (`ne_card.dart`, `ne_button.dart`, `ne_chip.dart`) align with `16dp` card radius and `999dp` pill actions.
   - Screen implementations retain the Ask-first architecture currently wired in `app_router.dart`.
2. **Google Stitch Layer**:
   - Stitch receives `STITCH_IMPLEMENTATION_BRIEF.md` as its strict prompt contract.
   - Batch 1 designs the 9 screens of the complete Ask flow (Splash, Welcome/Auth, Empty, Composing, In-Flight Shimmer, Structured Answer, Citation Modal Sheet, Emergency Triage, Abstention).
   - Subsequent batches design Explore, Growth, Body, and Store using their distinct architectural compositions.
3. **Product & Technical Documentation Layer**:
   - `01_PRD.md`, `02_TRD.md`, `03_APP_FLOW.md`, `04_UI_UX_DESIGN_BRIEF.md`, and `09_FEATURE_TICKETS.md` are synchronized to eliminate contradictions and reflect the frozen brand system.

---

## 3. Decisions Requiring Project Owner Confirmation

The following decisions have been established based on the frozen brand assets and clinical safety rules, and are ready for owner review:
1. **Font Licensing Choice**: The design system specifies `Playfair Display` (Google Fonts, SIL Open Font License) paired with `Inter` (SIL Open Font License) as the optimal cross-platform open-source fonts for Flutter and Web. If the owner has an exclusive commercial proprietary typeface for the "NE" monogram (such as Adobe Caslon Pro or Didot), it can be bundled via asset declaration.
2. **E-Commerce Commercialization Timing**: Store e-commerce checkout is currently disabled by specification, displaying formulation analysis and third-party lab testing. Owner confirmation is required before integrating commerce checkout APIs.
