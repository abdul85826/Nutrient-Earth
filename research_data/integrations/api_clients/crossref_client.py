"""
Nutrient Earth — Crossref Works API Client
Connects to Crossref REST API using the polite pool for DOI lookup, citation tracking,
and academic publication metadata retrieval.
"""

import os
from typing import Dict, Any, List, Optional
from .base_client import BaseAPIClient

class CrossrefClient(BaseAPIClient):
    def __init__(self, email: Optional[str] = None):
        super().__init__(
            base_url="https://api.crossref.org",
            rate_limit_delay_sec=0.2,
            timeout_sec=20.0
        )
        self.email = email or os.getenv("CROSSREF_EMAIL", "contact@nutrientearth.com")

    def search_works(self, query: str, rows: int = 10) -> List[Dict[str, Any]]:
        """Search publications in Crossref."""
        params = {
            "query": query,
            "rows": str(rows),
            "mailto": self.email
        }
        data = self.get_json("works", params=params)
        items = data.get("message", {}).get("items", [])

        normalized = []
        for it in items:
            authors = []
            for a in it.get("author", []):
                given = a.get("given", "")
                family = a.get("family", "")
                authors.append(f"{given} {family}".strip())

            title_list = it.get("title", [])
            title = title_list[0] if title_list else ""
            container = it.get("container-title", [])
            journal = container[0] if container else ""

            # Extract year from date-parts
            pub_date = it.get("published-print") or it.get("published-online") or {}
            date_parts = pub_date.get("date-parts", [[]])[0]
            year = date_parts[0] if date_parts else None

            normalized.append({
                "doi": it.get("DOI"),
                "title": title,
                "journal": journal,
                "pub_year": year,
                "authors": authors,
                "type": it.get("type"),
                "publisher": it.get("publisher"),
                "issn": it.get("ISSN", []),
                "url": it.get("URL") or f"https://doi.org/{it.get('DOI')}"
            })
        return normalized

    def get_by_doi(self, doi: str) -> Optional[Dict[str, Any]]:
        """Fetch exact metadata for a given DOI."""
        clean_doi = doi.strip()
        params = {"mailto": self.email}
        try:
            data = self.get_json(f"works/{clean_doi}", params=params)
            it = data.get("message", {})
            title_list = it.get("title", [])
            title = title_list[0] if title_list else ""
            return {
                "doi": it.get("DOI"),
                "title": title,
                "journal": (it.get("container-title") or [""])[0],
                "publisher": it.get("publisher"),
                "url": f"https://doi.org/{it.get('DOI')}"
            }
        except Exception as e:
            self.logger.warning(f"Failed to fetch Crossref DOI {clean_doi}: {e}")
            return None

