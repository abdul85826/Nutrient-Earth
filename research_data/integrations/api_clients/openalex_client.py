"""
Nutrient Earth — OpenAlex Scholarly Knowledge Graph API Client
Connects to OpenAlex REST API using the polite pool for high-throughput scholarly search,
citation counting, concept mapping, and institution attribution.
"""

import os
from typing import Dict, Any, List, Optional
from .base_client import BaseAPIClient

class OpenAlexClient(BaseAPIClient):
    def __init__(self, email: Optional[str] = None):
        super().__init__(
            base_url="https://api.openalex.org",
            rate_limit_delay_sec=0.15,
            timeout_sec=20.0
        )
        self.email = email or os.getenv("OPENALEX_EMAIL", "contact@nutrientearth.com")

    def search_works(self, query: str, per_page: int = 10) -> List[Dict[str, Any]]:
        """Search scholarly works in OpenAlex."""
        params = {
            "search": query,
            "per_page": str(per_page),
            "mailto": self.email
        }
        data = self.get_json("works", params=params)
        results = data.get("results", [])

        normalized = []
        for r in results:
            authors = [
                a.get("author", {}).get("display_name")
                for a in r.get("authorships", [])
                if a.get("author", {}).get("display_name")
            ]
            concepts = [
                c.get("display_name")
                for c in r.get("concepts", [])
                if c.get("display_name") and c.get("score", 0) > 0.4
            ]
            oa = r.get("open_access", {})

            normalized.append({
                "openalex_id": r.get("id"),
                "doi": r.get("doi"),
                "title": r.get("title"),
                "publication_year": r.get("publication_year"),
                "authors": authors,
                "concepts": concepts,
                "is_oa": oa.get("is_oa", False),
                "oa_status": oa.get("oa_status"),
                "oa_url": oa.get("oa_url"),
                "cited_by_count": r.get("cited_by_count", 0),
                "landing_page_url": r.get("primary_location", {}).get("landing_page_url")
            })
        return normalized

