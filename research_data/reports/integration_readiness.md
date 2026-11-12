# Nutrient Earth — Integration Readiness & Database Migration Guide

## Executive Summary
This guide specifies the production ingestion architecture for integrating the acquired scientific datasets and API clients into **Nutrient Earth's** database (Supabase / PostgreSQL) and Flutter client application (`client/`).

All data has been normalized into standardized JSON/JSONL files conforming to strict draft-07 schemas, making database loading and API serving straightforward, idempotent, and performant.

---

## 1. Database Architecture & PostgreSQL Schema Mappings

To support relational querying, vector similarity search, and high-performance caching in Supabase, the following target tables are recommended:

### Table 1: `public.scientific_research`
```sql
CREATE TABLE IF NOT EXISTS public.scientific_research (
    record_id TEXT PRIMARY KEY,
    source_id TEXT NOT NULL,
    original_source_id TEXT,
    title TEXT NOT NULL,
    authors TEXT[] DEFAULT '{}',
    abstract TEXT,
    publication_date TEXT,
    journal TEXT,
    doi TEXT,
    url TEXT,
    pdf_url TEXT,
    local_pdf_path TEXT,
    study_type TEXT NOT NULL,
    medical_system TEXT,
    intervention TEXT,
    comparator TEXT,
    evidence_type TEXT NOT NULL,
    keywords TEXT[] DEFAULT '{}',
    relevance_score NUMERIC(3, 2) DEFAULT 0.80,
    license TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_research_medical_system ON public.scientific_research(medical_system);
CREATE INDEX idx_research_evidence_type ON public.scientific_research(evidence_type);
CREATE INDEX idx_research_title_trgm ON public.scientific_research USING gin (title gin_trgm_ops);
```

### Table 2: `public.botanicals_and_herbs`
```sql
CREATE TABLE IF NOT EXISTS public.botanicals_and_herbs (
    herb_id TEXT PRIMARY KEY,
    accepted_botanical_name TEXT NOT NULL UNIQUE,
    botanical_synonyms TEXT[] DEFAULT '{}',
    common_names JSONB NOT NULL DEFAULT '{}',
    plant_family TEXT,
    traditional_systems TEXT[] DEFAULT '{}',
    traditional_properties JSONB DEFAULT '{}',
    traditional_uses TEXT[] DEFAULT '{}',
    documented_preparations TEXT[] DEFAULT '{}',
    active_phytochemicals JSONB DEFAULT '[]',
    toxicity_and_safety JSONB DEFAULT '{}',
    conservation_status TEXT,
    license TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_herbs_botanical_name ON public.botanicals_and_herbs(accepted_botanical_name);
```

### Table 3: `public.nutrients_reference`
```sql
CREATE TABLE IF NOT EXISTS public.nutrients_reference (
    nutrient_id TEXT PRIMARY KEY,
    nutrient_name TEXT NOT NULL,
    category TEXT NOT NULL,
    unit TEXT NOT NULL,
    physiological_functions TEXT[] DEFAULT '{}',
    reference_intakes JSONB NOT NULL DEFAULT '[]',
    deficiency_symptoms TEXT[] DEFAULT '{}',
    toxicity_symptoms TEXT[] DEFAULT '{}',
    dietary_food_sources TEXT[] DEFAULT '{}',
    jurisdiction TEXT NOT NULL,
    effective_date TEXT,
    evidence_source TEXT
);
```

### Table 4: `public.clinical_medicines`
```sql
CREATE TABLE IF NOT EXISTS public.clinical_medicines (
    medicine_id TEXT PRIMARY KEY,
    generic_name TEXT NOT NULL,
    brand_names TEXT[] DEFAULT '{}',
    rxcui TEXT,
    spl_set_id TEXT,
    active_ingredients JSONB DEFAULT '[]',
    dosage_forms TEXT[] DEFAULT '{}',
    routes_of_administration TEXT[] DEFAULT '{}',
    label_source_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_medicines_rxcui ON public.clinical_medicines(rxcui);
```

---

## 2. Automated PostgreSQL Bulk Ingestion Script

A ready-to-run bulk ingestion utility is provided in `research_data/integrations/importers/pg_loader.py` that streams the normalized JSONL files directly into PostgreSQL via standard COPY or parameter-bound upserts (`ON CONFLICT (record_id) DO UPDATE`).

### Execution Command:
```bash
python research_data/integrations/importers/pg_loader.py --db-url "postgresql://postgres:postgres@localhost:54322/postgres"
```

---

## 3. Flutter Client Integration Architecture

Inside the Flutter application (`client/lib/`):

1. **Repository Layer**:
   Create `ResearchRepository` in `client/lib/features/explore_research/data/repositories/research_repository.dart`:
   - Fetches paginated scientific papers by medical system (`Ayurveda`, `Siddha`, `Unani`, `Integrative_Medicine`).
   - Filters by evidence type (`human_clinical`, `animal_in_vivo`, `phytochemical_analytical`).
   - Supports offline caching using Hive or SQLite.

2. **State Management (Riverpod)**:
   - `scientificResearchProvider`: Queries Supabase with debounced search terms and filter chips.
   - `botanicalDetailProvider(herbId)`: Fetches botanical taxonomy, traditional properties (Rasa/Virya/Vipaka), and modern clinical evidence summaries.
   - `nutrientRdaProvider(userAge, userSex)`: Automatically computes personalized RDA and UL guidelines for the active user's demographic profile during calibration.

3. **UI Layer**:
   - `ExploreResearchScreen`: Displays peer-reviewed studies with badge indicators for study type (RCT, Systematic Review, Preclinical) and direct links to original open-access PDFs.
   - `UniversalReferenceAnswerCard`: Cites verified PMIDs, DOIs, and AYUSH portal references in response to user nutritional queries.

