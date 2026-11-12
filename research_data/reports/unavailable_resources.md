# Nutrient Earth — Restricted & Gated Scientific Resources Audit

## Overview
This document tracks all audited scientific data sources that require special credentials, commercial licenses, data use agreements, or API tokens before automated bulk acquisition can proceed.

Nutrient Earth adheres strictly to institutional terms of service, intellectual property laws, and ethical data acquisition principles. We never simulate success, fabricate API keys, or bypass authentication mechanisms.

---

## 1. Resources Requiring Free User Registration & API Keys

### A. Open Government Data Platform India (`data.gov.in`)
- **Source ID:** `src_india_gov`
- **Current Access State:** HTTP 400 Bad Request when accessed without `api-key` parameter.
- **Why It Is Gated:** The National Informatics Centre (NIC) requires registered developer attribution for analytics and rate-limiting.
- **Licensing:** Government Open Data License - India (GODL). Free for commercial and non-commercial use with mandatory attribution.
- **How to Obtain Access:**
  1. Register at [https://data.gov.in/user/register](https://data.gov.in/user/register).
  2. Navigate to [https://data.gov.in/developer](https://data.gov.in/developer) and generate a personal API key.
  3. Add the key to `.env` as `OGD_INDIA_API_KEY=<your_key>`.
- **Acquired Alternative in Nutrient Earth:** Core agricultural mandi prices and commodity arrivals were acquired directly from Agmarknet and open ministerial catalogs.

---

### B. OpenAQ API v3 (`api.openaq.org`)
- **Source ID:** `src_openaq`
- **Current Access State:** HTTP 401 Unauthorized on API v3 endpoints.
- **Why It Is Gated:** OpenAQ introduced mandatory API key authentication in 2024 to manage global compute infrastructure costs.
- **Licensing:** Creative Commons Attribution 4.0 International (CC BY 4.0). Fully permitted for commercial use with attribution.
- **How to Obtain Access:**
  1. Create a free account at [https://explore.openaq.org/register](https://explore.openaq.org/register).
  2. Generate an API Key under Account Settings.
  3. Set `OPENAQ_API_KEY=<your_key>` in `.env`.
- **Acquired Alternative in Nutrient Earth:** Atmospheric and environmental observations are directly acquired via the NASA POWER API and Open-Meteo REST API.

---

### C. IUCN Red List of Threatened Species (`iucnredlist.org`)
- **Source ID:** `src_iucn`
- **Current Access State:** Gated behind private API token.
- **Why It Is Gated:** The International Union for Conservation of Nature (IUCN) monitors biodiversity data usage to ensure conservation ethics.
- **Licensing:** Free for non-commercial scientific research upon token approval. Commercial products require a formal commercial agreement with IUCN.
- **How to Obtain Access:**
  1. Apply for an API token at [https://apiv3.iucnredlist.org/api/v3/token](https://apiv3.iucnredlist.org/api/v3/token).
  2. Provide a project description specifying health/botanical conservation research.
  3. Once approved, set `IUCN_API_TOKEN=<token>` in `.env`.
- **Acquired Alternative in Nutrient Earth:** Botanical conservation status is extracted from the National Medicinal Plants Board (NMPB) conservation priority schedules and state biodiversity board registers.

---

## 2. Resources Requiring Institutional Agreements / Commercial Licenses

### D. PharmGKB (Pharmacogenomics Knowledgebase)
- **Source ID:** `src_pharmgkb`
- **Current Access State:** Monthly bulk TSV archives and API are freely accessible for research, but commercial redistribution is restricted.
- **Why It Is Gated:** PharmGKB is operated by Stanford University with NIH funding. Commercial deployment requires a license from PharmGKB / Stanford University Office of Technology Licensing.
- **Licensing:** CC BY-SA 4.0 with Commercial Restrictions.
- **Action Required for Nutrient Earth Production:**
  1. For development and internal research, public annotations can be analyzed under research fair use.
  2. For commercial SaaS production, apply for a Commercial License at [https://www.pharmgkb.org/page/commercialUse](https://www.pharmgkb.org/page/commercialUse).
- **Acquired Alternative in Nutrient Earth:** Variant classifications and drug response associations were acquired from NCBI ClinVar (US Public Domain) and the NHGRI-EBI GWAS Catalog (CC BY 4.0).

---

### E. PhysioNet Credentialed Data Tier (e.g. MIMIC-IV)
- **Source ID:** `src_physionet`
- **Current Access State:** Open datasets (PhysioBank open wave forms, PTB-XL ECG database) are accessible under ODC-By. Full intensive care clinical databases (MIMIC-IV) require credentialed access.
- **Why It Is Gated:** HIPAA compliance and human subjects protections.
- **Action Required to Unlock Credentialed Datasets:**
  1. Complete CITI "Data or Specimens Only Research" training.
  2. Sign PhysioNet Data Use Agreement (DUA).
  3. Submit request at [https://physionet.org/](https://physionet.org/).
- **Acquired Alternative in Nutrient Earth:** Open physiological and biomechanical models are acquired via OpenStax, the Compendium of Physical Activities, and PhysioNet open archives.

---

### F. Open-Meteo Commercial Tier
- **Source ID:** `src_open_meteo`
- **Current Access State:** Accessible under free non-commercial tier (up to 10,000 calls/day).
- **Why It Is Gated for Production:** Open-Meteo terms require commercial products to purchase an API subscription or run the open-source self-hosted container.
- **Action Required for Production:**
  1. Acquire an Open-Meteo commercial API key at [https://open-meteo.com/en/pricing](https://open-meteo.com/en/pricing), OR
  2. Deploy the open-source Open-Meteo Docker image on Nutrient Earth's backend cluster.

