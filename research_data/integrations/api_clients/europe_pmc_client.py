"""
Nutrient Earth — Europe PMC API Client
Production client for querying European and global open-access biomedical literature, preprints,
and accessing full-text availability markers.
"""

from typing import Dict, Any, List, Optional
from .base_client import BaseAPIClient

class EuropePMCClient(BaseAPIClient):
    def __init__(self):
        super().__init__(
            base_url="https://www.ebi.ac.uk/europepmc/webservices/rest",
            rate_limit_delay_sec=0.2,
            timeout_sec=20.0
        )

    def search(
        self,
        query: str,
        page_size: int = 10,
        result_type: str = "core",
        synonym: bool = True
    ) -> List[Dict[str, Any]]:
        """Search Europe PMC publications with core metadata."""
        params = {
            "query": query,
            "resultType": result_type,
            "synonym": "true" if synonym else "false",
            "pageSize": str(page_size),
            "format": "json"
        }
        data = self.get_json("search", params=params)
        results = data.get("resultList", {}).get("result", [])

        normalized = []
        for r in results:
            normalized.append({
                "id": r.get("id"),
                "pmid": r.get("pmid"),
                "pmcid": r.get("pmcid"),
                "doi": r.get("doi"),
                "title": r.get("title", "").rstrip("."),
                "author_string": r.get("authorString", ""),
                "journal_title": r.get("journalTitle", ""),
                "pub_year": r.get("pubYear"),
                "abstract": r.get("abstractText", ""),
                "is_open_access": r.get("isOpenAccess") == "Y",
                "in_epmc": r.get("inEPMC") == "Y",
                "cited_by_count": r.get("citedByCount", 0),
                "url": f"https://europepmc.org/article/{r.get('source', 'MED')}/{r.get('id')}"
            })
        return normalized

