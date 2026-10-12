# Nutrient Earth — Five-Field UX & Interaction Specification

## Executive Overview

Nutrient Earth is composed of five distinct, interconnected fields. While all five share the authoritative brand tokens (Botanical Evergreen `#0E382B`, Luminous Lime `#B4F35E`, Warm Ivory `#FBF9F4`, and classical editorial typography), each field fulfills a fundamentally different product role and requires a distinct visual composition, information hierarchy, component inventory, and interaction model.

```
┌────────────────────────────────────────────────────────────────────────┐
│                          NUTRIENT EARTH SHELL                          │
├──────────────┬──────────────┬──────────────┬──────────────┬────────────┤
│   FIELD 1    │   FIELD 2    │   FIELD 3    │   FIELD 4    │  FIELD 5   │
│     ASK      │   EXPLORE    │    GROWTH    │     BODY     │   STORE    │
│  (Research)  │ (Discovery)  │   (Habits)   │ (Physiology) │(Formulation│
└──────────────┴──────────────┴──────────────┴──────────────┴────────────┘
```

---

## FIELD 1: ASK — Research and Personal Intelligence

### 1.1 Product Role & Value Proposition
**Ask** is the flagship workspace and the primary entry milestone of Nutrient Earth. It transforms user questions, symptoms, nutrition labels, and uploaded health documents into rigorously cited, evidence-backed answers synthesized by the deterministic clinical engine.

### 1.2 Visual Direction & Atmosphere
- **Quiet Scientific Workspace**: Distraction-free, tranquil Warm Ivory canvas (`#FBF9F4`).
- **Prominent Research Composer**: Central, inviting elevation with subtle botanical evergreen border (`#E3DDD3`).
- **Editorial Clinical Hierarchy**: Clear typographic distinction between direct answer synthesis, claim-level evidence chips, and clinical caveats.
- **Restrained Luminous Illumination**: Luminous Lime (`#B4F35E`) reserved strictly for verified citation badges and successful evidence match rings.

### 1.3 Information Architecture
1. **Workspace Header**: Minimal header showing active research context and environmental baseline (AQI, UV, temperature) from Open-Meteo.
2. **Research Query Composer**:
   - Multi-line text input with natural language prompt guidance.
   - Attachment tray (Camera/Photo, PDF Lab Report, Nutrition Label, Web URL).
   - Instant query clearing and active execution button.
3. **Emergency Triage Red Flag Alert (Conditional)**: Deterministic, high-priority alert card for acute cardiac, stroke, anaphylaxis, or crisis indicators.
4. **Structured Research Answer**:
   - **Executive Clinical Summary**: Direct, plain-language answer to the user's specific query.
   - **Synthesized Biological Mechanisms**: Clear explanation of biochemistry and physiological pathways.
   - **Claim-to-Citation Mapping**: Every factual assertion contains a clickable citation chip (`[1]`, `[2]`).
5. **Verified Evidence Drawer / Cards**:
   - Primary source badge (PubMed PMID, ClinicalTrials.gov NCT, USDA FoodData Central ID).
   - Study type indicator: Double-blind RCT, Meta-Analysis, Observational Cohort, In Vitro.
   - Study population, dosage, duration, and key statistical findings (p-values, relative risk).
   - Verifiable quote or passage from the primary source.
   - Direct external DOI/source hyperlink.
6. **Clinical Uncertainty & Limitations**:
   - Explicit callout of what the current medical literature does *not* know or where evidence is conflicting.
7. **Actionable, Evidence-Backed Next Steps**:
   - Practical dietary, lifestyle, or timing recommendations justified by the literature.
8. **Follow-Up Questions & Research History**:
   - Contextual follow-up suggestions and persistent session history drawer.

### 1.4 Field-Specific Components
- `NEResearchComposer`: Fluid multi-line text input with micro-actions for camera, gallery, document, and clear.
- `NEEvidenceCitationChip`: Inline superscript badge with verification status icon and modal sheet trigger.
- `NEClinicalAlertCard`: Surgical crimson triage banner with emergency instructions and zero AI-generated speculation.
- `NEEvidenceCard`: Expandable card displaying author, journal, year, study type, sample size, and extracted findings.
- `NEUncertaintyCallout`: Muted sage container highlighting evidentiary gaps and conflicting trial outcomes.

### 1.5 Comprehensive State Matrix

| State | Visual Manifestation | Component Behavior |
|---|---|---|
| **Empty / First Use** | Centered calm layout; prompt cards ("Analyze my sleep timing", "Evaluate creatine monohydrate", "Check my vitamin D level"). | Composer is focused; environmental weather pill is displayed; prompt cards populate query on tap. |
| **Composing** | Composer expands gracefully; character counter and attachment previews appear. | Execute button transitions from disabled sage to active Botanical Evergreen with lime micro-accent. |
| **Submission In Progress** | Input is locked; subtle progress indicator pulses with deterministic stage label ("Verifying query against safety engine..."). | No fake percentages; user can cancel in-flight request via stop button. |
| **Retrieving Evidence** | Dynamic status updates: "Querying PubMed & clinical trials database..." | Live skeleton shimmer on the answer canvas using Warm Ivory to Subtle Surface gradient. |
| **Answer Available** | Full structured answer renders with animated opacity fade (240ms); citation chips highlight. | User can tap any citation to open the source drawer; copy or export answer. |
| **Partial Evidence** | Answer provides what is known, accompanied by an amber caution card stating incomplete literature. | Explicitly labels conclusions as preliminary or observational. |
| **Conflicting Evidence** | Dual-column comparative section: "Studies showing benefit" vs "Studies showing no effect / risk". | Explains differing dosages, study durations, or demographic cohorts between trials. |
| **Insufficient Evidence (Abstention)**| Neutral sage card: "Current peer-reviewed scientific literature does not contain adequate evidence to answer this question reliably." | Recommends consulting a specialized healthcare practitioner; no hallucinated filler text. |
| **Emergency Red Flag** | Immediate crimson alert card (`#BA1A1A` on `#FDECEB`); immediate emergency contact options (911/112/988). | AI research engine completely abstains from casual speculation. |
| **Rate Limited (429)** | Amber banner: "Hourly research query limit reached. Resets in [X] minutes." | Explains quota transparently; circuit breaker prevents repeated failed API hits. |
| **Offline / Network Loss** | Offline notice banner with cached historical answer viewing enabled. | Composer is disabled with clear offline warning. |

### 1.6 Interaction & Safety Rules
- **Rule 1**: AI never replaces deterministic medical triage. Cardiac, stroke, respiratory, or psychiatric red flags immediately bypass LLM generation and trigger clinical emergency protocols.
- **Rule 2**: Every citation must link to a real, verified publication (PMID, DOI, USDA FDC ID). Fabricated citations are strictly prohibited.
- **Rule 3**: Entering and executing a question requires at most one tap from the home screen.

---

## FIELD 2: EXPLORE — Scientific Knowledge Discovery

### 2.1 Product Role & Value Proposition
**Explore** is the structured scientific compendium of Nutrient Earth. Unlike the conversational, prompt-driven workspace of Ask, Explore functions as an editorial medical encyclopedia. It allows users to browse peer-reviewed monographs on nutrients, botanical compounds, foods, and human biological pathways.

### 2.2 Visual Direction & Atmosphere
- **Editorial Scientific Journal**: Refined, magazine-style grid with ample white space and classical serif typography.
- **Botanical Illustrations**: High-fidelity, scientific line drawings and botanical specimen photography.
- **Structured Taxonomy**: Filterable category chips (Vitamins, Minerals, Amino Acids, Botanicals, Fatty Acids, Phytonutrients).

### 2.3 Information Architecture
1. **Curated Topic Header**: Featured clinical deep-dive of the week (e.g. "Creatine Monohydrate: Neurological Mechanisms Beyond Muscle").
2. **Category Navigation Pills**: Horizontally scrollable pill bar with active Botanical Evergreen pill and count badges.
3. **Search & Filter Drawer**: Instant filter by evidence grade (Meta-Analysis, Grade A RCT, Observational, Traditional Use).
4. **Knowledge Record Grid**:
   - Compound / Nutrient Name & Scientific Nomenclature (e.g. *Withania somnifera* / Ashwagandha).
   - Biological Mechanism Summary (1–2 sentences).
   - Primary Food / Natural Sources (with USDA nutritional density metrics).
   - Evidence Summary Bar (e.g., "14 RCTs • 3 Meta-Analyses").
   - Traditional vs Clinical Evidence demarcation badge.
5. **Direct Research Bridge**: "Ask about this compound" action button that transitions into Field 1 with a pre-filled, targeted prompt.

### 2.4 Field-Specific Components
- `NEKnowledgeCard`: Editorial card featuring compound title, botanical subtitle, summary finding, and evidence badge.
- `NEEvidenceGradeTag`: Strict visual taxonomy tag:
  - `Grade A`: Green fill, double checkmark (Multiple high-quality RCTs).
  - `Grade B`: Sage fill, single checkmark (Moderate RCTs / Cohort studies).
  - `Grade C`: Amber fill, question mark (Observational / Animal models).
  - `Traditional`: Ivory fill with botanical leaf (Historical ethnobotanical use, lacking clinical validation).
- `NECompoundDetailSheet`: Bottom sheet displaying pharmacokinetics, absorption co-factors, upper tolerable intake levels (UL), and contraindications.

### 2.5 Interaction Rules
- Never compute or display a single "Universal Health Score" or "Superfood Rating". Every compound has context-dependent efficacy and individual contraindications.
- Clearly separate traditional ethnobotanical claims from double-blind human clinical trials.

---

## FIELD 3: GROWTH — Habits and Personal Progress

### 3.1 Product Role & Value Proposition
**Growth** helps users track and sustain evidence-based health habits over time. It transforms clinical recommendations from Ask and Explore into actionable daily protocols (e.g., circadian photon exposure, morning electrolyte rehydration, postprandial ambulation, protein distribution).

### 3.2 Visual Direction & Atmosphere
- **Calm, Structured Routine Workspace**: Soothing, orderly list of daily protocols organized by biological circadian timing (Morning, Midday, Evening, Bedtime).
- **Subtle Habit Checkmarks**: Tactile, rewarding checkbox interactions using Botanical Evergreen and gentle Luminous Lime borders.
- **Restrained Weekly Trends**: Clean horizontal day-pills showing consistency without gamified dopamine streaks or punishing failure graphics.

### 3.3 Information Architecture
1. **Circadian Rhythm Header**: Current solar time, sunrise/sunset alignment, and optimal biological windows.
2. **Today's Active Protocols**:
   - Protocol Title (e.g. "Circadian Solar Photon Exposure").
   - Biological Rationale (Retinal ipRGC activation → SCN synchronization).
   - Recommended Timing & Duration (15–20 minutes within 60 min of waking).
   - Evidence Citation link (opens source in Ask).
   - Completion toggle with immediate tactile feedback.
3. **Weekly Consistency Matrix**: 7-day horizontal summary card showing completed protocols without aggressive streak counters.
4. **Protocol Library / Catalog**: Browse and adopt verified clinical protocols across Nutrition, Sleep, Movement, and Cognitive domains.
5. **Personal Reflection Notes**: Optional, private user notes on energy, focus, and digestion.

### 3.4 Field-Specific Components
- `NEProtocolTile`: Structured list item featuring protocol name, circadian clock icon, timing badge, completion checkbox, and scientific rationale accordion.
- `NECircadianPhaseIndicator`: Horizontal visual arc depicting current biological phase (Morning Cortisol Awakening, Afternoon Peak Performance, Evening Melatonin Onset).
- `NEWeeklyConsistencyGrid`: Monospace-style day matrix (`M T W T F S S`) with soft emerald fill indicators.

### 3.5 Interaction Rules
- **No Punitive Gamification**: Never shame users with broken streak counters or anxiety-inducing alert banners. Missed days are treated as neutral biological variations.
- **Never Claim Habits Are Clinical Cures**: Habit tracking supports lifestyle hygiene; it never claims to cure or reverse chronic disease without medical supervision.
- **Provenance Separation**: Clearly distinguish self-reported habit checkmarks from hardware-verified wearable sensor feeds.

---

## FIELD 4: BODY — Health Memory and Physiology

### 4.1 Product Role & Value Proposition
**Body** is the user's permanent, sovereign **Health Memory**. It organizes biometric measurements, laboratory blood panels, personal observations, and anatomical education into a unified physiological record owned entirely by the user.

### 4.2 Visual Direction & Atmosphere
- **Clinical Data Ledger**: High-contrast, tabular data presentation with crisp borders (`#E3DDD3`) and tabular numerals.
- **Educational Anatomical Map**: Elegant, stylized vector anatomy layers for organ system exploration (Cardiovascular, Metabolic, Musculoskeletal, Nervous, Endocrine, Digestive).
- **Scientific Reference Ranges**: Visual range bars illustrating normal, optimal, and out-of-range clinical reference intervals.

### 4.3 Information Architecture
1. **Health Memory Summary Card**: Total sovereign health records, latest imported lab panel date, and active data rights controls.
2. **Physiological System Navigator**:
   - Tabular grid of 6 primary organ systems with icon and functional summary.
   - Tap opens system deep-dive with key biomarkers and nutritional substrates.
3. **Biometric & Biomarker Ledger**:
   - Blood pressure, resting heart rate, fasting glucose, lipid panels, vitamin levels.
   - For every entry: Recorded value, unit, timestamp, measurement provenance (`User-reported`, `Wearable sync`, `Clinical lab report`).
   - Clinical reference range indicator (e.g. Fasting Glucose 70–99 mg/dL).
4. **Data Privacy & Export Console**:
   - One-tap cryptographic export of complete health history in JSON/CSV.
   - Selective purpose-specific consent toggles and permanent data purge trigger.

### 4.4 Field-Specific Components
- `NEBiomarkerTile`: Tabular item showing biomarker name, latest value, units, date, and visual reference range bar with optimal zone indicator.
- `NEPhysiologicalSystemCard`: Card highlighting system title, icon, summary physiology, key clinical biomarkers, and recommended nutritional substrates.
- `NEReferenceRangeBar`: Horizontal bar showing clinical lower limit, upper limit, and user's measured value with color-coded safety positioning.
- `NEDataRightsControlCard`: Prominent security card displaying local encryption status, consent ledger, and instant data export/delete actions.

### 4.5 Interaction Rules
- **Zero Medical Fabrication**: Never synthesize fake blood test results, estimated heart rates, or simulated organ scores. If no lab data is imported, display an honest, welcoming empty state with sample report import options.
- **Strict Provenance Labeling**: Every metric must visibly declare whether it was self-reported, imported from a clinical lab PDF, or synced from a device.
- **Separation of Educational vs Personal**: Anatomical diagrams are strictly educational layers and must never render simulated "inflamed" or "diseased" organ visualizations based on user questions.

---

## FIELD 5: STORE — Product and Formulation Intelligence

### 5.1 Product Role & Value Proposition
**Store** provides impartial formulation intelligence and ingredient verification. Rather than acting as a predatory e-commerce store pushing sponsored supplements, Store evaluates nutritional products against rigorous biochemical standards, certificate-of-analysis (CoA) assays, and independent laboratory testing.

### 5.2 Visual Direction & Atmosphere
- **Clean Formulation Catalog**: High-clarity product cards focusing on ingredient transparency, active constituent percentages, and testing certificates.
- **Nutritional Facts & Analytical Breakdown**: Authentic, standardized supplement facts panels with serving sizes, elemental yields, and chemical forms.
- **Zero Sponsored Clutter**: No popups, countdown sale timers, paid ranking badges, or affiliate banner advertisements.

### 5.3 Information Architecture
1. **Catalog Search & Category Filter**:
   - Search by active constituent (e.g., "TRAACS Magnesium Bisglycinate", "KSM-66 Ashwagandha", "Creapure Creatine").
   - Filter by certification (NSF Certified for Sport, USP Verified, Informed-Choice, Non-GMO).
2. **Formulation Benchmark Cards**:
   - Product title and formulation summary.
   - Elemental yield vs total compound weight (e.g. "200 mg Elemental Magnesium per 1000 mg Bisglycinate").
   - Third-party testing & certification badge.
   - Complete allergen disclosure.
   - Manufacturing standards (Cold-water extraction, solvent-free, heavy metal screening).
3. **Formulation Comparison Table**:
   - Side-by-side comparison of active bioavailability, excipients/fillers, cost-per-effective-dose, and third-party validation.
4. **Direct Research Bridge**:
   - "Verify formulation in Ask" button, opening Field 1 with the product's full constituent formula for clinical evidence scrutiny.

### 5.4 Field-Specific Components
- `NEFormulationCard`: Elegant card detailing formulation title, bioavailable active yields, certification seal, and allergen disclosures.
- `NEVerificationSeal`: Visual certification badge indicating whether the product has been verified by an independent accredited laboratory (USP, NSF, BSCG, ConsumerLab).
- `NEAllergenDisclosureBox`: High-visibility container disclosing presence or absence of major allergens (milk, eggs, fish, shellfish, tree nuts, peanuts, wheat, soybeans, sesame).
- `NEBioavailabilityRating`: Clear chemical breakdown explaining the absorption route of the compound (e.g. chelated amino acid dipeptide pathway vs inorganic oxide salt).

### 5.5 Interaction Rules
- **No Checkout Unless Formally Authorized**: E-commerce transactions and payment gateways remain completely disabled until certified supply-chain logistics and commercial licensing are approved.
- **Never Hide Fillers or Excipients**: Full disclosure of all ingredients including capsule shells, anti-caking agents, and flow agents.
- **No Undisclosed Commercial Sponsorship**: Products are indexed and compared strictly by chemical quality, third-party testing, and evidence support.

---

## Five-Field Architecture Summary Matrix

| Attribute | Field 1: Ask | Field 2: Explore | Field 3: Growth | Field 4: Body | Field 5: Store |
|---|---|---|---|---|---|
| **Core Metaphor** | Scientific Research Desk | Medical Library Journal | Circadian Lifestyle Routine | Clinical Health Memory | Analytical Laboratory Catalog |
| **Primary Action** | Compose question / analyze upload | Browse topics & evidence grades | Toggle daily completed protocols | Inspect biomarkers & export data | Compare chemical formulations |
| **Primary Component**| `NEResearchComposer` | `NEKnowledgeCard` | `NEProtocolTile` | `NEBiomarkerTile` | `NEFormulationCard` |
| **Dominant Accent** | Luminous Lime (`#B4F35E`) | Botanical Sage (`#526E60`) | Emerald Green (`#1E6B4A`) | Clinical Slate (`#2D5C88`) | Amber Gold (`#945B00`) |
| **Data Provenance** | PubMed / USDA / Groq | Scientific Literature / OLS | Self-Reported / Wearable | Lab Reports / Clinical Records | Certificates of Analysis / USP |
| **Safety Guard** | Red flag triage abstention | Grade A–C evidence tags | Non-punitive streaks | Reference ranges with units | Full allergen disclosure |
