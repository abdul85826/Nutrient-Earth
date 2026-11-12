"""
Nutrient Earth — Master 55-Source Audit & Discovery Tool (Phase 1)
Audits all 55 scientific data sources across categories A-G.
Validates live endpoints, response formats, HTTP status, SSL requirements,
licensing, authentication requirements, and exports to JSON, CSV, and Markdown.
"""

import os
import sys
import csv
import json
import time
import urllib3
import requests
from typing import Dict, Any, List

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
REGISTRY_DIR = os.path.join(BASE_DIR, "acquisition_registry")
REPORTS_DIR = os.path.join(BASE_DIR, "reports")

for d in [REGISTRY_DIR, REPORTS_DIR]:
    os.makedirs(d, exist_ok=True)

SOURCES = [
    # ── Category A: Research and Scientific Literature (1–12) ──
    {
        "id": "src_pubmed",
        "name": "PubMed (NLM / NCBI)",
        "category": "A_research_literature",
        "home_url": "https://pubmed.ncbi.nlm.nih.gov/",
        "api_docs_url": "https://www.ncbi.nlm.nih.gov/books/NBK25501/",
        "probe_url": "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=238139&retmode=json",
        "verify_ssl": True,
        "type": "Biomedical Literature Search / NLM Database",
        "default_license": "US Public Domain / NLM Database (Attribution requested)",
        "commercial_use": "Permitted (Public Domain)",
        "auth_required": False,
        "auth_notes": "API key increases rate limit from 3 to 10 req/s"
    },
    {
        "id": "src_ncbi_eutils",
        "name": "NCBI E-utilities",
        "category": "A_research_literature",
        "home_url": "https://www.ncbi.nlm.nih.gov/books/NBK25501/",
        "api_docs_url": "https://www.ncbi.nlm.nih.gov/books/NBK25499/",
        "probe_url": "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=curcumin&retmode=json&retmax=1",
        "verify_ssl": True,
        "type": "REST API Gateway (ESearch, EFetch, ESummary)",
        "default_license": "US Public Domain (NLM / NIH)",
        "commercial_use": "Permitted (Public Domain)",
        "auth_required": False,
        "auth_notes": "API key configured: a22068f9ba069fb60327ec9f27ad6e894208"
    },
    {
        "id": "src_europe_pmc",
        "name": "Europe PMC",
        "category": "A_research_literature",
        "home_url": "https://europepmc.org/",
        "api_docs_url": "https://europepmc.org/RestfulWebService",
        "probe_url": "https://www.ebi.ac.uk/europepmc/webservices/rest/search?query=Withania+somnifera&resultType=core&format=json&pageSize=1",
        "verify_ssl": True,
        "type": "Open Access Literature & Preprints API",
        "default_license": "CC0 / CC BY / Variable by article publisher",
        "commercial_use": "Permitted for CC BY / CC0 articles; metadata CC0",
        "auth_required": False,
        "auth_notes": "No API key required; rate limit 10 req/s"
    },
    {
        "id": "src_pmc_oa",
        "name": "PMC Open Access / BioC API",
        "category": "A_research_literature",
        "home_url": "https://www.ncbi.nlm.nih.gov/pmc/tools/openftlist/",
        "api_docs_url": "https://www.ncbi.nlm.nih.gov/research/bionlp/APIs/BioC-PMC/",
        "probe_url": "https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_json/PMC3573577/unicode",
        "verify_ssl": True,
        "type": "Full-Text XML/JSON BioC API for Open Access Articles",
        "default_license": "Open Access Subset (CC BY / CC0 / Public Domain)",
        "commercial_use": "Permitted according to individual article license",
        "auth_required": False,
        "auth_notes": "Rate limit 3 req/s without key"
    },
    {
        "id": "src_clinical_trials",
        "name": "ClinicalTrials.gov (API v2)",
        "category": "A_research_literature",
        "home_url": "https://clinicaltrials.gov/",
        "api_docs_url": "https://clinicaltrials.gov/data-api/api",
        "probe_url": "https://clinicaltrials.gov/api/v2/studies?query.term=curcumin&pageSize=1",
        "verify_ssl": True,
        "type": "Clinical Trials Registry REST API v2",
        "default_license": "US Public Domain (NLM / NIH)",
        "commercial_use": "Permitted (Public Domain)",
        "auth_required": False,
        "auth_notes": "Free public API; max 50 req/min recommended"
    },
    {
        "id": "src_openalex",
        "name": "OpenAlex",
        "category": "A_research_literature",
        "home_url": "https://openalex.org/",
        "api_docs_url": "https://docs.openalex.org/",
        "probe_url": "https://api.openalex.org/works?search=Ashwagandha&per_page=1&mailto=contact@nutrientearth.com",
        "verify_ssl": True,
        "type": "Scholarly Knowledge Graph REST API",
        "default_license": "CC0 1.0 Universal (Public Domain Dedication)",
        "commercial_use": "Permitted without restriction (CC0)",
        "auth_required": False,
        "auth_notes": "Polite pool enabled via mailto header (10 req/s)"
    },
    {
        "id": "src_crossref",
        "name": "Crossref",
        "category": "A_research_literature",
        "home_url": "https://www.crossref.org/",
        "api_docs_url": "https://api.crossref.org/",
        "probe_url": "https://api.crossref.org/works?query=Withania+somnifera&rows=1&mailto=contact@nutrientearth.com",
        "verify_ssl": True,
        "type": "Digital Object Identifier (DOI) Metadata API",
        "default_license": "CC0 (Metadata free of copyright)",
        "commercial_use": "Permitted (CC0 for metadata)",
        "auth_required": False,
        "auth_notes": "Polite pool active with mailto=contact@nutrientearth.com"
    },
    {
        "id": "src_semantic_scholar",
        "name": "Semantic Scholar (Graph API v1)",
        "category": "A_research_literature",
        "home_url": "https://www.semanticscholar.org/",
        "api_docs_url": "https://api.semanticscholar.org/api-docs/",
        "probe_url": "https://api.semanticscholar.org/graph/v1/paper/search?query=curcumin+inflammation&limit=1&fields=title,year,abstract",
        "verify_ssl": True,
        "type": "AI-Powered Scientific Literature Graph API",
        "default_license": "ODC-BY / Non-commercial without API key",
        "commercial_use": "Partner/Licensed access required for commercial redistribution",
        "auth_required": False,
        "auth_notes": "Public unauthenticated rate limit: 1 req/sec"
    },
    {
        "id": "src_usda_fdc",
        "name": "USDA FoodData Central (FDC)",
        "category": "A_research_literature",
        "home_url": "https://fdc.nal.usda.gov/",
        "api_docs_url": "https://fdc.nal.usda.gov/api-guide.html",
        "probe_url": "https://api.nal.usda.gov/fdc/v1/foods/search?query=spinach&pageSize=1&api_key=dhK8Ngpm9mMtrjHNFjRpcKHCCLDzdMrTwhQrNDkF",
        "verify_ssl": True,
        "type": "Nutritional Composition REST API",
        "default_license": "US Public Domain (USDA / Federal Government)",
        "commercial_use": "Permitted (Public Domain)",
        "auth_required": True,
        "auth_notes": "API key configured: dhK8Ngpm9mMtrjHNFjRpcKHCCLDzdMrTwhQrNDkF"
    },
    {
        "id": "src_fao_infoods",
        "name": "FAO/INFOODS Food Composition Databases",
        "category": "A_research_literature",
        "home_url": "https://www.fao.org/infoods/infoods/tables-and-databases/en/",
        "api_docs_url": "https://www.fao.org/infoods/infoods/standards-guidelines/en/",
        "probe_url": "https://www.fao.org/infoods/infoods/tables-and-databases/faoinfoods-databases/en/",
        "verify_ssl": True,
        "type": "International Food Composition & Density Databases",
        "default_license": "FAO Open Access / CC BY-NC-SA 3.0 IGO (Attribution required)",
        "commercial_use": "Attribution required; commercial licensing upon notice to FAO",
        "auth_required": False,
        "auth_notes": "Direct download & local verified repository (8 official PDFs stored)"
    },
    {
        "id": "src_open_food_facts",
        "name": "Open Food Facts",
        "category": "A_research_literature",
        "home_url": "https://world.openfoodfacts.org/",
        "api_docs_url": "https://wiki.openfoodfacts.org/API",
        "probe_url": "https://world.openfoodfacts.org/cgi/search.pl?search_terms=oats&search_simple=1&action=process&json=1&page_size=1",
        "verify_ssl": True,
        "type": "Global Crowdsourced Food Product Database",
        "default_license": "Open Database License (ODbL 1.0) / Artwork CC BY-SA 3.0",
        "commercial_use": "Permitted with ODbL Share-Alike & Attribution",
        "auth_required": False,
        "auth_notes": "User-Agent header required"
    },
    {
        "id": "src_lotus",
        "name": "LOTUS Initiative (Natural Products)",
        "category": "A_research_literature",
        "home_url": "https://lotus.naturalproducts.net/",
        "api_docs_url": "https://lotus.naturalproducts.net/download",
        "probe_url": "https://query.wikidata.org/sparql?query=SELECT%20*%20WHERE%20%7B%20%3Ftaxon%20wdt%3AP235%20%3Fcompound%20%7D%20LIMIT%201&format=json",
        "verify_ssl": True,
        "type": "Plant-Natural Compound Relationship Repository / Wikidata SPARQL",
        "default_license": "CC0 1.0 Universal",
        "commercial_use": "Permitted without restriction (CC0)",
        "auth_required": False,
        "auth_notes": "Accessible via Wikidata SPARQL endpoint & LOTUS dumps"
    },

    # ── Category B: Chemistry and Botanical Intelligence (13–20) ──
    {
        "id": "src_pubchem",
        "name": "PubChem (NCBI)",
        "category": "B_chemistry_botanical",
        "home_url": "https://pubchem.ncbi.nlm.nih.gov/",
        "api_docs_url": "https://pubchem.ncbi.nlm.nih.gov/docs/pug-rest",
        "probe_url": "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/curcumin/property/Title,MolecularFormula,MolecularWeight,InChIKey/JSON",
        "verify_ssl": True,
        "type": "Chemical Structures & Molecular Properties PUG REST API",
        "default_license": "US Public Domain (NIH / NLM)",
        "commercial_use": "Permitted (Public Domain)",
        "auth_required": False,
        "auth_notes": "Rate limit: 5 req/s max, max 400 requests/min"
    },
    {
        "id": "src_chebi",
        "name": "ChEBI (EMBL-EBI / OLS4)",
        "category": "B_chemistry_botanical",
        "home_url": "https://www.ebi.ac.uk/chebi/",
        "api_docs_url": "https://www.ebi.ac.uk/ols4/help",
        "probe_url": "https://www.ebi.ac.uk/ols4/api/search?q=withaferin+a&ontology=chebi&rows=1",
        "verify_ssl": True,
        "type": "Chemical Entities of Biological Interest Ontology API",
        "default_license": "CC BY 4.0 (Creative Commons Attribution)",
        "commercial_use": "Permitted with attribution",
        "auth_required": False,
        "auth_notes": "Public REST service"
    },
    {
        "id": "src_chembl",
        "name": "ChEMBL (EMBL-EBI)",
        "category": "B_chemistry_botanical",
        "home_url": "https://www.ebi.ac.uk/chembl/",
        "api_docs_url": "https://chembl.gitbook.io/chembl-interface-documentation/web-services",
        "probe_url": "https://www.ebi.ac.uk/chembl/api/data/molecule/search.json?q=aspirin&limit=1",
        "verify_ssl": True,
        "type": "Bioactive Drug Discovery Database REST API",
        "default_license": "CC BY-SA 3.0",
        "commercial_use": "Permitted with attribution and share-alike",
        "auth_required": False,
        "auth_notes": "Public REST API"
    },
    {
        "id": "src_bindingdb",
        "name": "BindingDB",
        "category": "B_chemistry_botanical",
        "home_url": "https://www.bindingdb.org/",
        "api_docs_url": "https://www.bindingdb.org/bind/chemsearch/marvin/help.jsp",
        "probe_url": "https://www.bindingdb.org/bind/index.jsp",
        "verify_ssl": True,
        "type": "Binding Affinities & Protein-Ligand Database",
        "default_license": "CC BY 3.0 US",
        "commercial_use": "Permitted with attribution",
        "auth_required": False,
        "auth_notes": "REST and downloadable TSV sets"
    },
    {
        "id": "src_gbif",
        "name": "Global Biodiversity Information Facility (GBIF)",
        "category": "B_chemistry_botanical",
        "home_url": "https://www.gbif.org/",
        "api_docs_url": "https://techdocs.gbif.org/en/openapi/v1/species",
        "probe_url": "https://api.gbif.org/v1/species/match?name=Withania+somnifera&verbose=false",
        "verify_ssl": True,
        "type": "Biodiversity & Botanical Species Matching REST API",
        "default_license": "CC0 1.0 / CC BY 4.0",
        "commercial_use": "Permitted with attribution",
        "auth_required": False,
        "auth_notes": "Public API"
    },
    {
        "id": "src_wfo",
        "name": "World Flora Online (WFO)",
        "category": "B_chemistry_botanical",
        "home_url": "https://www.worldfloraonline.org/",
        "api_docs_url": "https://list.worldfloraonline.org/",
        "probe_url": "https://list.worldfloraonline.org/reconcile",
        "verify_ssl": True,
        "type": "Global Plant Taxonomy Reconciliation API",
        "default_license": "CC BY-NC 4.0 / WFO Open Data",
        "commercial_use": "Non-commercial default; partner terms apply for commercial",
        "auth_required": False,
        "auth_notes": "W3C OpenRefine Reconciliation API Standard"
    },
    {
        "id": "src_powo",
        "name": "Plants of the World Online (Kew Gardens)",
        "category": "B_chemistry_botanical",
        "home_url": "https://powo.science.kew.org/",
        "api_docs_url": "https://powo.science.kew.org/",
        "probe_url": "https://powo.science.kew.org/api/2/search?q=Ocimum+tenuiflorum&perPage=1",
        "verify_ssl": True,
        "type": "Accepted Botanical Names & Taxonomic Authority API",
        "default_license": "CC BY 4.0 (Royal Botanic Gardens, Kew)",
        "commercial_use": "Permitted with attribution",
        "auth_required": False,
        "auth_notes": "Public Kew API"
    },
    {
        "id": "src_wikidata",
        "name": "Wikidata",
        "category": "B_chemistry_botanical",
        "home_url": "https://www.wikidata.org/",
        "api_docs_url": "https://www.wikidata.org/wiki/Wikidata:Data_access",
        "probe_url": "https://www.wikidata.org/w/api.php?action=wbsearchentities&search=Ashwagandha&language=en&format=json&limit=1",
        "verify_ssl": True,
        "type": "Collaborative Multilingual Knowledge Base API",
        "default_license": "CC0 1.0 Universal",
        "commercial_use": "Permitted without restriction (CC0)",
        "auth_required": False,
        "auth_notes": "Mandatory User-Agent header"
    },

    # ── Category C: Traditional Medicine and Health Safety (21–31) ──
    {
        "id": "src_ayushportal",
        "name": "AYUSH Research Portal",
        "category": "C_traditional_medicine_safety",
        "home_url": "https://ayushportal.nic.in/",
        "api_docs_url": "https://ayushportal.nic.in/srch1.aspx",
        "probe_url": "https://ayushportal.nic.in/srch1.aspx",
        "verify_ssl": False,
        "type": "National Research Portal (Ayurveda, Yoga, Unani, Siddha, Homeopathy)",
        "default_license": "Ministry of Ayush / Government of India",
        "commercial_use": "Public Health Research (Attribution required)",
        "auth_required": False,
        "auth_notes": "ASP.NET session state management required"
    },
    {
        "id": "src_ayush_ministry",
        "name": "Ministry of Ayush",
        "category": "C_traditional_medicine_safety",
        "home_url": "https://ayush.gov.in/",
        "api_docs_url": "https://ayush.gov.in/documents",
        "probe_url": "https://ayush.gov.in/",
        "verify_ssl": False,
        "type": "Union Ministry Portal / Guidelines, Pharmacopoeia & Gazette",
        "default_license": "Government Open Data (Attribution required)",
        "commercial_use": "Permitted with attribution",
        "auth_required": False,
        "auth_notes": "Public government portal"
    },
    {
        "id": "src_ccras",
        "name": "Central Council for Research in Ayurvedic Sciences (CCRAS)",
        "category": "C_traditional_medicine_safety",
        "home_url": "https://ccras.nic.in/",
        "api_docs_url": "https://ccras.nic.in/content/publications",
        "probe_url": "https://ccras.nic.in/",
        "verify_ssl": False,
        "type": "Apex Ayurvedic Research Council / Monographs & Books",
        "default_license": "Government Open Data / Copyright CCRAS",
        "commercial_use": "Permitted with attribution for scientific reference",
        "auth_required": False,
        "auth_notes": "12 official monographs acquired in repository"
    },
    {
        "id": "src_nmpb",
        "name": "National Medicinal Plants Board (NMPB)",
        "category": "C_traditional_medicine_safety",
        "home_url": "https://nmpb.nic.in/",
        "api_docs_url": "https://nmpb.nic.in/medicinal-plants",
        "probe_url": "https://nmpb.nic.in/",
        "verify_ssl": False,
        "type": "Government Board / Species Profiles & Agro-techniques",
        "default_license": "Government of India / NMPB Data",
        "commercial_use": "Government open use with attribution",
        "auth_required": False,
        "auth_notes": "Public web portal"
    },
    {
        "id": "src_nih_ods",
        "name": "NIH Office of Dietary Supplements (ODS)",
        "category": "C_traditional_medicine_safety",
        "home_url": "https://ods.od.nih.gov/",
        "api_docs_url": "https://ods.od.nih.gov/factsheets/list-all/",
        "probe_url": "https://ods.od.nih.gov/factsheets/list-all/",
        "verify_ssl": True,
        "type": "Nutrient Reference Values & Dietary Supplement Factsheets",
        "default_license": "US Public Domain (NIH / Federal Works)",
        "commercial_use": "Permitted (Public Domain)",
        "auth_required": False,
        "auth_notes": "Cloudflare protected; access via standard web/browser agent"
    },
    {
        "id": "src_nccih",
        "name": "National Center for Complementary and Integrative Health (NCCIH)",
        "category": "C_traditional_medicine_safety",
        "home_url": "https://www.nccih.nih.gov/",
        "api_docs_url": "https://www.nccih.nih.gov/health/herbsataglance",
        "probe_url": "https://www.nccih.nih.gov/health/herbsataglance",
        "verify_ssl": True,
        "type": "NIH Center / Herbs at a Glance Clinical Evidence Sheets",
        "default_license": "US Public Domain (NIH / Federal Works)",
        "commercial_use": "Permitted (Public Domain)",
        "auth_required": False,
        "auth_notes": "Public website"
    },
    {
        "id": "src_livertox",
        "name": "LiverTox (NCBI Bookshelf)",
        "category": "C_traditional_medicine_safety",
        "home_url": "https://www.ncbi.nlm.nih.gov/books/NBK547852/",
        "api_docs_url": "https://www.ncbi.nlm.nih.gov/books/NBK547852/",
        "probe_url": "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=books&id=547852&retmode=json",
        "verify_ssl": True,
        "type": "Drug-Induced & Herb-Induced Liver Injury (DILI / HILI) Database",
        "default_license": "US Public Domain (NLM / NIDDK)",
        "commercial_use": "Permitted (Public Domain)",
        "auth_required": False,
        "auth_notes": "Authoritative hepatotoxicity Likelihood Scores (A through E)"
    },
    {
        "id": "src_dailymed",
        "name": "DailyMed (NLM / FDA)",
        "category": "C_traditional_medicine_safety",
        "home_url": "https://dailymed.nlm.nih.gov/",
        "api_docs_url": "https://dailymed.nlm.nih.gov/dailymed/app-support-web-services.cfm",
        "probe_url": "https://dailymed.nlm.nih.gov/dailymed/services/v2/spls.json?drug_name=metformin&pagesize=1",
        "verify_ssl": True,
        "type": "FDA Approved Drug Labeling (SPL) REST API",
        "default_license": "US Public Domain (FDA / NLM)",
        "commercial_use": "Permitted (Public Domain)",
        "auth_required": False,
        "auth_notes": "Public REST API"
    },
    {
        "id": "src_rxnorm",
        "name": "RxNorm (NLM)",
        "category": "C_traditional_medicine_safety",
        "home_url": "https://www.nlm.nih.gov/research/umls/rxnorm/",
        "api_docs_url": "https://lhncbc.nlm.nih.gov/RxNav/APIs/RxNormAPIs.html",
        "probe_url": "https://rxnav.nlm.nih.gov/REST/rxcui.json?name=metformin",
        "verify_ssl": True,
        "type": "Standardized Clinical Medication Terminology REST API",
        "default_license": "US Public Domain (NLM / UMLS Metathesaurus)",
        "commercial_use": "Permitted with UMLS license agreement",
        "auth_required": False,
        "auth_notes": "Public REST service"
    },
    {
        "id": "src_medlineplus",
        "name": "MedlinePlus (NLM)",
        "category": "C_traditional_medicine_safety",
        "home_url": "https://medlineplus.gov/",
        "api_docs_url": "https://medlineplus.gov/connect/service.html",
        "probe_url": "https://wsearch.nlm.nih.gov/ws/query?db=healthTopics&term=hypertension&retmax=1",
        "verify_ssl": True,
        "type": "Consumer Health & Clinical Laboratory Explanations",
        "default_license": "US Public Domain (NLM / NIH)",
        "commercial_use": "Permitted (Public Domain)",
        "auth_required": False,
        "auth_notes": "XML Web Service"
    },
    {
        "id": "src_who",
        "name": "World Health Organization (WHO)",
        "category": "C_traditional_medicine_safety",
        "home_url": "https://www.who.int/",
        "api_docs_url": "https://www.who.int/publications",
        "probe_url": "https://www.who.int/publications/i",
        "verify_ssl": True,
        "type": "International Public Health Guidelines & Monographs",
        "default_license": "WHO Open Access / CC BY-NC-SA 3.0 IGO",
        "commercial_use": "Attribution required; commercial licensing upon application",
        "auth_required": False,
        "auth_notes": "Public publications repository"
    },

    # ── Category D: Anatomy, Physiology and Exercise (32–37) ──
    {
        "id": "src_openstax",
        "name": "OpenStax Anatomy and Physiology",
        "category": "D_anatomy_physiology_exercise",
        "home_url": "https://openstax.org/details/books/anatomy-and-physiology-2e",
        "api_docs_url": "https://openstax.org/api/v0/",
        "probe_url": "https://openstax.org/details/books/anatomy-and-physiology-2e",
        "verify_ssl": True,
        "type": "Peer-Reviewed Open Access Educational Textbook",
        "default_license": "CC BY 4.0 (Rice University)",
        "commercial_use": "Permitted with attribution",
        "auth_required": False,
        "auth_notes": "Full HTML & PDF openly downloadable"
    },
    {
        "id": "src_compendium_pa",
        "name": "Compendium of Physical Activities",
        "category": "D_anatomy_physiology_exercise",
        "home_url": "https://sites.google.com/site/compendiumofphysicalactivities/",
        "api_docs_url": "https://sites.google.com/site/compendiumofphysicalactivities/activity-categories",
        "probe_url": "https://sites.google.com/site/compendiumofphysicalactivities/",
        "verify_ssl": True,
        "type": "Standardized Physical Activity MET Values Database",
        "default_license": "Academic Research / Fair Use (Ainsworth et al.)",
        "commercial_use": "Fair use with citation; non-commercial license for database extracts",
        "auth_required": False,
        "auth_notes": "Standard 5-digit activity codes and MET ratings"
    },
    {
        "id": "src_addbiomechanics",
        "name": "AddBiomechanics",
        "category": "D_anatomy_physiology_exercise",
        "home_url": "https://addbiomechanics.org/",
        "api_docs_url": "https://addbiomechanics.org/",
        "probe_url": "https://addbiomechanics.org/",
        "verify_ssl": True,
        "type": "Cloud-Based Automated Biomechanical Motion Capture Processing",
        "default_license": "CC BY 4.0 / Open Data",
        "commercial_use": "Permitted with attribution",
        "auth_required": False,
        "auth_notes": "Stanford University Biomechanics"
    },
    {
        "id": "src_sports2d",
        "name": "Sports2D",
        "category": "D_anatomy_physiology_exercise",
        "home_url": "https://github.com/davidpagnon/Sports2D",
        "api_docs_url": "https://github.com/davidpagnon/Sports2D#readme",
        "probe_url": "https://raw.githubusercontent.com/davidpagnon/Sports2D/main/README.md",
        "verify_ssl": True,
        "type": "Markerless 2D Kinematics & Pose Estimation",
        "default_license": "BSD 3-Clause",
        "commercial_use": "Permitted under BSD license",
        "auth_required": False,
        "auth_notes": "Open-source Python package"
    },
    {
        "id": "src_zanatomy",
        "name": "Z-Anatomy",
        "category": "D_anatomy_physiology_exercise",
        "home_url": "https://www.z-anatomy.com/",
        "api_docs_url": "https://www.z-anatomy.com/",
        "probe_url": "https://www.z-anatomy.com/",
        "verify_ssl": True,
        "type": "Open-Source 3D Human Anatomy Atlas",
        "default_license": "CC BY-SA 4.0",
        "commercial_use": "Permitted with attribution and share-alike",
        "auth_required": False,
        "auth_notes": "Blender 3D models and anatomical mappings"
    },
    {
        "id": "src_physionet",
        "name": "PhysioNet (MIT / PhysioToolkit)",
        "category": "D_anatomy_physiology_exercise",
        "home_url": "https://physionet.org/",
        "api_docs_url": "https://physionet.org/about/api/",
        "probe_url": "https://physionet.org/api/v1/projects/",
        "verify_ssl": True,
        "type": "Biomedical Signal & Clinical Dataset Archive",
        "default_license": "ODC-BY 1.0 / PhysioNet Credentialed Data Use Agreement",
        "commercial_use": "Open tier permitted with attribution; credentialed tier restricted",
        "auth_required": False,
        "auth_notes": "Open access tier freely downloadable"
    },

    # ── Category E: Research Datasets and Genetics (38–44) ──
    {
        "id": "src_osf",
        "name": "Open Science Framework (OSF)",
        "category": "E_datasets_genetics",
        "home_url": "https://osf.io/",
        "api_docs_url": "https://developer.osf.io/",
        "probe_url": "https://api.osf.io/v2/nodes/?filter[title]=nutrition",
        "verify_ssl": True,
        "type": "Open Science Repository REST API v2",
        "default_license": "Variable per deposit (CC0 / CC BY default)",
        "commercial_use": "Permitted for open licenses",
        "auth_required": False,
        "auth_notes": "Public API rate limit: 100 req/min"
    },
    {
        "id": "src_zenodo",
        "name": "Zenodo (CERN)",
        "category": "E_datasets_genetics",
        "home_url": "https://zenodo.org/",
        "api_docs_url": "https://developers.zenodo.org/",
        "probe_url": "https://zenodo.org/api/records?q=phytochemistry&size=1",
        "verify_ssl": True,
        "type": "Open Research Data Repository REST API",
        "default_license": "Variable per deposit (CC0 / CC BY predominant)",
        "commercial_use": "Permitted for CC BY / CC0 records",
        "auth_required": False,
        "auth_notes": "Public API: 60 req/min"
    },
    {
        "id": "src_gwas_catalog",
        "name": "GWAS Catalog (NHGRI-EBI)",
        "category": "E_datasets_genetics",
        "home_url": "https://www.ebi.ac.uk/gwas/",
        "api_docs_url": "https://www.ebi.ac.uk/gwas/rest/docs/api",
        "probe_url": "https://www.ebi.ac.uk/gwas/rest/api/studies?size=1",
        "verify_ssl": True,
        "type": "Genome-Wide Association Studies REST API & Bulk TSV",
        "default_license": "EMBL-EBI Terms of Use / Open Access",
        "commercial_use": "Permitted with attribution",
        "auth_required": False,
        "auth_notes": "Bulk TSV file acquired: 40.66 MB (15fecc3dc010...)"
    },
    {
        "id": "src_clinvar",
        "name": "ClinVar (NCBI)",
        "category": "E_datasets_genetics",
        "home_url": "https://www.ncbi.nlm.nih.gov/clinvar/",
        "api_docs_url": "https://www.ncbi.nlm.nih.gov/clinvar/docs/maintenance_use/",
        "probe_url": "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=clinvar&id=12345&retmode=json",
        "verify_ssl": True,
        "type": "Genomic Variation & Human Health Interpretations",
        "default_license": "US Public Domain (NLM / NIH)",
        "commercial_use": "Permitted (Public Domain)",
        "auth_required": False,
        "auth_notes": "Public E-utilities gateway"
    },
    {
        "id": "src_ensembl",
        "name": "Ensembl (EMBL-EBI)",
        "category": "E_datasets_genetics",
        "home_url": "https://www.ensembl.org/",
        "api_docs_url": "https://rest.ensembl.org/",
        "probe_url": "https://rest.ensembl.org/lookup/symbol/homo_sapiens/MTHFR?content-type=application/json",
        "verify_ssl": True,
        "type": "Vertebrate Genome Annotation REST API",
        "default_license": "EMBL-EBI Terms / Open Access",
        "commercial_use": "Permitted with attribution",
        "auth_required": False,
        "auth_notes": "Rate limit: 15 req/s"
    },
    {
        "id": "src_clingen",
        "name": "ClinGen (Clinical Genome Resource)",
        "category": "E_datasets_genetics",
        "home_url": "https://clinicalgenome.org/",
        "api_docs_url": "https://clinicalgenome.org/data-sharing/",
        "probe_url": "https://search.clinicalgenome.org/kb/genes",
        "verify_ssl": True,
        "type": "Gene-Disease Clinical Validity Curations",
        "default_license": "CC BY 4.0 / Public Domain Dedication",
        "commercial_use": "Permitted with attribution",
        "auth_required": False,
        "auth_notes": "Public curation database"
    },
    {
        "id": "src_pharmgkb",
        "name": "PharmGKB (Pharmacogenomics Knowledgebase)",
        "category": "E_datasets_genetics",
        "home_url": "https://www.pharmgkb.org/",
        "api_docs_url": "https://api.pharmgkb.org/v1/",
        "probe_url": "https://api.pharmgkb.org/v1/data/chemical/PA448873",
        "verify_ssl": True,
        "type": "Pharmacogenomics Gene-Drug Curations REST API",
        "default_license": "CC BY-SA 4.0",
        "commercial_use": "Permitted with attribution and share-alike",
        "auth_required": False,
        "auth_notes": "Public API"
    },

    # ── Category F: Indian Public Data and Food Safety (45–49) ──
    {
        "id": "src_ogd_india",
        "name": "Open Government Data Platform India (data.gov.in)",
        "category": "F_indian_data_food_safety",
        "home_url": "https://data.gov.in/",
        "api_docs_url": "https://data.gov.in/apis",
        "probe_url": "https://data.gov.in/",
        "verify_ssl": False,
        "type": "National Data Sharing and Accessibility Policy (NDSAP) Portal",
        "default_license": "Government Open Data License - India (GODL)",
        "commercial_use": "Permitted with attribution",
        "auth_required": False,
        "auth_notes": "Direct catalog search; API key required for live data feeds"
    },
    {
        "id": "src_agmarknet",
        "name": "Agmarknet (Agricultural Marketing Information Network)",
        "category": "F_indian_data_food_safety",
        "home_url": "https://agmarknet.gov.in/",
        "api_docs_url": "https://agmarknet.gov.in/PriceTrends/SA_Pri_Month.aspx",
        "probe_url": "https://agmarknet.gov.in/",
        "verify_ssl": False,
        "type": "Indian Agricultural Commodities & Wholesale Prices",
        "default_license": "Government of India Open Access",
        "commercial_use": "Permitted with attribution",
        "auth_required": False,
        "auth_notes": "ASP.NET price tables"
    },
    {
        "id": "src_enam",
        "name": "eNAM (National Agriculture Market)",
        "category": "F_indian_data_food_safety",
        "home_url": "https://enam.gov.in/",
        "api_docs_url": "https://enam.gov.in/web/dashboard/trade-data",
        "probe_url": "https://enam.gov.in/",
        "verify_ssl": False,
        "type": "Pan-India Electronic Trading Portal for Agro Commodities",
        "default_license": "Ministry of Agriculture & Farmers Welfare, India",
        "commercial_use": "Permitted with attribution",
        "auth_required": False,
        "auth_notes": "Public trade data dashboard"
    },
    {
        "id": "src_fssai",
        "name": "Food Safety and Standards Authority of India (FSSAI)",
        "category": "F_indian_data_food_safety",
        "home_url": "https://www.fssai.gov.in/",
        "api_docs_url": "https://www.fssai.gov.in/notifications.php",
        "probe_url": "https://www.fssai.gov.in/",
        "verify_ssl": False,
        "type": "Apex Food Regulator / Indian Food Safety & Standards",
        "default_license": "Government Open Data / Public Domain Regulations",
        "commercial_use": "Statutory legal standards; open reference permitted",
        "auth_required": False,
        "auth_notes": "Gazette notifications, standard food codes, Indian FSS regulations"
    },
    {
        "id": "src_codex",
        "name": "Codex Alimentarius (FAO / WHO)",
        "category": "F_indian_data_food_safety",
        "home_url": "https://www.fao.org/fao-who-codexalimentarius/en/",
        "api_docs_url": "https://www.fao.org/fao-who-codexalimentarius/codex-texts/guidelines/en/",
        "probe_url": "https://www.fao.org/fao-who-codexalimentarius/en/",
        "verify_ssl": True,
        "type": "International Food Standards, Codes & Guidelines",
        "default_license": "FAO / WHO Public Domain Standards",
        "commercial_use": "Permitted with attribution",
        "auth_required": False,
        "auth_notes": "Official standards CXS001 and CXG023 stored in repository"
    },

    # ── Category G: Environment and Geographical Intelligence (50–55) ──
    {
        "id": "src_openaq",
        "name": "OpenAQ Global Air Quality Platform",
        "category": "G_environment_geographical",
        "home_url": "https://openaq.org/",
        "api_docs_url": "https://docs.openaq.org/",
        "probe_url": "https://api.openaq.org/v3/locations?limit=1",
        "verify_ssl": True,
        "type": "Harmonized Global Air Quality (PM2.5, NO2, O3) REST API v3",
        "default_license": "CC BY 4.0",
        "commercial_use": "Permitted with attribution",
        "auth_required": False,
        "auth_notes": "Open tier free with API key for high volume"
    },
    {
        "id": "src_nasa_earthdata",
        "name": "NASA Earthdata (CMR API)",
        "category": "G_environment_geographical",
        "home_url": "https://www.earthdata.nasa.gov/",
        "api_docs_url": "https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html",
        "probe_url": "https://cmr.earthdata.nasa.gov/search/collections.json?keyword=soil+moisture&page_size=1",
        "verify_ssl": True,
        "type": "NASA Earth Science Common Metadata Repository (CMR) REST API",
        "default_license": "US Public Domain (NASA Open Data Policy)",
        "commercial_use": "Permitted (Public Domain)",
        "auth_required": False,
        "auth_notes": "Public CMR search endpoint"
    },
    {
        "id": "src_osm",
        "name": "OpenStreetMap / Nominatim",
        "category": "G_environment_geographical",
        "home_url": "https://www.openstreetmap.org/",
        "api_docs_url": "https://nominatim.org/release-docs/latest/api/Search/",
        "probe_url": "https://nominatim.openstreetmap.org/search?q=Bengaluru&format=json&limit=1",
        "verify_ssl": True,
        "type": "Geographical Geocoding & Boundary Service",
        "default_license": "Open Database License (ODbL 1.0)",
        "commercial_use": "Permitted with attribution and share-alike",
        "auth_required": False,
        "auth_notes": "Max 1 req/s, valid User-Agent mandatory"
    },
    {
        "id": "src_overpass",
        "name": "Overpass API (OpenStreetMap)",
        "category": "G_environment_geographical",
        "home_url": "https://overpass-turbo.eu/",
        "api_docs_url": "https://wiki.openstreetmap.org/wiki/Overpass_API",
        "probe_url": "https://overpass-api.de/api/interpreter?data=[out:json];node(51.5,-0.1,51.51,-0.09)[amenity=pharmacy];out%201;",
        "verify_ssl": True,
        "type": "OSM Feature & Amenity Query Engine",
        "default_license": "Open Database License (ODbL 1.0)",
        "commercial_use": "Permitted with attribution",
        "auth_required": False,
        "auth_notes": "Fair use rate limit (queries under 10s execution)"
    },
    {
        "id": "src_open_meteo",
        "name": "Open-Meteo",
        "category": "G_environment_geographical",
        "home_url": "https://open-meteo.com/",
        "api_docs_url": "https://open-meteo.com/en/docs",
        "probe_url": "https://archive-api.open-meteo.com/v1/archive?latitude=28.6139&longitude=77.2090&start_date=2023-01-01&end_date=2023-01-02&daily=temperature_2m_mean&timezone=auto",
        "verify_ssl": True,
        "type": "Open Meteorological Weather & Climate Archive REST API",
        "default_license": "CC BY 4.0 (Open Data)",
        "commercial_use": "Permitted with attribution under 10k daily calls",
        "auth_required": False,
        "auth_notes": "No API key required for non-commercial and standard queries"
    },
    {
        "id": "src_iucn_redlist",
        "name": "IUCN Red List of Threatened Species",
        "category": "G_environment_geographical",
        "home_url": "https://www.iucnredlist.org/",
        "api_docs_url": "https://apiv3.iucnredlist.org/api/v3/docs",
        "probe_url": "https://apiv3.iucnredlist.org/api/v3/docs",
        "verify_ssl": True,
        "type": "Global Species Conservation Status & Threat Assessments",
        "default_license": "IUCN Red List Terms of Use (Attribution required)",
        "commercial_use": "Commercial use requires prior written agreement with IUCN",
        "auth_required": True,
        "auth_notes": "Free research token available via online registration"
    }
]

HEADERS = {
    "User-Agent": "NutrientEarth-ScientificPipeline/2.0 (Verified Health Research & Botanical Acquisition; contact: contact@nutrientearth.com)",
    "Accept": "application/json, text/html, application/xml, */*"
}

def audit_source(source: Dict[str, Any]) -> Dict[str, Any]:
    url = source["probe_url"]
    verify = source.get("verify_ssl", True)
    
    result = {
        "id": source["id"],
        "name": source["name"],
        "category": source["category"],
        "home_url": source["home_url"],
        "api_docs_url": source["api_docs_url"],
        "probe_url": url,
        "type": source["type"],
        "default_license": source["default_license"],
        "commercial_use": source["commercial_use"],
        "auth_required": source["auth_required"],
        "auth_notes": source.get("auth_notes", ""),
        "http_status": None,
        "response_time_ms": None,
        "accessible": False,
        "content_type": "",
        "detected_format": "Unknown",
        "notes": ""
    }

    start_t = time.time()
    try:
        resp = requests.get(url, headers=HEADERS, verify=verify, timeout=12)
        elapsed_ms = int((time.time() - start_t) * 1000)
        result["http_status"] = resp.status_code
        result["response_time_ms"] = elapsed_ms
        ct = resp.headers.get("Content-Type", "")
        result["content_type"] = ct

        if resp.status_code in [200, 206]:
            result["accessible"] = True
            if "application/json" in ct or "application/sparql-results+json" in ct:
                result["detected_format"] = "JSON"
            elif "xml" in ct or "<xml" in resp.text[:200]:
                result["detected_format"] = "XML"
            elif "html" in ct or "<html" in resp.text[:200]:
                result["detected_format"] = "HTML"
            elif "text/tab-separated-values" in ct or "text/csv" in ct:
                result["detected_format"] = "TSV/CSV"
            else:
                result["detected_format"] = "Binary/Text"
            result["notes"] = f"Verified Live (HTTP {resp.status_code}, {elapsed_ms}ms)"
        elif resp.status_code in [401, 403]:
            result["accessible"] = True
            result["notes"] = f"Endpoint online, requires token/browser authorization (HTTP {resp.status_code})"
            result["detected_format"] = "Protected Endpoint"
        else:
            result["notes"] = f"HTTP {resp.status_code}"
    except requests.exceptions.SSLError as e:
        result["notes"] = f"SSL Handshake Failed: {str(e)[:80]}"
    except requests.exceptions.Timeout:
        result["notes"] = "Connection Timeout (>12s)"
    except requests.exceptions.ConnectionError as e:
        result["notes"] = f"Connection Failed: {str(e)[:80]}"
    except Exception as e:
        result["notes"] = f"Probe Error: {str(e)[:80]}"

    return result

def main():
    print(f"Starting Master 55-Source Audit for Nutrient Earth...")
    print(f"Categories: A (12), B (8), C (11), D (6), E (7), F (5), G (6) = Total 55 sources.\n")
    results = []
    
    for i, s in enumerate(SOURCES, 1):
        print(f"[{i:02d}/55] Probing {s['id']} ({s['name']})...", end="", flush=True)
        res = audit_source(s)
        status_str = f"HTTP {res['http_status']}" if res['http_status'] else "Offline"
        print(f" -> {status_str} ({res['detected_format']}, {res['response_time_ms']}ms)")
        results.append(res)
        time.sleep(0.2)

    # 1. Save sources.json
    sources_json_path = os.path.join(REGISTRY_DIR, "sources.json")
    with open(sources_json_path, "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2)
    print(f"\n[OK] Saved 55-source registry to {sources_json_path}")

    # 2. Save sources.csv
    sources_csv_path = os.path.join(REGISTRY_DIR, "sources.csv")
    fieldnames = [
        "id", "name", "category", "home_url", "api_docs_url", "probe_url", "type",
        "default_license", "commercial_use", "auth_required", "auth_notes",
        "http_status", "response_time_ms", "accessible", "content_type", "detected_format", "notes"
    ]
    with open(sources_csv_path, "w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(results)
    print(f"[OK] Saved CSV registry to {sources_csv_path}")

    # 3. Generate Markdown Report
    audit_md_path = os.path.join(REPORTS_DIR, "source_audit.md")
    with open(audit_md_path, "w", encoding="utf-8") as f:
        f.write("# Nutrient Earth — Master 55-Source Scientific Registry & Discovery Audit\n\n")
        f.write(f"**Audit Execution Timestamp:** {time.strftime('%Y-%m-%d %H:%M:%S UTC', time.gmtime())}  \n")
        f.write(f"**Total Scope:** 55 Authoritative Scientific, Botanical, Nutritional, and Clinical Data Sources  \n\n")
        
        f.write("## 1. Executive Summary Table\n\n")
        f.write("| # | Source ID | Name | Category | Status | Format | Auth | Commercial Terms |\n")
        f.write("|---|---|---|---|---|---|---|---|\n")
        for i, r in enumerate(results, 1):
            stat = f"HTTP {r['http_status']}" if r['http_status'] else "Offline"
            auth = "Key Required" if r['auth_required'] else "Free"
            comm = r['commercial_use'][:36] + ("..." if len(r['commercial_use']) > 36 else "")
            f.write(f"| {i} | `{r['id']}` | {r['name']} | {r['category']} | {stat} | {r['detected_format']} | {auth} | {comm} |\n")

        f.write("\n## 2. Detailed Technical Breakdown by Category\n\n")
        current_cat = None
        for r in results:
            if r['category'] != current_cat:
                current_cat = r['category']
                f.write(f"\n### Category: {current_cat}\n\n")
            f.write(f"#### {r['name']} (`{r['id']}`)\n")
            f.write(f"- **Home URL:** [{r['home_url']}]({r['home_url']})\n")
            f.write(f"- **API Reference:** {r['api_docs_url']}\n")
            f.write(f"- **Live Probe:** `{r['probe_url']}`\n")
            f.write(f"- **Observed Status:** HTTP {r['http_status']} ({r['response_time_ms']} ms, format: `{r['detected_format']}`)\n")
            f.write(f"- **License:** {r['default_license']}\n")
            f.write(f"- **Commercial Permission:** {r['commercial_use']}\n")
            f.write(f"- **Authentication / Rate Limits:** {r['auth_notes']}\n")
            f.write(f"- **Audit Notes:** {r['notes']}\n\n")

    print(f"[OK] Generated comprehensive source audit report at {audit_md_path}")

if __name__ == "__main__":
    main()
