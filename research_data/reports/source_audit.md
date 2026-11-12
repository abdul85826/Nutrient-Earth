# Nutrient Earth — Master 55-Source Scientific Registry & Discovery Audit

**Audit Execution Timestamp:** 2026-11-11 19:37:04 UTC  
**Total Scope:** 55 Authoritative Scientific, Botanical, Nutritional, and Clinical Data Sources  

## 1. Executive Summary Table

| # | Source ID | Name | Category | Status | Format | Auth | Commercial Terms |
|---|---|---|---|---|---|---|---|
| 1 | `src_pubmed` | PubMed (NLM / NCBI) | A_research_literature | HTTP 200 | JSON | Free | Permitted (Public Domain) |
| 2 | `src_ncbi_eutils` | NCBI E-utilities | A_research_literature | HTTP 200 | JSON | Free | Permitted (Public Domain) |
| 3 | `src_europe_pmc` | Europe PMC | A_research_literature | HTTP 200 | JSON | Free | Permitted for CC BY / CC0 articles; ... |
| 4 | `src_pmc_oa` | PMC Open Access / BioC API | A_research_literature | HTTP 200 | JSON | Free | Permitted according to individual ar... |
| 5 | `src_clinical_trials` | ClinicalTrials.gov (API v2) | A_research_literature | HTTP 200 | JSON | Free | Permitted (Public Domain) |
| 6 | `src_openalex` | OpenAlex | A_research_literature | HTTP 200 | JSON | Free | Permitted without restriction (CC0) |
| 7 | `src_crossref` | Crossref | A_research_literature | HTTP 200 | JSON | Free | Permitted (CC0 for metadata) |
| 8 | `src_semantic_scholar` | Semantic Scholar (Graph API v1) | A_research_literature | HTTP 429 | Unknown | Free | Partner/Licensed access required for... |
| 9 | `src_usda_fdc` | USDA FoodData Central (FDC) | A_research_literature | HTTP 200 | JSON | Key Required | Permitted (Public Domain) |
| 10 | `src_fao_infoods` | FAO/INFOODS Food Composition Databases | A_research_literature | HTTP 200 | HTML | Free | Attribution required; commercial lic... |
| 11 | `src_open_food_facts` | Open Food Facts | A_research_literature | HTTP 503 | Unknown | Free | Permitted with ODbL Share-Alike & At... |
| 12 | `src_lotus` | LOTUS Initiative (Natural Products) | A_research_literature | HTTP 200 | JSON | Free | Permitted without restriction (CC0) |
| 13 | `src_pubchem` | PubChem (NCBI) | B_chemistry_botanical | HTTP 200 | JSON | Free | Permitted (Public Domain) |
| 14 | `src_chebi` | ChEBI (EMBL-EBI / OLS4) | B_chemistry_botanical | HTTP 200 | JSON | Free | Permitted with attribution |
| 15 | `src_chembl` | ChEMBL (EMBL-EBI) | B_chemistry_botanical | HTTP 500 | Unknown | Free | Permitted with attribution and share... |
| 16 | `src_bindingdb` | BindingDB | B_chemistry_botanical | HTTP 404 | Unknown | Free | Permitted with attribution |
| 17 | `src_gbif` | Global Biodiversity Information Facility (GBIF) | B_chemistry_botanical | HTTP 200 | JSON | Free | Permitted with attribution |
| 18 | `src_wfo` | World Flora Online (WFO) | B_chemistry_botanical | Offline | Unknown | Free | Non-commercial default; partner term... |
| 19 | `src_powo` | Plants of the World Online (Kew Gardens) | B_chemistry_botanical | HTTP 403 | Protected Endpoint | Free | Permitted with attribution |
| 20 | `src_wikidata` | Wikidata | B_chemistry_botanical | HTTP 200 | JSON | Free | Permitted without restriction (CC0) |
| 21 | `src_ayushportal` | AYUSH Research Portal | C_traditional_medicine_safety | HTTP 200 | HTML | Free | Public Health Research (Attribution ... |
| 22 | `src_ayush_ministry` | Ministry of Ayush | C_traditional_medicine_safety | HTTP 200 | HTML | Free | Permitted with attribution |
| 23 | `src_ccras` | Central Council for Research in Ayurvedic Sciences (CCRAS) | C_traditional_medicine_safety | HTTP 200 | HTML | Free | Permitted with attribution for scien... |
| 24 | `src_nmpb` | National Medicinal Plants Board (NMPB) | C_traditional_medicine_safety | HTTP 200 | HTML | Free | Government open use with attribution |
| 25 | `src_nih_ods` | NIH Office of Dietary Supplements (ODS) | C_traditional_medicine_safety | HTTP 403 | Protected Endpoint | Free | Permitted (Public Domain) |
| 26 | `src_nccih` | National Center for Complementary and Integrative Health (NCCIH) | C_traditional_medicine_safety | HTTP 200 | HTML | Free | Permitted (Public Domain) |
| 27 | `src_livertox` | LiverTox (NCBI Bookshelf) | C_traditional_medicine_safety | HTTP 200 | JSON | Free | Permitted (Public Domain) |
| 28 | `src_dailymed` | DailyMed (NLM / FDA) | C_traditional_medicine_safety | HTTP 200 | JSON | Free | Permitted (Public Domain) |
| 29 | `src_rxnorm` | RxNorm (NLM) | C_traditional_medicine_safety | HTTP 200 | JSON | Free | Permitted with UMLS license agreemen... |
| 30 | `src_medlineplus` | MedlinePlus (NLM) | C_traditional_medicine_safety | HTTP 200 | XML | Free | Permitted (Public Domain) |
| 31 | `src_who` | World Health Organization (WHO) | C_traditional_medicine_safety | HTTP 200 | HTML | Free | Attribution required; commercial lic... |
| 32 | `src_openstax` | OpenStax Anatomy and Physiology | D_anatomy_physiology_exercise | HTTP 200 | HTML | Free | Permitted with attribution |
| 33 | `src_compendium_pa` | Compendium of Physical Activities | D_anatomy_physiology_exercise | HTTP 200 | HTML | Free | Fair use with citation; non-commerci... |
| 34 | `src_addbiomechanics` | AddBiomechanics | D_anatomy_physiology_exercise | HTTP 200 | HTML | Free | Permitted with attribution |
| 35 | `src_sports2d` | Sports2D | D_anatomy_physiology_exercise | HTTP 200 | Binary/Text | Free | Permitted under BSD license |
| 36 | `src_zanatomy` | Z-Anatomy | D_anatomy_physiology_exercise | HTTP 200 | HTML | Free | Permitted with attribution and share... |
| 37 | `src_physionet` | PhysioNet (MIT / PhysioToolkit) | D_anatomy_physiology_exercise | HTTP 404 | Unknown | Free | Open tier permitted with attribution... |
| 38 | `src_osf` | Open Science Framework (OSF) | E_datasets_genetics | HTTP 200 | Binary/Text | Free | Permitted for open licenses |
| 39 | `src_zenodo` | Zenodo (CERN) | E_datasets_genetics | HTTP 200 | JSON | Free | Permitted for CC BY / CC0 records |
| 40 | `src_gwas_catalog` | GWAS Catalog (NHGRI-EBI) | E_datasets_genetics | HTTP 410 | Unknown | Free | Permitted with attribution |
| 41 | `src_clinvar` | ClinVar (NCBI) | E_datasets_genetics | HTTP 200 | JSON | Free | Permitted (Public Domain) |
| 42 | `src_ensembl` | Ensembl (EMBL-EBI) | E_datasets_genetics | Offline | Unknown | Free | Permitted with attribution |
| 43 | `src_clingen` | ClinGen (Clinical Genome Resource) | E_datasets_genetics | HTTP 200 | HTML | Free | Permitted with attribution |
| 44 | `src_pharmgkb` | PharmGKB (Pharmacogenomics Knowledgebase) | E_datasets_genetics | Offline | Unknown | Free | Permitted with attribution and share... |
| 45 | `src_ogd_india` | Open Government Data Platform India (data.gov.in) | F_indian_data_food_safety | HTTP 403 | Protected Endpoint | Free | Permitted with attribution |
| 46 | `src_agmarknet` | Agmarknet (Agricultural Marketing Information Network) | F_indian_data_food_safety | HTTP 200 | HTML | Free | Permitted with attribution |
| 47 | `src_enam` | eNAM (National Agriculture Market) | F_indian_data_food_safety | HTTP 200 | HTML | Free | Permitted with attribution |
| 48 | `src_fssai` | Food Safety and Standards Authority of India (FSSAI) | F_indian_data_food_safety | HTTP 200 | HTML | Free | Statutory legal standards; open refe... |
| 49 | `src_codex` | Codex Alimentarius (FAO / WHO) | F_indian_data_food_safety | HTTP 200 | HTML | Free | Permitted with attribution |
| 50 | `src_openaq` | OpenAQ Global Air Quality Platform | G_environment_geographical | HTTP 401 | Protected Endpoint | Free | Permitted with attribution |
| 51 | `src_nasa_earthdata` | NASA Earthdata (CMR API) | G_environment_geographical | HTTP 200 | JSON | Free | Permitted (Public Domain) |
| 52 | `src_osm` | OpenStreetMap / Nominatim | G_environment_geographical | HTTP 200 | JSON | Free | Permitted with attribution and share... |
| 53 | `src_overpass` | Overpass API (OpenStreetMap) | G_environment_geographical | Offline | Unknown | Free | Permitted with attribution |
| 54 | `src_open_meteo` | Open-Meteo | G_environment_geographical | HTTP 200 | JSON | Free | Permitted with attribution under 10k... |
| 55 | `src_iucn_redlist` | IUCN Red List of Threatened Species | G_environment_geographical | HTTP 404 | Unknown | Key Required | Commercial use requires prior writte... |

## 2. Detailed Technical Breakdown by Category


### Category: A_research_literature

#### PubMed (NLM / NCBI) (`src_pubmed`)
- **Home URL:** [https://pubmed.ncbi.nlm.nih.gov/](https://pubmed.ncbi.nlm.nih.gov/)
- **API Reference:** https://www.ncbi.nlm.nih.gov/books/NBK25501/
- **Live Probe:** `https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=238139&retmode=json`
- **Observed Status:** HTTP 200 (8059 ms, format: `JSON`)
- **License:** US Public Domain / NLM Database (Attribution requested)
- **Commercial Permission:** Permitted (Public Domain)
- **Authentication / Rate Limits:** API key increases rate limit from 3 to 10 req/s
- **Audit Notes:** Verified Live (HTTP 200, 8059ms)

#### NCBI E-utilities (`src_ncbi_eutils`)
- **Home URL:** [https://www.ncbi.nlm.nih.gov/books/NBK25501/](https://www.ncbi.nlm.nih.gov/books/NBK25501/)
- **API Reference:** https://www.ncbi.nlm.nih.gov/books/NBK25499/
- **Live Probe:** `https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=curcumin&retmode=json&retmax=1`
- **Observed Status:** HTTP 200 (1115 ms, format: `JSON`)
- **License:** US Public Domain (NLM / NIH)
- **Commercial Permission:** Permitted (Public Domain)
- **Authentication / Rate Limits:** API key configured: a22068f9ba069fb60327ec9f27ad6e894208
- **Audit Notes:** Verified Live (HTTP 200, 1115ms)

#### Europe PMC (`src_europe_pmc`)
- **Home URL:** [https://europepmc.org/](https://europepmc.org/)
- **API Reference:** https://europepmc.org/RestfulWebService
- **Live Probe:** `https://www.ebi.ac.uk/europepmc/webservices/rest/search?query=Withania+somnifera&resultType=core&format=json&pageSize=1`
- **Observed Status:** HTTP 200 (963 ms, format: `JSON`)
- **License:** CC0 / CC BY / Variable by article publisher
- **Commercial Permission:** Permitted for CC BY / CC0 articles; metadata CC0
- **Authentication / Rate Limits:** No API key required; rate limit 10 req/s
- **Audit Notes:** Verified Live (HTTP 200, 963ms)

#### PMC Open Access / BioC API (`src_pmc_oa`)
- **Home URL:** [https://www.ncbi.nlm.nih.gov/pmc/tools/openftlist/](https://www.ncbi.nlm.nih.gov/pmc/tools/openftlist/)
- **API Reference:** https://www.ncbi.nlm.nih.gov/research/bionlp/APIs/BioC-PMC/
- **Live Probe:** `https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_json/PMC3573577/unicode`
- **Observed Status:** HTTP 200 (1183 ms, format: `JSON`)
- **License:** Open Access Subset (CC BY / CC0 / Public Domain)
- **Commercial Permission:** Permitted according to individual article license
- **Authentication / Rate Limits:** Rate limit 3 req/s without key
- **Audit Notes:** Verified Live (HTTP 200, 1183ms)

#### ClinicalTrials.gov (API v2) (`src_clinical_trials`)
- **Home URL:** [https://clinicaltrials.gov/](https://clinicaltrials.gov/)
- **API Reference:** https://clinicaltrials.gov/data-api/api
- **Live Probe:** `https://clinicaltrials.gov/api/v2/studies?query.term=curcumin&pageSize=1`
- **Observed Status:** HTTP 200 (619 ms, format: `JSON`)
- **License:** US Public Domain (NLM / NIH)
- **Commercial Permission:** Permitted (Public Domain)
- **Authentication / Rate Limits:** Free public API; max 50 req/min recommended
- **Audit Notes:** Verified Live (HTTP 200, 619ms)

#### OpenAlex (`src_openalex`)
- **Home URL:** [https://openalex.org/](https://openalex.org/)
- **API Reference:** https://docs.openalex.org/
- **Live Probe:** `https://api.openalex.org/works?search=Ashwagandha&per_page=1&mailto=contact@nutrientearth.com`
- **Observed Status:** HTTP 200 (1465 ms, format: `JSON`)
- **License:** CC0 1.0 Universal (Public Domain Dedication)
- **Commercial Permission:** Permitted without restriction (CC0)
- **Authentication / Rate Limits:** Polite pool enabled via mailto header (10 req/s)
- **Audit Notes:** Verified Live (HTTP 200, 1465ms)

#### Crossref (`src_crossref`)
- **Home URL:** [https://www.crossref.org/](https://www.crossref.org/)
- **API Reference:** https://api.crossref.org/
- **Live Probe:** `https://api.crossref.org/works?query=Withania+somnifera&rows=1&mailto=contact@nutrientearth.com`
- **Observed Status:** HTTP 200 (1171 ms, format: `JSON`)
- **License:** CC0 (Metadata free of copyright)
- **Commercial Permission:** Permitted (CC0 for metadata)
- **Authentication / Rate Limits:** Polite pool active with mailto=contact@nutrientearth.com
- **Audit Notes:** Verified Live (HTTP 200, 1171ms)

#### Semantic Scholar (Graph API v1) (`src_semantic_scholar`)
- **Home URL:** [https://www.semanticscholar.org/](https://www.semanticscholar.org/)
- **API Reference:** https://api.semanticscholar.org/api-docs/
- **Live Probe:** `https://api.semanticscholar.org/graph/v1/paper/search?query=curcumin+inflammation&limit=1&fields=title,year,abstract`
- **Observed Status:** HTTP 429 (943 ms, format: `Unknown`)
- **License:** ODC-BY / Non-commercial without API key
- **Commercial Permission:** Partner/Licensed access required for commercial redistribution
- **Authentication / Rate Limits:** Public unauthenticated rate limit: 1 req/sec
- **Audit Notes:** HTTP 429

#### USDA FoodData Central (FDC) (`src_usda_fdc`)
- **Home URL:** [https://fdc.nal.usda.gov/](https://fdc.nal.usda.gov/)
- **API Reference:** https://fdc.nal.usda.gov/api-guide.html
- **Live Probe:** `https://api.nal.usda.gov/fdc/v1/foods/search?query=spinach&pageSize=1&api_key=dhK8Ngpm9mMtrjHNFjRpcKHCCLDzdMrTwhQrNDkF`
- **Observed Status:** HTTP 200 (1630 ms, format: `JSON`)
- **License:** US Public Domain (USDA / Federal Government)
- **Commercial Permission:** Permitted (Public Domain)
- **Authentication / Rate Limits:** API key configured: dhK8Ngpm9mMtrjHNFjRpcKHCCLDzdMrTwhQrNDkF
- **Audit Notes:** Verified Live (HTTP 200, 1630ms)

#### FAO/INFOODS Food Composition Databases (`src_fao_infoods`)
- **Home URL:** [https://www.fao.org/infoods/infoods/tables-and-databases/en/](https://www.fao.org/infoods/infoods/tables-and-databases/en/)
- **API Reference:** https://www.fao.org/infoods/infoods/standards-guidelines/en/
- **Live Probe:** `https://www.fao.org/infoods/infoods/tables-and-databases/faoinfoods-databases/en/`
- **Observed Status:** HTTP 200 (419 ms, format: `HTML`)
- **License:** FAO Open Access / CC BY-NC-SA 3.0 IGO (Attribution required)
- **Commercial Permission:** Attribution required; commercial licensing upon notice to FAO
- **Authentication / Rate Limits:** Direct download & local verified repository (8 official PDFs stored)
- **Audit Notes:** Verified Live (HTTP 200, 419ms)

#### Open Food Facts (`src_open_food_facts`)
- **Home URL:** [https://world.openfoodfacts.org/](https://world.openfoodfacts.org/)
- **API Reference:** https://wiki.openfoodfacts.org/API
- **Live Probe:** `https://world.openfoodfacts.org/cgi/search.pl?search_terms=oats&search_simple=1&action=process&json=1&page_size=1`
- **Observed Status:** HTTP 503 (973 ms, format: `Unknown`)
- **License:** Open Database License (ODbL 1.0) / Artwork CC BY-SA 3.0
- **Commercial Permission:** Permitted with ODbL Share-Alike & Attribution
- **Authentication / Rate Limits:** User-Agent header required
- **Audit Notes:** HTTP 503

#### LOTUS Initiative (Natural Products) (`src_lotus`)
- **Home URL:** [https://lotus.naturalproducts.net/](https://lotus.naturalproducts.net/)
- **API Reference:** https://lotus.naturalproducts.net/download
- **Live Probe:** `https://query.wikidata.org/sparql?query=SELECT%20*%20WHERE%20%7B%20%3Ftaxon%20wdt%3AP235%20%3Fcompound%20%7D%20LIMIT%201&format=json`
- **Observed Status:** HTTP 200 (753 ms, format: `JSON`)
- **License:** CC0 1.0 Universal
- **Commercial Permission:** Permitted without restriction (CC0)
- **Authentication / Rate Limits:** Accessible via Wikidata SPARQL endpoint & LOTUS dumps
- **Audit Notes:** Verified Live (HTTP 200, 753ms)


### Category: B_chemistry_botanical

#### PubChem (NCBI) (`src_pubchem`)
- **Home URL:** [https://pubchem.ncbi.nlm.nih.gov/](https://pubchem.ncbi.nlm.nih.gov/)
- **API Reference:** https://pubchem.ncbi.nlm.nih.gov/docs/pug-rest
- **Live Probe:** `https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/curcumin/property/Title,MolecularFormula,MolecularWeight,InChIKey/JSON`
- **Observed Status:** HTTP 200 (2736 ms, format: `JSON`)
- **License:** US Public Domain (NIH / NLM)
- **Commercial Permission:** Permitted (Public Domain)
- **Authentication / Rate Limits:** Rate limit: 5 req/s max, max 400 requests/min
- **Audit Notes:** Verified Live (HTTP 200, 2736ms)

#### ChEBI (EMBL-EBI / OLS4) (`src_chebi`)
- **Home URL:** [https://www.ebi.ac.uk/chebi/](https://www.ebi.ac.uk/chebi/)
- **API Reference:** https://www.ebi.ac.uk/ols4/help
- **Live Probe:** `https://www.ebi.ac.uk/ols4/api/search?q=withaferin+a&ontology=chebi&rows=1`
- **Observed Status:** HTTP 200 (3518 ms, format: `JSON`)
- **License:** CC BY 4.0 (Creative Commons Attribution)
- **Commercial Permission:** Permitted with attribution
- **Authentication / Rate Limits:** Public REST service
- **Audit Notes:** Verified Live (HTTP 200, 3518ms)

#### ChEMBL (EMBL-EBI) (`src_chembl`)
- **Home URL:** [https://www.ebi.ac.uk/chembl/](https://www.ebi.ac.uk/chembl/)
- **API Reference:** https://chembl.gitbook.io/chembl-interface-documentation/web-services
- **Live Probe:** `https://www.ebi.ac.uk/chembl/api/data/molecule/search.json?q=aspirin&limit=1`
- **Observed Status:** HTTP 500 (5882 ms, format: `Unknown`)
- **License:** CC BY-SA 3.0
- **Commercial Permission:** Permitted with attribution and share-alike
- **Authentication / Rate Limits:** Public REST API
- **Audit Notes:** HTTP 500

#### BindingDB (`src_bindingdb`)
- **Home URL:** [https://www.bindingdb.org/](https://www.bindingdb.org/)
- **API Reference:** https://www.bindingdb.org/bind/chemsearch/marvin/help.jsp
- **Live Probe:** `https://www.bindingdb.org/bind/index.jsp`
- **Observed Status:** HTTP 404 (1167 ms, format: `Unknown`)
- **License:** CC BY 3.0 US
- **Commercial Permission:** Permitted with attribution
- **Authentication / Rate Limits:** REST and downloadable TSV sets
- **Audit Notes:** HTTP 404

#### Global Biodiversity Information Facility (GBIF) (`src_gbif`)
- **Home URL:** [https://www.gbif.org/](https://www.gbif.org/)
- **API Reference:** https://techdocs.gbif.org/en/openapi/v1/species
- **Live Probe:** `https://api.gbif.org/v1/species/match?name=Withania+somnifera&verbose=false`
- **Observed Status:** HTTP 200 (1003 ms, format: `JSON`)
- **License:** CC0 1.0 / CC BY 4.0
- **Commercial Permission:** Permitted with attribution
- **Authentication / Rate Limits:** Public API
- **Audit Notes:** Verified Live (HTTP 200, 1003ms)

#### World Flora Online (WFO) (`src_wfo`)
- **Home URL:** [https://www.worldfloraonline.org/](https://www.worldfloraonline.org/)
- **API Reference:** https://list.worldfloraonline.org/
- **Live Probe:** `https://list.worldfloraonline.org/reconcile`
- **Observed Status:** HTTP None (None ms, format: `Unknown`)
- **License:** CC BY-NC 4.0 / WFO Open Data
- **Commercial Permission:** Non-commercial default; partner terms apply for commercial
- **Authentication / Rate Limits:** W3C OpenRefine Reconciliation API Standard
- **Audit Notes:** SSL Handshake Failed: HTTPSConnectionPool(host='list.worldfloraonline.org', port=443): Max retries exc

#### Plants of the World Online (Kew Gardens) (`src_powo`)
- **Home URL:** [https://powo.science.kew.org/](https://powo.science.kew.org/)
- **API Reference:** https://powo.science.kew.org/
- **Live Probe:** `https://powo.science.kew.org/api/2/search?q=Ocimum+tenuiflorum&perPage=1`
- **Observed Status:** HTTP 403 (326 ms, format: `Protected Endpoint`)
- **License:** CC BY 4.0 (Royal Botanic Gardens, Kew)
- **Commercial Permission:** Permitted with attribution
- **Authentication / Rate Limits:** Public Kew API
- **Audit Notes:** Endpoint online, requires token/browser authorization (HTTP 403)

#### Wikidata (`src_wikidata`)
- **Home URL:** [https://www.wikidata.org/](https://www.wikidata.org/)
- **API Reference:** https://www.wikidata.org/wiki/Wikidata:Data_access
- **Live Probe:** `https://www.wikidata.org/w/api.php?action=wbsearchentities&search=Ashwagandha&language=en&format=json&limit=1`
- **Observed Status:** HTTP 200 (636 ms, format: `JSON`)
- **License:** CC0 1.0 Universal
- **Commercial Permission:** Permitted without restriction (CC0)
- **Authentication / Rate Limits:** Mandatory User-Agent header
- **Audit Notes:** Verified Live (HTTP 200, 636ms)


### Category: C_traditional_medicine_safety

#### AYUSH Research Portal (`src_ayushportal`)
- **Home URL:** [https://ayushportal.nic.in/](https://ayushportal.nic.in/)
- **API Reference:** https://ayushportal.nic.in/srch1.aspx
- **Live Probe:** `https://ayushportal.nic.in/srch1.aspx`
- **Observed Status:** HTTP 200 (444 ms, format: `HTML`)
- **License:** Ministry of Ayush / Government of India
- **Commercial Permission:** Public Health Research (Attribution required)
- **Authentication / Rate Limits:** ASP.NET session state management required
- **Audit Notes:** Verified Live (HTTP 200, 444ms)

#### Ministry of Ayush (`src_ayush_ministry`)
- **Home URL:** [https://ayush.gov.in/](https://ayush.gov.in/)
- **API Reference:** https://ayush.gov.in/documents
- **Live Probe:** `https://ayush.gov.in/`
- **Observed Status:** HTTP 200 (449 ms, format: `HTML`)
- **License:** Government Open Data (Attribution required)
- **Commercial Permission:** Permitted with attribution
- **Authentication / Rate Limits:** Public government portal
- **Audit Notes:** Verified Live (HTTP 200, 449ms)

#### Central Council for Research in Ayurvedic Sciences (CCRAS) (`src_ccras`)
- **Home URL:** [https://ccras.nic.in/](https://ccras.nic.in/)
- **API Reference:** https://ccras.nic.in/content/publications
- **Live Probe:** `https://ccras.nic.in/`
- **Observed Status:** HTTP 200 (969 ms, format: `HTML`)
- **License:** Government Open Data / Copyright CCRAS
- **Commercial Permission:** Permitted with attribution for scientific reference
- **Authentication / Rate Limits:** 12 official monographs acquired in repository
- **Audit Notes:** Verified Live (HTTP 200, 969ms)

#### National Medicinal Plants Board (NMPB) (`src_nmpb`)
- **Home URL:** [https://nmpb.nic.in/](https://nmpb.nic.in/)
- **API Reference:** https://nmpb.nic.in/medicinal-plants
- **Live Probe:** `https://nmpb.nic.in/`
- **Observed Status:** HTTP 200 (357 ms, format: `HTML`)
- **License:** Government of India / NMPB Data
- **Commercial Permission:** Government open use with attribution
- **Authentication / Rate Limits:** Public web portal
- **Audit Notes:** Verified Live (HTTP 200, 357ms)

#### NIH Office of Dietary Supplements (ODS) (`src_nih_ods`)
- **Home URL:** [https://ods.od.nih.gov/](https://ods.od.nih.gov/)
- **API Reference:** https://ods.od.nih.gov/factsheets/list-all/
- **Live Probe:** `https://ods.od.nih.gov/factsheets/list-all/`
- **Observed Status:** HTTP 403 (901 ms, format: `Protected Endpoint`)
- **License:** US Public Domain (NIH / Federal Works)
- **Commercial Permission:** Permitted (Public Domain)
- **Authentication / Rate Limits:** Cloudflare protected; access via standard web/browser agent
- **Audit Notes:** Endpoint online, requires token/browser authorization (HTTP 403)

#### National Center for Complementary and Integrative Health (NCCIH) (`src_nccih`)
- **Home URL:** [https://www.nccih.nih.gov/](https://www.nccih.nih.gov/)
- **API Reference:** https://www.nccih.nih.gov/health/herbsataglance
- **Live Probe:** `https://www.nccih.nih.gov/health/herbsataglance`
- **Observed Status:** HTTP 200 (2564 ms, format: `HTML`)
- **License:** US Public Domain (NIH / Federal Works)
- **Commercial Permission:** Permitted (Public Domain)
- **Authentication / Rate Limits:** Public website
- **Audit Notes:** Verified Live (HTTP 200, 2564ms)

#### LiverTox (NCBI Bookshelf) (`src_livertox`)
- **Home URL:** [https://www.ncbi.nlm.nih.gov/books/NBK547852/](https://www.ncbi.nlm.nih.gov/books/NBK547852/)
- **API Reference:** https://www.ncbi.nlm.nih.gov/books/NBK547852/
- **Live Probe:** `https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=books&id=547852&retmode=json`
- **Observed Status:** HTTP 200 (526 ms, format: `JSON`)
- **License:** US Public Domain (NLM / NIDDK)
- **Commercial Permission:** Permitted (Public Domain)
- **Authentication / Rate Limits:** Authoritative hepatotoxicity Likelihood Scores (A through E)
- **Audit Notes:** Verified Live (HTTP 200, 526ms)

#### DailyMed (NLM / FDA) (`src_dailymed`)
- **Home URL:** [https://dailymed.nlm.nih.gov/](https://dailymed.nlm.nih.gov/)
- **API Reference:** https://dailymed.nlm.nih.gov/dailymed/app-support-web-services.cfm
- **Live Probe:** `https://dailymed.nlm.nih.gov/dailymed/services/v2/spls.json?drug_name=metformin&pagesize=1`
- **Observed Status:** HTTP 200 (1362 ms, format: `JSON`)
- **License:** US Public Domain (FDA / NLM)
- **Commercial Permission:** Permitted (Public Domain)
- **Authentication / Rate Limits:** Public REST API
- **Audit Notes:** Verified Live (HTTP 200, 1362ms)

#### RxNorm (NLM) (`src_rxnorm`)
- **Home URL:** [https://www.nlm.nih.gov/research/umls/rxnorm/](https://www.nlm.nih.gov/research/umls/rxnorm/)
- **API Reference:** https://lhncbc.nlm.nih.gov/RxNav/APIs/RxNormAPIs.html
- **Live Probe:** `https://rxnav.nlm.nih.gov/REST/rxcui.json?name=metformin`
- **Observed Status:** HTTP 200 (8359 ms, format: `JSON`)
- **License:** US Public Domain (NLM / UMLS Metathesaurus)
- **Commercial Permission:** Permitted with UMLS license agreement
- **Authentication / Rate Limits:** Public REST service
- **Audit Notes:** Verified Live (HTTP 200, 8359ms)

#### MedlinePlus (NLM) (`src_medlineplus`)
- **Home URL:** [https://medlineplus.gov/](https://medlineplus.gov/)
- **API Reference:** https://medlineplus.gov/connect/service.html
- **Live Probe:** `https://wsearch.nlm.nih.gov/ws/query?db=healthTopics&term=hypertension&retmax=1`
- **Observed Status:** HTTP 200 (12622 ms, format: `XML`)
- **License:** US Public Domain (NLM / NIH)
- **Commercial Permission:** Permitted (Public Domain)
- **Authentication / Rate Limits:** XML Web Service
- **Audit Notes:** Verified Live (HTTP 200, 12622ms)

#### World Health Organization (WHO) (`src_who`)
- **Home URL:** [https://www.who.int/](https://www.who.int/)
- **API Reference:** https://www.who.int/publications
- **Live Probe:** `https://www.who.int/publications/i`
- **Observed Status:** HTTP 200 (265 ms, format: `HTML`)
- **License:** WHO Open Access / CC BY-NC-SA 3.0 IGO
- **Commercial Permission:** Attribution required; commercial licensing upon application
- **Authentication / Rate Limits:** Public publications repository
- **Audit Notes:** Verified Live (HTTP 200, 265ms)


### Category: D_anatomy_physiology_exercise

#### OpenStax Anatomy and Physiology (`src_openstax`)
- **Home URL:** [https://openstax.org/details/books/anatomy-and-physiology-2e](https://openstax.org/details/books/anatomy-and-physiology-2e)
- **API Reference:** https://openstax.org/api/v0/
- **Live Probe:** `https://openstax.org/details/books/anatomy-and-physiology-2e`
- **Observed Status:** HTTP 200 (1065 ms, format: `HTML`)
- **License:** CC BY 4.0 (Rice University)
- **Commercial Permission:** Permitted with attribution
- **Authentication / Rate Limits:** Full HTML & PDF openly downloadable
- **Audit Notes:** Verified Live (HTTP 200, 1065ms)

#### Compendium of Physical Activities (`src_compendium_pa`)
- **Home URL:** [https://sites.google.com/site/compendiumofphysicalactivities/](https://sites.google.com/site/compendiumofphysicalactivities/)
- **API Reference:** https://sites.google.com/site/compendiumofphysicalactivities/activity-categories
- **Live Probe:** `https://sites.google.com/site/compendiumofphysicalactivities/`
- **Observed Status:** HTTP 200 (625 ms, format: `HTML`)
- **License:** Academic Research / Fair Use (Ainsworth et al.)
- **Commercial Permission:** Fair use with citation; non-commercial license for database extracts
- **Authentication / Rate Limits:** Standard 5-digit activity codes and MET ratings
- **Audit Notes:** Verified Live (HTTP 200, 625ms)

#### AddBiomechanics (`src_addbiomechanics`)
- **Home URL:** [https://addbiomechanics.org/](https://addbiomechanics.org/)
- **API Reference:** https://addbiomechanics.org/
- **Live Probe:** `https://addbiomechanics.org/`
- **Observed Status:** HTTP 200 (1350 ms, format: `HTML`)
- **License:** CC BY 4.0 / Open Data
- **Commercial Permission:** Permitted with attribution
- **Authentication / Rate Limits:** Stanford University Biomechanics
- **Audit Notes:** Verified Live (HTTP 200, 1350ms)

#### Sports2D (`src_sports2d`)
- **Home URL:** [https://github.com/davidpagnon/Sports2D](https://github.com/davidpagnon/Sports2D)
- **API Reference:** https://github.com/davidpagnon/Sports2D#readme
- **Live Probe:** `https://raw.githubusercontent.com/davidpagnon/Sports2D/main/README.md`
- **Observed Status:** HTTP 200 (544 ms, format: `Binary/Text`)
- **License:** BSD 3-Clause
- **Commercial Permission:** Permitted under BSD license
- **Authentication / Rate Limits:** Open-source Python package
- **Audit Notes:** Verified Live (HTTP 200, 544ms)

#### Z-Anatomy (`src_zanatomy`)
- **Home URL:** [https://www.z-anatomy.com/](https://www.z-anatomy.com/)
- **API Reference:** https://www.z-anatomy.com/
- **Live Probe:** `https://www.z-anatomy.com/`
- **Observed Status:** HTTP 200 (824 ms, format: `HTML`)
- **License:** CC BY-SA 4.0
- **Commercial Permission:** Permitted with attribution and share-alike
- **Authentication / Rate Limits:** Blender 3D models and anatomical mappings
- **Audit Notes:** Verified Live (HTTP 200, 824ms)

#### PhysioNet (MIT / PhysioToolkit) (`src_physionet`)
- **Home URL:** [https://physionet.org/](https://physionet.org/)
- **API Reference:** https://physionet.org/about/api/
- **Live Probe:** `https://physionet.org/api/v1/projects/`
- **Observed Status:** HTTP 404 (1357 ms, format: `Unknown`)
- **License:** ODC-BY 1.0 / PhysioNet Credentialed Data Use Agreement
- **Commercial Permission:** Open tier permitted with attribution; credentialed tier restricted
- **Authentication / Rate Limits:** Open access tier freely downloadable
- **Audit Notes:** HTTP 404


### Category: E_datasets_genetics

#### Open Science Framework (OSF) (`src_osf`)
- **Home URL:** [https://osf.io/](https://osf.io/)
- **API Reference:** https://developer.osf.io/
- **Live Probe:** `https://api.osf.io/v2/nodes/?filter[title]=nutrition`
- **Observed Status:** HTTP 200 (2591 ms, format: `Binary/Text`)
- **License:** Variable per deposit (CC0 / CC BY default)
- **Commercial Permission:** Permitted for open licenses
- **Authentication / Rate Limits:** Public API rate limit: 100 req/min
- **Audit Notes:** Verified Live (HTTP 200, 2591ms)

#### Zenodo (CERN) (`src_zenodo`)
- **Home URL:** [https://zenodo.org/](https://zenodo.org/)
- **API Reference:** https://developers.zenodo.org/
- **Live Probe:** `https://zenodo.org/api/records?q=phytochemistry&size=1`
- **Observed Status:** HTTP 200 (1068 ms, format: `JSON`)
- **License:** Variable per deposit (CC0 / CC BY predominant)
- **Commercial Permission:** Permitted for CC BY / CC0 records
- **Authentication / Rate Limits:** Public API: 60 req/min
- **Audit Notes:** Verified Live (HTTP 200, 1068ms)

#### GWAS Catalog (NHGRI-EBI) (`src_gwas_catalog`)
- **Home URL:** [https://www.ebi.ac.uk/gwas/](https://www.ebi.ac.uk/gwas/)
- **API Reference:** https://www.ebi.ac.uk/gwas/rest/docs/api
- **Live Probe:** `https://www.ebi.ac.uk/gwas/rest/api/studies?size=1`
- **Observed Status:** HTTP 410 (1290 ms, format: `Unknown`)
- **License:** EMBL-EBI Terms of Use / Open Access
- **Commercial Permission:** Permitted with attribution
- **Authentication / Rate Limits:** Bulk TSV file acquired: 40.66 MB (15fecc3dc010...)
- **Audit Notes:** HTTP 410

#### ClinVar (NCBI) (`src_clinvar`)
- **Home URL:** [https://www.ncbi.nlm.nih.gov/clinvar/](https://www.ncbi.nlm.nih.gov/clinvar/)
- **API Reference:** https://www.ncbi.nlm.nih.gov/clinvar/docs/maintenance_use/
- **Live Probe:** `https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=clinvar&id=12345&retmode=json`
- **Observed Status:** HTTP 200 (1066 ms, format: `JSON`)
- **License:** US Public Domain (NLM / NIH)
- **Commercial Permission:** Permitted (Public Domain)
- **Authentication / Rate Limits:** Public E-utilities gateway
- **Audit Notes:** Verified Live (HTTP 200, 1066ms)

#### Ensembl (EMBL-EBI) (`src_ensembl`)
- **Home URL:** [https://www.ensembl.org/](https://www.ensembl.org/)
- **API Reference:** https://rest.ensembl.org/
- **Live Probe:** `https://rest.ensembl.org/lookup/symbol/homo_sapiens/MTHFR?content-type=application/json`
- **Observed Status:** HTTP None (None ms, format: `Unknown`)
- **License:** EMBL-EBI Terms / Open Access
- **Commercial Permission:** Permitted with attribution
- **Authentication / Rate Limits:** Rate limit: 15 req/s
- **Audit Notes:** Connection Timeout (>12s)

#### ClinGen (Clinical Genome Resource) (`src_clingen`)
- **Home URL:** [https://clinicalgenome.org/](https://clinicalgenome.org/)
- **API Reference:** https://clinicalgenome.org/data-sharing/
- **Live Probe:** `https://search.clinicalgenome.org/kb/genes`
- **Observed Status:** HTTP 200 (1413 ms, format: `HTML`)
- **License:** CC BY 4.0 / Public Domain Dedication
- **Commercial Permission:** Permitted with attribution
- **Authentication / Rate Limits:** Public curation database
- **Audit Notes:** Verified Live (HTTP 200, 1413ms)

#### PharmGKB (Pharmacogenomics Knowledgebase) (`src_pharmgkb`)
- **Home URL:** [https://www.pharmgkb.org/](https://www.pharmgkb.org/)
- **API Reference:** https://api.pharmgkb.org/v1/
- **Live Probe:** `https://api.pharmgkb.org/v1/data/chemical/PA448873`
- **Observed Status:** HTTP None (None ms, format: `Unknown`)
- **License:** CC BY-SA 4.0
- **Commercial Permission:** Permitted with attribution and share-alike
- **Authentication / Rate Limits:** Public API
- **Audit Notes:** Connection Failed: HTTPSConnectionPool(host='api.pharmgkb.org', port=443): Max retries exceeded wit


### Category: F_indian_data_food_safety

#### Open Government Data Platform India (data.gov.in) (`src_ogd_india`)
- **Home URL:** [https://data.gov.in/](https://data.gov.in/)
- **API Reference:** https://data.gov.in/apis
- **Live Probe:** `https://data.gov.in/`
- **Observed Status:** HTTP 403 (1077 ms, format: `Protected Endpoint`)
- **License:** Government Open Data License - India (GODL)
- **Commercial Permission:** Permitted with attribution
- **Authentication / Rate Limits:** Direct catalog search; API key required for live data feeds
- **Audit Notes:** Endpoint online, requires token/browser authorization (HTTP 403)

#### Agmarknet (Agricultural Marketing Information Network) (`src_agmarknet`)
- **Home URL:** [https://agmarknet.gov.in/](https://agmarknet.gov.in/)
- **API Reference:** https://agmarknet.gov.in/PriceTrends/SA_Pri_Month.aspx
- **Live Probe:** `https://agmarknet.gov.in/`
- **Observed Status:** HTTP 200 (500 ms, format: `HTML`)
- **License:** Government of India Open Access
- **Commercial Permission:** Permitted with attribution
- **Authentication / Rate Limits:** ASP.NET price tables
- **Audit Notes:** Verified Live (HTTP 200, 500ms)

#### eNAM (National Agriculture Market) (`src_enam`)
- **Home URL:** [https://enam.gov.in/](https://enam.gov.in/)
- **API Reference:** https://enam.gov.in/web/dashboard/trade-data
- **Live Probe:** `https://enam.gov.in/`
- **Observed Status:** HTTP 200 (422 ms, format: `HTML`)
- **License:** Ministry of Agriculture & Farmers Welfare, India
- **Commercial Permission:** Permitted with attribution
- **Authentication / Rate Limits:** Public trade data dashboard
- **Audit Notes:** Verified Live (HTTP 200, 422ms)

#### Food Safety and Standards Authority of India (FSSAI) (`src_fssai`)
- **Home URL:** [https://www.fssai.gov.in/](https://www.fssai.gov.in/)
- **API Reference:** https://www.fssai.gov.in/notifications.php
- **Live Probe:** `https://www.fssai.gov.in/`
- **Observed Status:** HTTP 200 (522 ms, format: `HTML`)
- **License:** Government Open Data / Public Domain Regulations
- **Commercial Permission:** Statutory legal standards; open reference permitted
- **Authentication / Rate Limits:** Gazette notifications, standard food codes, Indian FSS regulations
- **Audit Notes:** Verified Live (HTTP 200, 522ms)

#### Codex Alimentarius (FAO / WHO) (`src_codex`)
- **Home URL:** [https://www.fao.org/fao-who-codexalimentarius/en/](https://www.fao.org/fao-who-codexalimentarius/en/)
- **API Reference:** https://www.fao.org/fao-who-codexalimentarius/codex-texts/guidelines/en/
- **Live Probe:** `https://www.fao.org/fao-who-codexalimentarius/en/`
- **Observed Status:** HTTP 200 (1314 ms, format: `HTML`)
- **License:** FAO / WHO Public Domain Standards
- **Commercial Permission:** Permitted with attribution
- **Authentication / Rate Limits:** Official standards CXS001 and CXG023 stored in repository
- **Audit Notes:** Verified Live (HTTP 200, 1314ms)


### Category: G_environment_geographical

#### OpenAQ Global Air Quality Platform (`src_openaq`)
- **Home URL:** [https://openaq.org/](https://openaq.org/)
- **API Reference:** https://docs.openaq.org/
- **Live Probe:** `https://api.openaq.org/v3/locations?limit=1`
- **Observed Status:** HTTP 401 (520 ms, format: `Protected Endpoint`)
- **License:** CC BY 4.0
- **Commercial Permission:** Permitted with attribution
- **Authentication / Rate Limits:** Open tier free with API key for high volume
- **Audit Notes:** Endpoint online, requires token/browser authorization (HTTP 401)

#### NASA Earthdata (CMR API) (`src_nasa_earthdata`)
- **Home URL:** [https://www.earthdata.nasa.gov/](https://www.earthdata.nasa.gov/)
- **API Reference:** https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html
- **Live Probe:** `https://cmr.earthdata.nasa.gov/search/collections.json?keyword=soil+moisture&page_size=1`
- **Observed Status:** HTTP 200 (984 ms, format: `JSON`)
- **License:** US Public Domain (NASA Open Data Policy)
- **Commercial Permission:** Permitted (Public Domain)
- **Authentication / Rate Limits:** Public CMR search endpoint
- **Audit Notes:** Verified Live (HTTP 200, 984ms)

#### OpenStreetMap / Nominatim (`src_osm`)
- **Home URL:** [https://www.openstreetmap.org/](https://www.openstreetmap.org/)
- **API Reference:** https://nominatim.org/release-docs/latest/api/Search/
- **Live Probe:** `https://nominatim.openstreetmap.org/search?q=Bengaluru&format=json&limit=1`
- **Observed Status:** HTTP 200 (1250 ms, format: `JSON`)
- **License:** Open Database License (ODbL 1.0)
- **Commercial Permission:** Permitted with attribution and share-alike
- **Authentication / Rate Limits:** Max 1 req/s, valid User-Agent mandatory
- **Audit Notes:** Verified Live (HTTP 200, 1250ms)

#### Overpass API (OpenStreetMap) (`src_overpass`)
- **Home URL:** [https://overpass-turbo.eu/](https://overpass-turbo.eu/)
- **API Reference:** https://wiki.openstreetmap.org/wiki/Overpass_API
- **Live Probe:** `https://overpass-api.de/api/interpreter?data=[out:json];node(51.5,-0.1,51.51,-0.09)[amenity=pharmacy];out%201;`
- **Observed Status:** HTTP None (None ms, format: `Unknown`)
- **License:** Open Database License (ODbL 1.0)
- **Commercial Permission:** Permitted with attribution
- **Authentication / Rate Limits:** Fair use rate limit (queries under 10s execution)
- **Audit Notes:** Connection Timeout (>12s)

#### Open-Meteo (`src_open_meteo`)
- **Home URL:** [https://open-meteo.com/](https://open-meteo.com/)
- **API Reference:** https://open-meteo.com/en/docs
- **Live Probe:** `https://archive-api.open-meteo.com/v1/archive?latitude=28.6139&longitude=77.2090&start_date=2023-01-01&end_date=2023-01-02&daily=temperature_2m_mean&timezone=auto`
- **Observed Status:** HTTP 200 (920 ms, format: `JSON`)
- **License:** CC BY 4.0 (Open Data)
- **Commercial Permission:** Permitted with attribution under 10k daily calls
- **Authentication / Rate Limits:** No API key required for non-commercial and standard queries
- **Audit Notes:** Verified Live (HTTP 200, 920ms)

#### IUCN Red List of Threatened Species (`src_iucn_redlist`)
- **Home URL:** [https://www.iucnredlist.org/](https://www.iucnredlist.org/)
- **API Reference:** https://apiv3.iucnredlist.org/api/v3/docs
- **Live Probe:** `https://apiv3.iucnredlist.org/api/v3/docs`
- **Observed Status:** HTTP 404 (848 ms, format: `Unknown`)
- **License:** IUCN Red List Terms of Use (Attribution required)
- **Commercial Permission:** Commercial use requires prior written agreement with IUCN
- **Authentication / Rate Limits:** Free research token available via online registration
- **Audit Notes:** HTTP 404

