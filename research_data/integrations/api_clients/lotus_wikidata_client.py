"""
Nutrient Earth — LOTUS Natural Products & Plant-Compound API Client
Integrates with LOTUS Initiative data and Wikidata SPARQL endpoint to resolve
plant-compound pairings, natural product structures, and phytochemical evidence.
"""

from typing import Dict, Any, List, Optional
from .base_client import BaseAPIClient

class LotusWikidataClient(BaseAPIClient):
    def __init__(self):
        super().__init__(
            base_url="https://query.wikidata.org",
            rate_limit_delay_sec=0.5,
            timeout_sec=30.0,
            default_headers={
                "User-Agent": "NutrientEarth-PhytochemicalBot/1.0 (contact: contact@nutrientearth.com)",
                "Accept": "application/sparql-results+json"
            }
        )

    def query_compounds_for_plant(self, taxon_scientific_name: str, limit: int = 15) -> List[Dict[str, Any]]:
        """
        Query LOTUS / Wikidata for natural compounds found in a plant taxon.
        Property P235 represents InChIKey, P662 PubChem CID, P225 taxon name.
        """
        sparql_query = f"""
        SELECT DISTINCT ?taxon ?taxonLabel ?compound ?compoundLabel ?inchikey ?pubchemCid WHERE {{
          ?taxon wdt:P225 "{taxon_scientific_name}" .
          ?compound wdt:P235 ?inchikey .
          OPTIONAL {{ ?compound wdt:P662 ?pubchemCid . }}
          SERVICE wikibase:label {{ bd:serviceParam wikibase:language "en". }}
        }}
        LIMIT {limit}
        """
        params = {
            "query": sparql_query,
            "format": "json"
        }
        try:
            data = self.get_json("sparql", params=params)
            bindings = data.get("results", {}).get("bindings", [])

            results = []
            for b in bindings:
                results.append({
                    "plant_name": taxon_scientific_name,
                    "compound_name": b.get("compoundLabel", {}).get("value"),
                    "compound_uri": b.get("compound", {}).get("value"),
                    "inchikey": b.get("inchikey", {}).get("value"),
                    "pubchem_cid": b.get("pubchemCid", {}).get("value"),
                    "provenance": "LOTUS Initiative / Wikidata Knowledge Base"
                })
            return results
        except Exception as e:
            self.logger.warning(f"SPARQL error for {taxon_scientific_name}: {e}")
            return []

