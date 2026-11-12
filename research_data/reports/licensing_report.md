# Nutrient Earth — Comprehensive Scientific Data Licensing & Legal Audit

## Executive Summary
This document provides the legal and intellectual property compliance audit for all 35 scientific data sources integrated into or evaluated for **Nutrient Earth**.

Nutrient Earth is a health technology and precision nutrition platform. To protect the organization and its users, data acquisition and software integration must comply strictly with international copyright treaties, database rights, open data licenses, and institutional terms of service.

---

## 1. Public Domain Datasets (Unrestricted Commercial Use)

The following datasets are public domain works of the United States Federal Government (under 17 U.S.C. § 105) or dedicated to the public domain under CC0:

| Source ID | Source Name | Jurisdiction / Authority | License Terms | Commercial SaaS Status |
|---|---|---|---|---|
| `src_nih_ods` | NIH Office of Dietary Supplements | US Federal Government | US Public Domain | **Approved** (Unrestricted) |
| `src_nccih` | National Center for Complementary & Integrative Health | US Federal Government | US Public Domain | **Approved** (Unrestricted) |
| `src_dailymed` | DailyMed (FDA Drug Labels & SPL) | US NLM / FDA | US Public Domain | **Approved** (Unrestricted) |
| `src_clinvar` | NCBI ClinVar | US National Library of Medicine | US Public Domain | **Approved** (Unrestricted) |
| `src_livertox` | LiverTox: Drug-Induced Liver Injury | US NIDDK / NLM Bookshelf | US Public Domain | **Approved** (Unrestricted) |
| `src_clingen` | Clinical Genome Resource | ClinGen Consortium | CC0 1.0 Universal | **Approved** (Unrestricted) |
| `src_nasa` | NASA POWER Meteorological API | NASA Earth Science | US Public Domain | **Approved** (Unrestricted) |

### Compliance Requirement
While legal restrictions do not prohibit commercial reuse, standard scientific attribution and publication provenance must be preserved to maintain medical auditability.

---

## 2. Permissive Open Access Licenses (CC BY, BSD, OGD)

These datasets permit commercial use, modification, and redistribution, provided appropriate attribution is displayed:

| Source ID | Source Name | License | Attribution Requirement |
|---|---|---|---|
| `src_openstax` | OpenStax Anatomy and Physiology 2e | CC BY 4.0 | Mandatory: *"Anatomy and Physiology 2e from OpenStax, CC BY 4.0"* |
| `src_gwas_catalog` | NHGRI-EBI GWAS Catalog | CC BY 4.0 | Mandatory: Cite GWAS Catalog publications & EMBL-EBI |
| `src_ensembl` | Ensembl Genome Browser | CC BY 4.0 Equivalent | Mandatory: Cite Ensembl annual nucleic acids research paper |
| `src_sports2d` | Sports2D Kinematics Engine | BSD 3-Clause | Mandatory: Retain BSD copyright notice in distribution |
| `src_india_gov` | Open Government Data Platform India | GODL - India | Mandatory: Attribute Government of India and data.gov.in |
| `src_agmarknet` | Agricultural Marketing Information Network | GODL - India | Mandatory: Attribute Directorate of Marketing & Inspection |
| `src_pacompendium` | Compendium of Physical Activities | Scientific Attribution | Mandatory: Cite Ainsworth et al. 2011/2024 Compendium |

---

## 3. Share-Alike & Copyleft Licenses (Special Architecture Required)

These licenses permit commercial use, but require derivative datasets or software to be shared under the same terms:

### A. OpenStreetMap (`src_openstreetmap`, `src_overpass`)
- **License:** Open Database License (ODbL) 1.0.
- **Commercial Use:** Permitted.
- **Legal Risk:** If OSM data is combined with proprietary user data into an inseparable database ("Derivative Database"), the combined database may be subject to public disclosure under ODbL.
- **Architectural Solution for Nutrient Earth:** 
  Maintain strict architectural isolation: store OSM Point-of-Interest (POI) data in a standalone table/service with clear attribution (`© OpenStreetMap contributors`). Do not merge proprietary user health markers directly into the OSM spatial index.

### B. Z-Anatomy (`src_z_anatomy`)
- **License:** Creative Commons Attribution-ShareAlike 4.0 (CC BY-SA 4.0).
- **Commercial Use:** Permitted.
- **Legal Risk:** If 3D anatomical meshes are modified or adapted, the modified 3D model files must be distributed under CC BY-SA 4.0.
- **Architectural Solution for Nutrient Earth:**
  Use the 3D meshes as separate external assets (GLTF/GLB) without embedding proprietary proprietary source code inside the 3D asset bundles.

---

## 4. Non-Commercial & Contractually Restricted Sources

These sources are valuable for scientific reference and benchmarking, but **must not be redistributed in a paid commercial SaaS tier without a formal license agreement**:

| Source ID | Source Name | License / Terms | Restriction | Production Strategy |
|---|---|---|---|---|
| `src_who` | WHO Global Health Observatory | CC BY-NC-SA 3.0 IGO | Non-Commercial | Use for public health baseline research; apply for WHO commercial partnership for direct in-app indicators. |
| `src_pharmgkb` | PharmGKB | CC BY-SA with Commercial Exclusions | Commercial Exclusion | Commercial use requires Stanford Office of Technology Licensing agreement. Rely on ClinVar and GWAS Catalog for unencumbered variants. |
| `src_open_meteo` | Open-Meteo Weather API | Dual License | Free tier non-commercial only | Self-host the open-source Open-Meteo container, or purchase a commercial API tier. |
| `src_iucn` | IUCN Red List | IUCN Terms of Use | Commercial Agreement Required | Non-commercial research token free; commercial in-app biodiversity badges require IUCN agreement. |

---

## 5. Traditional Knowledge & Government Repositories

### Central Council for Research in Ayurvedic Sciences (CCRAS) & AYUSH Portal
- **Authority:** Ministry of Ayush, Government of India.
- **Status:** Public scientific research repository established under national health research initiatives.
- **Terms:** Freely accessible for scientific inquiry, medical education, and evidence synthesis. Research papers preserve journal copyright where published in external periodicals (e.g. *Annals of Ayurvedic Medicine*, *JAIM*, *AYU*).
- **Nutrient Earth Architecture:** We index and synthesize peer-reviewed citations, preserving author names, publication year, journal citation, and direct links to original papers without altering historical or scientific provenance.

