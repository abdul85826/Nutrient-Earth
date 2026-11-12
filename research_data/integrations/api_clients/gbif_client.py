"""
Nutrient Earth — GBIF (Global Biodiversity Information Facility) API Client
Connects to GBIF Taxonomic Species API for accepted botanical names,
taxonomic validation, and kingdom/family hierarchies.
"""

from typing import Dict, Any, Optional
from .base_client import BaseAPIClient

class GBIFClient(BaseAPIClient):
    def __init__(self):
        super().__init__(
            base_url="https://api.gbif.org/v1",
            rate_limit_delay_sec=0.2,
            timeout_sec=20.0
        )

    def match_species(self, botanical_name: str) -> Optional[Dict[str, Any]]:
        """Reconcile and validate a botanical name with GBIF Taxonomy."""
        params = {
            "name": botanical_name,
            "verbose": "false"
        }
        try:
            data = self.get_json("species/match", params=params)
            match_type = data.get("matchType")
            if match_type in ["EXACT", "FUZZY"]:
                return {
                    "taxon_key": data.get("usageKey"),
                    "scientific_name": data.get("scientificName"),
                    "canonical_name": data.get("canonicalName"),
                    "rank": data.get("rank"),
                    "status": data.get("status"),
                    "confidence": data.get("confidence"),
                    "kingdom": data.get("kingdom"),
                    "phylum": data.get("phylum"),
                    "order": data.get("order"),
                    "family": data.get("family"),
                    "genus": data.get("genus"),
                    "source_url": f"https://www.gbif.org/species/{data.get('usageKey')}"
                }
            return None
        except Exception as e:
            self.logger.warning(f"Error matching species {botanical_name} in GBIF: {e}")
            return None

