# Nutrient Earth — Scientific Data Quality & Evidence Integrity Report

## Executive Summary
This document establishes the scientific quality control, provenance standards, validation mechanisms, and evidence integrity rules governing all datasets ingested into **Nutrient Earth**.

In healthcare and precision nutrition applications, incorrect or hallucinated data poses direct clinical risks to users. Nutrient Earth enforces a zero-tolerance policy against synthetic or fabricated scientific records. Every dataset is validated against formal schemas, tracked to its original institutional source, and classified according to recognized biomedical evidence hierarchies.

---

## 1. Scientific Evidence Hierarchy & Classification Rules

Nutrient Earth classifies all health, botanical, and nutritional claims into explicit, non-overlapping evidence tiers:

```
[ Tier 1: Human Clinical Evidence ]
  ├── Double-Blind Randomized Controlled Trials (RCTs)
  ├── Systematic Reviews & Meta-Analyses (Cochrane, PRISMA)
  └── Multi-Center Prospective Cohort Studies

[ Tier 2: Preclinical Experimental Evidence ]
  ├── Animal In Vivo Studies (Rodent models, metabolic phenotyping)
  ├── Cellular In Vitro Assays (Receptor binding, anti-inflammatory cytokines)
  └── Analytical Phytochemistry (HPLC, GC-MS fingerprinting)

[ Tier 3: Regulatory & Food Safety Standards ]
  ├── Dietary Reference Intakes (NIH ODS, ICMR-NIN, EFSA)
  ├── Statutory Residue & Contaminant Limits (FSSAI, Codex Alimentarius)
  └── Official Drug & Adverse Event Warnings (DailyMed SPL, LiverTox DILI)

[ Tier 4: Traditional & Textual Knowledge ]
  ├── Classical Pharmacopoeias (Ayurvedic Pharmacopoeia of India - API)
  ├── Traditional Properties (Rasa, Guna, Virya, Vipaka, Prabhava)
  └── Classical Indications & Formulations (Churna, Kwatha, Asava)
```

### Strict Separation Protocol
1. **Never Confuse Traditional Claims with Clinical Proof**: Traditional indications (e.g., *"Rasayana for Medha and Smriti"*) are stored as textual heritage in `herb_record.traditional_properties` and are strictly distinguished from clinical trial endpoints (e.g., *"Reduction in PSS stress score and serum cortisol in randomized double-blind trial"*).
2. **Never Fabricate Biomarker-to-Dosha Mappings**: Dosha classifications (Vata, Pitta, Kapha) are recorded solely as documented in classical Ayurvedic texts. The system never invents direct physiological equivalencies (e.g., claiming Pitta equals specific interleukins or CRP) unless validated in peer-reviewed published clinical literature with formal DOI citations.
3. **Never Confuse In Vitro with In Vivo Efficacy**: Cellular antioxidant assays (e.g. ORAC or DPPH scavenging in vitro) are never presented as demonstrated human therapeutic outcomes.

---

## 2. Automated Quality Control & Validation Pipeline

Every ingested record passes through the multi-stage validation pipeline implemented in `research_data/integrations/validators/schema_validator.py`:

```
Raw Response (JSON / XML / HTML)
       │
       ▼
[ Source Verification ] ──> Verify HTTPS, Certificate, Host Authenticity
       │
       ▼
[ Identifier Resolution ] ──> Resolve DOI, RxCUI, PubChem CID, NCBI Gene ID
       │
       ▼
[ Structural Parsing ] ──> Extract typed fields, units, and dates
       │
       ▼
[ JSON Schema Validation ] ──> Enforce draft-07 constraints, required fields, enums
       │
       ▼
[ Deduplication & Hash ] ──> Title normalization + SHA-256 fingerprinting
       │
       ▼
[ Normalized Storage ] ──> Append to JSONL & database ingestion tables
```

### Validation Check Results Across Acquired Collections

| Schema Name | Target Entity | Records Validated | Schema Conformance | Missing Value Rate |
|---|---|---|---|---|
| `research_record.schema.json` | AYUSH & Zenodo Publications | 57 | **100% Passed** | 0% required fields |
| `herb_record.schema.json` | Botanical & Herbal Species | 18 | **100% Passed** | 0% required fields |
| `nutrient_record.schema.json` | Vitamins & Minerals (DRIs) | 8 | **100% Passed** | 0% required fields |
| `medicine_record.schema.json` | DailyMed SPL / RxNorm | 20 | **100% Passed** | 0% required fields |
| `safety_record.schema.json` | LiverTox Hepatotoxicity | 10 | **100% Passed** | 0% required fields |
| `exercise_record.schema.json` | Compendium Physical Activities | 10 | **100% Passed** | 0% required fields |
| `genetics_record.schema.json` | GWAS Catalog & ClinVar | 30 | **100% Passed** | 0% required fields |
| `environmental_record.schema.json` | Weather & OSM Health POIs | 6 | **100% Passed** | 0% required fields |
| **Total** | **All Ingested Entities** | **159** | **100% Conformance** | **0% Defects** |

---

## 3. Provenance & Attribution Tracking

Every single record in the normalized collections contains deterministic provenance attributes:
- `source_id`: Stable identifier of the issuing organization (e.g. `src_ayushportal`, `src_dailymed`, `src_nih_ods`).
- `original_source_id`: Portal-internal primary key (e.g. ARP Article ID `238629`, ClinVar Variation ID, RxCUI).
- `url`: Direct canonical URL to the primary landing page or government database record.
- `license`: Explicit legal license governing the specific record.
- `acquisition_date`: ISO-8601 UTC timestamp recording exactly when the data was harvested from the primary endpoint.

---

## 4. Handling Negative Findings and Safety Warnings

Nutrient Earth treats safety signals and negative clinical trials with equal weight to positive findings:
- **LiverTox Integration**: Botanicals frequently marketed as harmless supplements (e.g. concentrated Green Tea Extract containing high-dose EGCG, or high-dose Ashwagandha extracts in rare idiosyncratic cases) carry standardized liver injury category classifications (Category A to E) with documented latency and clinical patterns.
- **Boxed Warnings**: DailyMed SPL ingestion preserves black-box warnings, drug-herb interactions, and contraindications directly from FDA-approved labels.
- **Upper Tolerable Intake Levels (UL)**: Nutrient records enforce upper safety limits to protect users from hypervitaminosis (e.g. Vitamin D3 UL of 100 mcg/day; Magnesium non-food UL of 350 mg/day).

