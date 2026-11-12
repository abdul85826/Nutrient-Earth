"""
Nutrient Earth — ChEBI (Chemical Entities of Biological Interest) API Client
Connects to EMBL-EBI Ontology Lookup Service (OLS4) to search and resolve
ChEBI chemical ontologies, roles, and biological relationships.
"""

from typing import Dict, Any, List, Optional
from .base_client import BaseAPIClient

class ChEBIClient(BaseAPIClient):
    def __init__(self):
        super().__init__(
            base_url="https://www.ebi.ac.uk/ols4/api",
            rate_limit_delay_sec=0.25,
            timeout_sec=20.0
        )

    def search_chemical(self, query: str, rows: int = 5) -> List[Dict[str, Any]]:
        """Search ChEBI ontology for a chemical entity."""
        params = {
            "q": query,
            "ontology": "chebi",
            "rows": str(rows)
        }
        data = self.get_json("search", params=params)
        docs = data.get("response", {}).get("docs", [])

        results = []
        for d in docs:
            obo_id = d.get("obo_id")  # e.g. CHEBI:39015
            results.append({
                "chebi_id": obo_id,
                "label": d.get("label"),
                "description": (d.get("description") or [""])[0],
                "synonyms": d.get("synonym", []),
                "iri": d.get("iri"),
                "ontology_name": d.get("ontology_name"),
                "url": f"https://www.ebi.ac.uk/chebi/searchId.do?chebiId={obo_id}"
            })
        return results

