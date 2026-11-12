"""
Research Record Normalization Pipeline
Normalizes scientific publications, clinical trials, and reviews from AYUSH, Zenodo, and OSF
into NutrientEarthResearchRecord conforming to research_record.schema.json.
"""

import os
import json
import hashlib
from typing import Dict, Any, Optional

class ResearchImporter:
    @staticmethod
    def generate_record_id(source_id: str, title: str, doi: Optional[str] = None) -> str:
        if doi and doi.strip():
            clean_doi = doi.strip().lower()
            return f"res_doi_{hashlib.md5(clean_doi.encode('utf-8')).hexdigest()[:12]}"
        clean_title = "".join(c for c in title.lower() if c.isalnum())
        return f"res_{source_id}_{hashlib.md5(clean_title.encode('utf-8')).hexdigest()[:12]}"

    @staticmethod
    def normalize_ayush_record(raw: Dict[str, Any]) -> Dict[str, Any]:
        title = (raw.get("title") or f"AYUSH Research Publication {raw.get('article_id', 'unknown')}").strip()
        record_id = f"res_ayush_{raw.get('article_id', 'unknown')}"
        
        # Categorize evidence type
        ab = (raw.get("abstract") or "").lower()
        if "clinical trial" in ab or "patients were" in ab or "double-blind" in ab or "randomized" in ab:
            study_type = "clinical_trial"
            evidence_type = "human_clinical"
        elif "rats" in ab or "mice" in ab or "in vivo" in ab or "animal model" in ab:
            study_type = "preclinical_in_vivo"
            evidence_type = "animal_in_vivo"
        elif "cell" in ab or "in vitro" in ab or "assay" in ab:
            study_type = "in_vitro"
            evidence_type = "cellular_in_vitro"
        elif "review" in ab or "meta-analysis" in ab:
            study_type = "review"
            evidence_type = "systematic_synthesis"
        else:
            study_type = "drug_research"
            evidence_type = "phytochemical_analytical"

        return {
            "record_id": record_id,
            "source_id": "src_ayushportal",
            "original_source_id": str(raw.get("article_id")),
            "title": title,
            "authors": raw.get("authors", []),
            "abstract": raw.get("abstract") or "No abstract provided in original portal record.",
            "publication_date": str(raw.get("year")) if raw.get("year") else None,
            "journal": raw.get("journal"),
            "volume": None,
            "issue": None,
            "pages": None,
            "doi": None,
            "url": raw.get("url") or f"https://ayushportal.nic.in/ShowRslt2.aspx?IDD={raw.get('article_id')}",
            "pdf_url": raw.get("pdf_url"),
            "local_pdf_path": raw.get("local_pdf_path"),
            "study_type": study_type,
            "medical_system": raw.get("system") or "Ayurveda",
            "population": None,
            "sample_size": None,
            "intervention": raw.get("keyword"),
            "comparator": None,
            "outcomes": [],
            "results_summary": None,
            "limitations": None,
            "evidence_type": evidence_type,
            "funding_and_conflicts": None,
            "keywords": raw.get("keywords", []),
            "relevance_score": 0.85,
            "license": "Ministry of Ayush / Public Research Repository",
            "acquisition_date": raw.get("acquisition_date") or "2026-11-11T18:00:00Z",
            "extraction_status": "full_text_and_pdf" if raw.get("local_pdf_path") else "metadata_and_abstract_only"
        }

    @staticmethod
    def normalize_zenodo_record(raw: Dict[str, Any]) -> Dict[str, Any]:
        meta = raw.get("metadata", {})
        title = meta.get("title", "").strip()
        doi = meta.get("doi")
        record_id = ResearchImporter.generate_record_id("src_zenodo", title, doi)
        
        creators = [c.get("name") for c in meta.get("creators", []) if c.get("name")]
        
        return {
            "record_id": record_id,
            "source_id": "src_zenodo",
            "original_source_id": str(raw.get("id")),
            "title": title,
            "authors": creators,
            "abstract": meta.get("description", ""),
            "publication_date": meta.get("publication_date"),
            "journal": meta.get("journal_title"),
            "volume": None,
            "issue": None,
            "pages": None,
            "doi": doi,
            "url": raw.get("links", {}).get("html", f"https://zenodo.org/record/{raw.get('id')}"),
            "pdf_url": None,
            "local_pdf_path": None,
            "study_type": "unclassified",
            "medical_system": "Integrative_Medicine",
            "population": None,
            "sample_size": None,
            "intervention": None,
            "comparator": None,
            "outcomes": [],
            "results_summary": None,
            "limitations": None,
            "evidence_type": "phytochemical_analytical",
            "funding_and_conflicts": None,
            "keywords": meta.get("keywords", []),
            "relevance_score": 0.80,
            "license": meta.get("license", {}).get("id", "Open Access"),
            "acquisition_date": "2026-11-11T18:00:00Z",
            "extraction_status": "metadata_and_abstract_only"
        }
