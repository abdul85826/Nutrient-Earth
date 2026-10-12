# Nutrient Earth — Google Stitch Implementation Brief & Design Contract

## 1. Executive Directive to Google Stitch

This document constitutes the binding design specification and contract for all screens created in Google Stitch for **Nutrient Earth**.

Google Stitch must adhere strictly to the frozen brand tokens, typography, spatial geometry, and interaction invariants defined herein. 

### Core Design Imperatives
1. **The Supplied Logo is Authoritative**: The botanical evergreen, luminous chartreuse halo, warm ivory canvas, and classical serif monogram ("NE") establish the brand essence.
2. **Prioritize Field 1 (Ask) First**: Stitch must produce the complete end-to-end **Ask** research experience in the initial batch before proceeding to Explore, Growth, Body, or Store.
3. **Five Distinct Field Personalities**: Explore, Growth, Body, and Store must **never** be cloned copies of Ask with different headings. Each field possesses a distinct layout, information density, and component inventory.
4. **Zero Fabricated Precision**: Never generate screens displaying fake laboratory test values, synthetic health scores, invented prices, or imaginary citations.

---

## 2. Brand Tokens & Design System Contract

All mockups, components, and interactive prototypes generated in Stitch must utilize these exact design system tokens:

### 2.1 Color Palette
- **Canvas & Background**:
  - Primary Background: `Warm Ivory` (`#FBF9F4`)
  - Elevated Card Surface: `Pure White` (`#FFFFFF`)
  - Inset / Table Background: `Subtle Cream` (`#F3EFE6`)
- **Brand Colors**:
  - Primary Brand Green: `Botanical Evergreen` (`#0E382B`)
  - Brand Interactive Hover: `Evergreen Light` (`#1B4332`)
  - Deep Text & Obsidian Surfaces: `Deep Forest` (`#08231B`)
  - Luminous Illumination Accent: `Luminous Lime` (`#B4F35E`)
  - Accent Ring Glow: `Chartreuse Glow` (`#9EE854`)
- **Text Hierarchy**:
  - Primary Typography: `Obsidian Forest` (`#112019`)
  - Secondary Metadata / Subtitles: `Muted Sage` (`#526E60`)
  - Inactive / Footnotes: `Subdued Leaf` (`#7E9A8C`)
  - Inverted Text (on Evergreen buttons): `Warm Ivory` (`#FBF9F4`)
- **Semantic Feedback**:
  - Success / Verified: `Emerald Green` (`#1E6B4A` text, `#EBF5F0` surface)
  - Warning / Caution: `Amber Gold` (`#945B00` text, `#FDF4E5` surface)
  - Clinical Red Flag / Error: `Surgical Crimson` (`#BA1A1A` text, `#FDECEB` surface)
  - Educational Note: `Clinical Slate` (`#2D5C88` text, `#ECF3F9` surface)
- **Borders & Shadows**:
  - Border Subtle: `#E3DDD3` (1.0dp solid)
  - Divider Hairline: `#EFECE5` (0.75dp solid)
  - Elevation Shadow: `0px 3px 12px rgba(14, 56, 43, 0.05)`

### 2.2 Typography Hierarchy
- **Brand Display Headings**: High-contrast Serif (`Playfair Display` or `Georgia`).
  - Hero Display: 32sp, Bold (700), line height 1.25.
  - Section Heading: 22sp, SemiBold (600), line height 1.35.
- **Reading, Data & Controls**: Modern Functional Sans-Serif (`Inter` or `Roboto`).
  - Card Title: 18sp, SemiBold (600).
  - Body Prose: 16sp, Regular (400), line height 1.55.
  - Metadata / Captions: 14sp & 12sp, Regular (400), line height 1.45.
  - Button Labels: 14sp, SemiBold (600), +0.25sp tracking.
  - Tabular Biometrics: 20–28sp, Bold (700), tabular figures.

### 2.3 Geometry & Radii Scale
- Primary Cards: `16dp` rounded corners.
- Sub-cards & Data Tables: `12dp` rounded corners.
- Input Fields & Composer: `12dp` rounded corners.
- Action Buttons & Chips: `999dp` (pill radius) or `12dp` (standard rounded).
- Bottom Sheet Corners: `24dp` top-only radius.

---

## 3. Shared Components & Component States

Stitch must assemble screens using these standardized, reusable components:

| Component Name | Description | Required Interactive States |
|---|---|---|
| `NEButton` | Primary action button in Botanical Evergreen (`#0E382B`) with Warm Ivory text. | Default, Hover, Pressed, Loading (spinner), Disabled. |
| `NECard` | Elevated card container on Pure White with subtle border (`#E3DDD3`) and botanical shadow. | Flat, Hover elevation, Expanded, Selected. |
| `NEResearchComposer`| Floating query input box with attachment actions (camera, document, clear) and submit button. | Empty, Focused, Text populated, Disabled/Loading. |
| `NEEvidenceChip` | Inline pill indicating citation source (e.g. `[1] PubMed PMID: 31234567`). | Default, Hover, Active/Tapped, Verified. |
| `NENavigationBar` | Fixed 5-destination bottom bar with icons and text labels (Ask, Explore, Growth, Body, Store). | Inactive (sage `#7E9A8C`), Active (Evergreen `#0E382B` with indicator). |
| `NEStatusBanner` | Semantic alert card (Red flag crimson, Warning amber, Success emerald). | Default, Dismissible, Action button. |
| `NEBiomarkerBar` | Horizontal range indicator showing user value positioned against normal/optimal clinical range. | In range (green), Borderline (amber), Out of range (crimson). |

---

## 4. Implementation Phasing & Batch Priority

### BATCH 1 — THE COMPLETE "ASK" EXPERIENCE (MANDATORY FIRST SHIP)
Stitch must first deliver the complete, coherent research flow for Field 1:

1. **Screen 1.0 — Logo Splash & Transition**:
   - Master medallion centered on Warm Ivory canvas.
   - Restrained luminous lime outer glow (`#B4F35E`).
   - "NUTRIENT EARTH" wordmark, botanical triad emblem (`— 🌿 —`), and "A New LifeStyle" slogan.
2. **Screen 1.1 — Authentication & Welcome Entry**:
   - Serene welcome card stating core promise: *"Understand your health with evidence and practical next steps."*
   - Prominent Google Sign-In button (`Continue with Google`).
   - Non-blocking "Continue as Guest Explorer" action.
   - Privacy guarantee and sovereign data rights badge.
3. **Screen 1.2 — Ask Empty State (First Launch)**:
   - Quiet scientific workspace header with live environmental weather badge (AQI, UV, Temp).
   - Prominent, empty `NEResearchComposer` with placeholder *"Ask about symptoms, nutrients, blood tests, or medications..."*
   - Three evidence-based prompt starter cards:
     - *"What is the optimal timing and dose for magnesium bisglycinate?"*
     - *"Analyze the clinical evidence for postprandial walking on blood glucose."*
     - *"What are the verified biological co-factors for Vitamin D3 absorption?"*
4. **Screen 1.3 — Research Query In-Progress / Composing**:
   - Query typed into composer; camera photo thumbnail preview attached.
   - Active botanical evergreen submit button with lime micro-accent.
5. **Screen 1.4 — Research In-Flight Loading State**:
   - Composer disabled; deterministic progress stage label: *"Searching peer-reviewed clinical trials in PubMed..."*
   - Warm Ivory shimmer skeleton on the answer canvas (no fake percentage circles).
6. **Screen 1.5 — Structured Research Answer (Success)**:
   - Executive clinical summary in Georgia Display Serif.
   - Detailed biological mechanisms in functional sans-serif with inline citation chips (`[1]`, `[2]`).
   - Actionable dietary & lifestyle takeaways box with subtle green border.
   - Clinical limitations and scientific uncertainty callout.
7. **Screen 1.6 — Evidence Drawer / Source Inspection (Modal Sheet)**:
   - Tapping citation `[1]` slides up a 24dp rounded bottom sheet.
   - Displays full study title, primary authors, journal, year, study type (Double-Blind RCT), sample size ($n=120$), and verbatim study passage.
   - Direct clickable DOI external hyperlink.
8. **Screen 1.7 — Clinical Emergency Red Flag Triage**:
   - Triggered when query contains acute red flags (e.g. crushing chest pain, facial droop).
   - Prominent Surgical Crimson card (`#BA1A1A`) with immediate emergency contact actions.
   - Zero AI-generated speculation.
9. **Screen 1.8 — Insufficient Evidence / Abstention State**:
   - Clean, honest callout: *"Current peer-reviewed scientific literature does not contain adequate evidence to answer this question reliably."*

---

### BATCH 2 — EXPLORE (SCIENTIFIC KNOWLEDGE DISCOVERY)
- **Screen 2.1 — Scientific Catalog Home**:
  - Magazine-style topic hero: *"Creatine Monohydrate: Neurological Mechanisms Beyond Muscle"*.
  - Horizontal category pills: All, Vitamins, Minerals, Amino Acids, Botanicals, Fatty Acids.
  - Two-column grid of `NEKnowledgeCard` with evidence grade badges (Grade A, B, C, Traditional).
- **Screen 2.2 — Compound Monograph Detail**:
  - Pharmacokinetics, elemental yield, clinical trials summary, upper tolerable limits, and food sources.
  - "Verify in Ask" bridge button.

---

### BATCH 3 — GROWTH (HABITS & LIFESTYLE PROGRESS)
- **Screen 3.1 — Daily Protocol Flow**:
  - Circadian rhythm phase indicator (Morning Cortisol Awakening, Midday Energy, Evening Melatonin).
  - Four circadian protocol tiles with checkboxes: Solar Light Exposure, Morning Hydration, Protein Pacing, Postprandial Ambulation.
  - Scientific rationale expander beneath each protocol.
- **Screen 3.2 — Weekly Consistency Matrix**:
  - 7-day clean consistency matrix without gamified dopamine streaks or failure warnings.

---

### BATCH 4 — BODY (HEALTH MEMORY & PHYSIOLOGY)
- **Screen 4.1 — Health Memory Ledger**:
  - Sovereign health record counter and cryptographic export button.
  - 6 Physiological System cards (Cardiovascular, Metabolic, Musculoskeletal, Nervous, Endocrine, Digestive).
  - Biometric ledger showing latest Fasting Glucose, Blood Pressure, and ApoB with reference range bars.
- **Screen 4.2 — Biomarker Range Detail**:
  - Clinical reference interval card displaying user measurement date, unit, source provenance (`Clinical Lab PDF`), and reference boundaries.

---

### BATCH 5 — STORE (FORMULATION INTELLIGENCE)
- **Screen 5.1 — Formulation Benchmark Catalog**:
  - Product formulation cards showing active constituent yield, bioavailable chemical form, and testing certification seal (NSF, USP).
  - Complete allergen disclosure boxes.
  - E-commerce checkout disabled banner: *"Impartial formulation research catalog. Direct purchasing is disabled."*
- **Screen 5.2 — Formulation Comparison**:
  - Side-by-side comparison table of two competing magnesium formulations (Bisglycinate Chelate vs Oxide).

---

## 5. Prohibited Behaviors in Google Stitch

To maintain clinical integrity and user trust, Google Stitch must reject:
1. **No Fake Progress Percentages**: Never render progress bars claiming "87% analyzed" when querying databases.
2. **No Hallucinated Citations**: Never insert placeholder text like "Smith et al., Nature 2024" without actual clinical grounding.
3. **No Decorative Medical Heatmaps**: Never display colored heatmaps over photographs implying an algorithm can diagnose cancer or body fat from an image.
4. **No Gamified Anxiety Traps**: No burning flame streaks, countdown clocks, or punitive badges for missed daily habits.
5. **No Cloned Screens**: Explore, Growth, Body, and Store must have bespoke layouts tailored to their information architecture.

---

## 6. Acceptance Checklist for Stitch Screens

- [ ] **Brand Fidelity**: Uses authoritative Botanical Evergreen (`#0E382B`), Luminous Lime (`#B4F35E`), and Warm Ivory (`#FBF9F4`).
- [ ] **Typography**: High-contrast Serif for titles, Functional Sans for body/data, tabular numbers for biometrics.
- [ ] **Touch Targets**: All interactive elements are at least 48x48dp.
- [ ] **Contrast Compliance**: Body text achieves at least 4.5:1 (AA); primary text achieves 7:1 (AAA) against Warm Ivory.
- [ ] **Ask Batch Completeness**: All 9 screens of Batch 1 are fully designed and connected into a logical flow.
- [ ] **Source Inspectability**: Every citation chip links to an explicit source inspection sheet.
- [ ] **Medical Safety**: Emergency triage screen cleanly bypasses AI generation.
- [ ] **Navigation Consistency**: All 5 tabs are represented on the shared shell with Ask selected by default.
