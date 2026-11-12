"""
Nutrient Earth — Wikidata API Client
Searches Wikidata entities and retrieves multilingual labels, descriptions,
and external identifiers for biomedical and botanical entities.
"""

from typing import Dict, Any, List, Optional
from .base_client import BaseAPIClient

class WikidataClient(BaseAPIClient):
    def __init__(self):
        super().__init__(
            base_url="https://www.wikidata.org/w",
            rate_limit_delay_sec=0.25,
            timeout_sec=20.0,
            default_headers={
                "User-Agent": "NutrientEarth-EntityBot/1.0 (contact: contact@nutrientearth.com)"
            }
        )

    def search_entities(self, query: str, limit: int = 5) -> List[Dict[str, Any]]:
        """Search Wikidata entities by label or alias."""
        params = {
            "action": "wbsearchentities",
            "search": query,
            "language": "en",
            "format": "json",
            "limit": str(limit)
        }
        data = self.get_json("api.php", params=params)
        search_results = data.get("search", [])

        results = []
        for s in search_results:
            results.append({
                "entity_id": s.get("id"),
                "label": s.get("label"),
                "description": s.get("description"),
                "concept_uri": s.get("concepturi"),
                "url": s.get("url") or f"https://www.wikidata.org/wiki/{s.get('id')}"
            })
        return results

