# Nutrient Earth — Scientific Data Acquisition & Integration Engine

## Overview
This directory contains the production data acquisition pipeline, schema definitions, API clients, and normalized scientific datasets for **Nutrient Earth**.

It automates the collection, validation, and normalization of scientific evidence across traditional systems of medicine (Ayurveda, Siddha, Unani), modern pharmacology, clinical trials, nutritional reference values, genomics, biomechanics, and environmental metrics.

---

## Directory Structure

```
research_data/
├── README.md                      # Master operational documentation
├── .env.example                   # Environment variable template
│
├── acquisition_registry/          # Metadata registries & manifests
│   ├── sources.json               # Complete audit of all 35 scientific sources
│   ├── datasets.json              # Dataset catalog and target definitions
│   ├── api_registry.json          # Verified endpoints, documentation, and rate limits
│   ├── licences.json              # Legal analysis and commercial SaaS terms
│   ├── acquisition_targets.json   # Batch definitions and target priority entities
│   ├── acquisition_status.json    # Live execution metrics and counts
│   ├── downloaded_documents_manifest.json # Complete checksum & provenance manifest (JSON)
│   └── downloaded_documents_manifest.csv  # Complete checksum & provenance manifest (CSV)
│
├── schemas/                       # JSON Schema (Draft-07) specifications
│   ├── research_record.schema.json
│   ├── herb_record.schema.json
│   ├── nutrient_record.schema.json
│   ├── compound_record.schema.json
│   ├── medicine_record.schema.json
│   ├── safety_record.schema.json
│   ├── anatomy_record.schema.json
│   ├── exercise_record.schema.json
│   ├── genetics_record.schema.json
│   └── environmental_record.schema.json
│
├── integrations/                  # Python acquisition codebase
│   ├── api_clients/               # Modular REST & web service clients
│   │   ├── base_client.py         # Retry backoff, rate limiting & error handling
│   │   ├── ayush_client.py        # AYUSH Portal ASP.NET session scraper
│   │   ├── dailymed_client.py     # NLM / FDA DailyMed SPL client
│   │   ├── rxnorm_client.py       # NLM RxNav clinical drug resolver
│   │   ├── livertox_client.py     # NCBI Bookshelf E-utilities LiverTox client
│   │   ├── gwas_client.py         # NHGRI-EBI GWAS Catalog v2 client
│   │   ├── clinvar_client.py      # NCBI ClinVar clinical significance client
│   │   ├── openstax_client.py     # OpenStax Anatomy 2e CMS client
│   │   ├── zenodo_client.py       # Zenodo Open Access REST client
│   │   ├── open_meteo_client.py   # Meteorological forecast client
│   │   └── osm_client.py          # OpenStreetMap Nominatim amenity client
│   ├── importers/                 # Normalizers into schema-conforming entities
│   ├── validators/                # Automated JSON Schema validator
│   └── update_jobs/               # Master execution orchestrators
│       ├── run_acquisition.py     # Multi-batch production acquisition engine
│       └── acquire_master_resources.py # Monograph downloader & dual JSONL/CSV exporter
│
├── raw/                           # Original unmodified JSON, TSV, and XML responses
│   ├── gwas_catalog/              # NHGRI-EBI GWAS alternative studies summary TSV (40.6 MB)
│   ├── open_meteo/                # Multi-year meteorological archives for major Indian cities
│   └── ...                        # Zenodo, DailyMed, ClinVar, LiverTox raw responses
│
├── normalized/                    # Validated datasets partitioned by domain (JSONL + CSV)
│   ├── research/                  # research_records.jsonl & research_records.csv
│   ├── herbs/                     # herbs_records.jsonl & herbs_records.csv
│   ├── nutrients/                 # nutrients_records.jsonl & nutrients_records.csv
│   ├── medicines/                 # medicines_records.jsonl & medicines_records.csv
│   ├── supplements/               # supplements_records.jsonl & supplements_records.csv
│   ├── exercise/                  # exercise_records.jsonl & exercise_records.csv
│   ├── genetics/                  # genetics_records.jsonl & genetics_records.csv
│   └── environment/               # environment_records.jsonl & environment_records.csv
│
├── documents/                     # Authentic publications, monographs, and guidelines
│   ├── pdf/                       # Open-access peer-reviewed clinical research papers
│   ├── publications/              # High-resolution CCRAS and Ministry of Ayush official monographs
│   └── reports/                   # Codex Alimentarius food standards and regulatory texts
│
├── reports/                       # Formal architectural and legal audits
│   ├── source_audit.md            # Live probe results of all 35 sources
│   ├── acquisition_report.md      # Summary metrics and acquired file inventory
│   ├── licensing_report.md        # IP, ODbL, CC BY-SA, and commercial terms
│   ├── data_quality_report.md     # Evidence hierarchy and quality controls
│   ├── unavailable_resources.md   # Gated sources and credential instructions
│   └── integration_readiness.md   # PostgreSQL schema & Flutter integration specs
│
└── tests/                         # Automated unit & integration tests
    └── test_acquisition_pipeline.py
```

---

## Operational Commands

### 1. Run the Complete Automated Test Suite
To verify that all schemas, importers, and normalizers pass with 100% conformance:
```powershell
python D:\Documents\NE_App\Nutrient_Earth\research_data\tests\test_acquisition_pipeline.py
```

### 2. Run Master Monograph Acquisition & Dual JSON/CSV Export
To acquire all official CCRAS/AYUSH publications, download bulk genomic datasets, compute SHA-256 hashes, and export all collections to CSV:
```powershell
python D:\Documents\NE_App\Nutrient_Earth\research_data\integrations\update_jobs\acquire_master_resources.py
```

### 3. Run Source Network Audit Probe (All 35 Sources)
To re-probe all 35 institutional endpoints and update `sources.json`:
```powershell
python D:\Documents\NE_App\Nutrient_Earth\research_data\integrations\audit_sources.py
```

### 4. Run Production Data Ingestion Batches
To execute the modular batch ingest across specific domains:
- **Ayurveda & Botanical Taxonomy:**
  ```powershell
  python D:\Documents\NE_App\Nutrient_Earth\research_data\integrations\update_jobs\run_acquisition.py --batch batch_01
  ```
- **Vitamins, Minerals & Safety:**
  ```powershell
  python D:\Documents\NE_App\Nutrient_Earth\research_data\integrations\update_jobs\run_acquisition.py --batch batch_02
  ```
- **DailyMed SPL & RxNorm Medicines:**
  ```powershell
  python D:\Documents\NE_App\Nutrient_Earth\research_data\integrations\update_jobs\run_acquisition.py --batch batch_03
  ```
- **Exercise & Biomechanics METs:**
  ```powershell
  python D:\Documents\NE_App\Nutrient_Earth\research_data\integrations\update_jobs\run_acquisition.py --batch batch_04
  ```
- **Genetics & ClinVar:**
  ```powershell
  python D:\Documents\NE_App\Nutrient_Earth\research_data\integrations\update_jobs\run_acquisition.py --batch batch_05
  ```
- **Zenodo Open Research:**
  ```powershell
  python D:\Documents\NE_App\Nutrient_Earth\research_data\integrations\update_jobs\run_acquisition.py --batch batch_06
  ```
- **Meteorology & Health Amenities:**
  ```powershell
  python D:\Documents\NE_App\Nutrient_Earth\research_data\integrations\update_jobs\run_acquisition.py --batch batch_07
  ```

---

## Scientific Rigor & Evidence Guidelines
1. **No Hallucinated Data**: Only real datasets with verified HTTP responses and provenance attributes are saved.
2. **Traditional vs Modern Evidence**: Traditional Ayurvedic attributes (Rasa, Virya, Vipaka, Prabhava) are preserved as cultural heritage in `herb_record.traditional_properties` and are strictly distinguished from randomized human clinical trials and biochemical assays.
3. **Safety First**: Hepatotoxicity warnings (LiverTox) and FDA boxed warnings (DailyMed) are indexed alongside dietary supplements and botanicals to safeguard user health.
