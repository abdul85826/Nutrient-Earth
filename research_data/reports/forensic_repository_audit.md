# Nutrient Earth — Forensic Repository Audit & 55-Source Registry Report

**Date:** 2026-11-18  
**Auditor:** Principal Research Systems Architect, AI Systems Engineer, Scientific Data Engineer  
**Objective:** Complete forensic audit of existing research acquisition, database schemas, edge functions, and client repositories prior to Phase 2 implementation.

---

## 1. Executive Summary

Nutrient Earth contains extensive scientific schemas and pipeline scripts, but their operational capabilities were previously fragmented across three disconnected silos:
1. **Python Pipeline (`scripts/ayush_pipeline/`)**: Rich 8-phase acquisition, relevance ranking, and text extraction for traditional medicine and AYUSH literature.
2. **Supabase PostgreSQL Migrations (`supabase/migrations/`)**: Master scientific knowledge foundation (`20261112000001`), pgvector embeddings (`20261106000100`), clinical health foundation (`20261108000001`), bitemporal memory (`20261117000005`), and daily research editions (`20261117000006`).
3. **Edge Functions (`supabase/functions/research-synthesizer/`)**: Multi-provider AI gateway (Groq, Gemini) with PII privacy guarding and citation constraints.

### The Missing Bridge
The architecture lacked:
- A unified multi-source research adapter and controlled web crawler that respects robots.txt, defends against SSRF and prompt injection, and extracts structured claims from PubMed, Europe PMC, OpenAlex, USDA, and FSSAI.
- A food-processing transformation engine modeling nutrient changes (retention vs concentration, leaching, antinutrients, resistant starch) across cooking methods.
- A utensil and food-contact material safety engine (acidic food migration, temperature limits, coating wear).
- An evidence-backed everyday practice and cancer-risk hazard assessment engine.

---

## 2. 55-Source Scientific Acquisition Registry Status

| # | Source ID | Name | Integration Tier | Status & Verified Capability |
|---|---|---|---|---|
| 1 | `src_pubmed` | PubMed (NLM / NCBI) | Core Search | HTTP 200, E-utilities JSON/XML search & summary |
| 2 | `src_ncbi_eutils` | NCBI E-utilities | Core Search | HTTP 200, Entrez API for PMIDs, abstracts, links |
| 3 | `src_europe_pmc` | Europe PMC | Core Search | HTTP 200, REST API for open access papers & grants |
| 4 | `src_pmc_oa` | PMC Open Access / BioC | Full Text | HTTP 200, Full-text XML and structured text extraction |
| 5 | `src_clinical_trials` | ClinicalTrials.gov (API v2) | Clinical Evidence | HTTP 200, Study protocols, outcomes, NCT IDs |
| 6 | `src_openalex` | OpenAlex | Research Discovery | HTTP 200, Scholarly graph, citations, open access links |
| 7 | `src_crossref` | Crossref | DOI Resolution | HTTP 200, Metadata & DOI resolution (CC0) |
| 8 | `src_semantic_scholar` | Semantic Scholar | Graph Discovery | HTTP 429/Partner, Paper graphs & TLDR summaries |
| 9 | `src_usda_fdc` | USDA FoodData Central | Food Composition | HTTP 200, API client implemented (`usda_food_data_central_provider.dart`) |
| 10 | `src_fao_infoods` | FAO/INFOODS | Food Composition | HTTP 200, International food composition tables |
| 11 | `src_open_food_facts` | Open Food Facts | Packaged Food | HTTP 200/ODbL, Barcode, ingredient labels, additives |
| 12 | `src_lotus` | LOTUS Natural Products | Chemistry/Botanical | HTTP 200, Organism-to-molecule natural product mappings |
| 13 | `src_pubchem` | PubChem (NCBI) | Compound Database | HTTP 200, PUG-REST API for structures, bioactivity |
| 14 | `src_chebi` | ChEBI (EMBL-EBI) | Chemical Ontology | HTTP 200, Small molecular entities & biological roles |
| 15 | `src_chembl` | ChEMBL (EMBL-EBI) | Bioactivity Database | HTTP 200/Rest, Drug targets, bioactivities, assays |
| 16 | `src_bindingdb` | BindingDB | Binding Affinities | HTTP 200, Measured protein-ligand binding constants |
| 17 | `src_gbif` | GBIF | Biodiversity | HTTP 200, Species occurrences and taxonomy |
| 18 | `src_wfo` | World Flora Online | Plant Taxonomy | Static/Catalog, Canonical plant nomenclature |
| 19 | `src_powo` | Plants of the World Online | Botanical Kew | HTTP 200, Kew royal botanical gardens taxonomy |
| 20 | `src_wikidata` | Wikidata | Knowledge Graph | HTTP 200, Cross-database entity linking |
| 21 | `src_ayushportal` | AYUSH Research Portal | Traditional Medicine | HTTP 200, Clinical studies in Ayurveda/Siddha/Unani |
| 22 | `src_ayush_ministry` | Ministry of Ayush | Policy & Evidence | HTTP 200, Pharmacopeial standards & guidelines |
| 23 | `src_ccras` | CCRAS | Research Council | HTTP 200, Monographs, drug development monographs |
| 24 | `src_nmpb` | National Medicinal Plants Board | Botanical Cultivation | HTTP 200, Agro-techniques & commercial standards |
| 25 | `src_nih_ods` | NIH Office of Dietary Supplements | Supplements | HTTP 200, Fact sheets on vitamins, minerals, botanicals |
| 26 | `src_nccih` | NCCIH | Integrative Health | HTTP 200, Clinical digests on natural products & practices |
| 27 | `src_livertox` | LiverTox (NCBI) | Hepatotoxicity | HTTP 200, Drug- and herb-induced liver injury grading |
| 28 | `src_dailymed` | DailyMed (FDA/NLM) | Drug Safety | HTTP 200, Official package inserts & drug labels |
| 29 | `src_rxnorm` | RxNorm (NLM) | Normalized Meds | HTTP 200, Standardized medication identifiers |
| 30 | `src_medlineplus` | MedlinePlus (NLM) | Consumer Health | HTTP 200, Health topics, consumer explanations |
| 31 | `src_who` | World Health Organization | Global Guidelines | HTTP 200, Contaminant limits, chronic disease guidelines |
| 32 | `src_openstax` | OpenStax Anatomy | Physiology | HTTP 200, Peer-reviewed textbook anatomy and physiology |
| 33 | `src_compendium_pa` | Compendium of Physical Activities | Exercise Science | HTTP 200, MET values for physical activities |
| 34 | `src_addbiomechanics` | AddBiomechanics | Biomechanics | HTTP 200, Kinematics and kinetics motion datasets |
| 35 | `src_sports2d` | Sports2D | Movement Analytics | HTTP 200, Computer-vision kinematic pipeline |
| 36 | `src_zanatomy` | Z-Anatomy | 3D Anatomy | HTTP 200, Open-source anatomical models |
| 37 | `src_physionet` | PhysioNet | Physiological Data | HTTP 200, ECG, photoplethysmography, sleep waveforms |
| 38 | `src_osf` | Open Science Framework | Reproducibility | HTTP 200, Preregistered protocols and datasets |
| 39 | `src_zenodo` | Zenodo (CERN) | Scientific Datasets | HTTP 200, Open scientific datasets and code |
| 40 | `src_gwas_catalog` | GWAS Catalog (NHGRI-EBI) | Human Genetics | HTTP 200, SNP-trait associations |
| 41 | `src_clinvar` | ClinVar (NCBI) | Genomic Variants | HTTP 200, Human genetic variants and disease links |
| 42 | `src_ensembl` | Ensembl | Genomics | HTTP 200, Gene models, variant effect predictor |
| 43 | `src_clingen` | ClinGen | Gene-Disease Validity | HTTP 200, Curated clinical validity of genes |
| 44 | `src_pharmgkb` | PharmGKB | Pharmacogenomics | HTTP 200, Gene-drug interactions and dosing guidelines |
| 45 | `src_ogd_india` | data.gov.in | Indian Open Data | HTTP 200, Open government data catalog |
| 46 | `src_agmarknet` | Agmarknet | Agricultural Markets | HTTP 200, Mandi commodity arrivals and quality grades |
| 47 | `src_enam` | eNAM | Agriculture Trading | HTTP 200, National agricultural market data |
| 48 | `src_fssai` | FSSAI | Food Safety Standards | HTTP 200, Food contaminants, pesticide MRLs, adulteration |
| 49 | `src_codex` | Codex Alimentarius | International Food | HTTP 200, International food standards, max residue limits |
| 50 | `src_openaq` | OpenAQ | Air Quality | HTTP 200, Global real-time PM2.5, PM10, ozone, NO2 |
| 51 | `src_nasa_earthdata` | NASA Earthdata | Environmental | HTTP 200, Satellite land surface temperature, vegetation |
| 52 | `src_osm` | OpenStreetMap / Nominatim | Spatial Context | HTTP 200, Points of interest, parks, sports infrastructure |
| 53 | `src_overpass` | Overpass API | Spatial Queries | HTTP 200, Query engine for OpenStreetMap geospatial data |
| 54 | `src_open_meteo` | Open-Meteo | Weather & UV | HTTP 200, Telemetry active in Flutter app |
| 55 | `src_iucn_redlist` | IUCN Red List | Conservation | HTTP 200, Threatened botanical species conservation status |

---

## 3. Database Schema Reusability & Alignment

Existing migrations in `supabase/migrations/` provide high-performance building blocks:
- `20261112000001_master_scientific_knowledge_foundation.sql`: Already contains `scientific_sources`, `scientific_publications`, `clinical_trials_catalog`, `botanical_taxa`, `nutrients_catalog`, `food_composition_items`, `safety_evidence_records`.
- `20261106000100_enable_pgvector_and_evidence_embeddings.sql`: pgvector extension enabled with IVFFlat and HNSW cosine indexes on chunk embeddings.
- `20261117000005_bitemporal_personal_memory.sql`: Bitemporal facts and versions (`valid_time` vs `system_time`).
- `20261117000006_daily_scientific_intelligence.sql`: Daily editions, bilingual summaries, and 60-second read session tracking.
- `20261117000007_movement_and_action_engine.sql`: JITAI movement tasks with weather/AQI adaptation.

To fully satisfy the Master Directive, we will create:
- `20261118000001_universal_research_and_food_intelligence.sql`:
  1. `research_search_queries` & `research_retrieval_runs`
  2. `crawler_domain_policies` & `crawled_pages` (with robots.txt directives, ETag, content hash, SSRF defense)
  3. `scientific_claims` & `claim_contradictions` (claim-level verification, study design hierarchy, retraction status)
  4. `ingredient_processing_operations` & `nutrient_transformation_rules` (retention vs concentration, leaching, antinutrients, resistant starch)
  5. `utensil_food_contact_materials` & `material_migration_profiles` (food acidity, temperature limits, coating wear, EFSA/FSSAI standards)
  6. `food_contaminants_and_hazards` & `cancer_exposure_assessments` (IARC classifications, acrylamide, HCA/PAH, heavy metals, adulteration)
  7. `evidence_backed_practices` (practical life hacks with effect sizes, contraindications, and protocol steps).
