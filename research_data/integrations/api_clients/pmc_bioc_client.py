"""
Nutrient Earth — PMC Open Access BioC API Client
Retrieves full-text structured Unicode JSON articles from the NCBI BioNLP PMC Open Access service.
Extracts sections, headings, paragraphs, and references without screen scraping.
"""

import re
from typing import Dict, Any, List, Optional
from .base_client import BaseAPIClient

class PMCBioCClient(BaseAPIClient):
    def __init__(self):
        super().__init__(
            base_url="https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_json",
            rate_limit_delay_sec=0.4,
            timeout_sec=25.0
        )

    def fetch_article(self, pmc_id: str) -> Optional[Dict[str, Any]]:
        """
        Fetch full-text BioC JSON for an open-access article.
        pmc_id can be 'PMC3573577' or '3573577'.
        """
        clean_id = pmc_id.upper()
        if not clean_id.startswith("PMC"):
            clean_id = f"PMC{clean_id}"

        endpoint = f"{clean_id}/unicode"
        try:
            data = self.get_json(endpoint)
        except Exception as e:
            self.logger.warning(f"Failed to fetch BioC JSON for {clean_id}: {e}")
            return None

        documents = data.get("documents", [])
        if not documents:
            return None

        doc = documents[0]
        passages = doc.get("passages", [])
        
        title = ""
        sections = []
        current_section = {"heading": "Introduction", "paragraphs": []}

        for p in passages:
            infons = p.get("infons", {})
            section_type = infons.get("section_type", "").lower()
            text = p.get("text", "").strip()

            if not text:
                continue

            if section_type == "title" and not title:
                title = text
            elif section_type in ["title", "section_title"]:
                if current_section["paragraphs"]:
                    sections.append(current_section)
                current_section = {"heading": text, "paragraphs": []}
            else:
                current_section["paragraphs"].append(text)

        if current_section["paragraphs"]:
            sections.append(current_section)

        return {
            "pmcid": clean_id,
            "title": title or doc.get("id"),
            "section_count": len(sections),
            "sections": sections,
            "license": "PMC Open Access Subset",
            "source_url": f"https://www.ncbi.nlm.nih.gov/pmc/articles/{clean_id}/"
        }

