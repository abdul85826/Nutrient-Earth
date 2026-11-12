"""
DailyMed REST API Client (v2)
Connects to https://dailymed.nlm.nih.gov/dailymed/services/v2/
Retrieves official FDA drug labels, active ingredients, dosage forms, and boxed warnings.
"""

from typing import Dict, Any, List, Optional
from .base_client import BaseAPIClient

class DailyMedClient(BaseAPIClient):
    def __init__(self, rate_limit_delay_sec: float = 0.4):
        super().__init__(
            base_url="https://dailymed.nlm.nih.gov/dailymed/services/v2",
            rate_limit_delay_sec=rate_limit_delay_sec,
            timeout_sec=15.0
        )

    def search_spls_by_drug_name(self, drug_name: str, pagesize: int = 20, page: int = 1) -> Dict[str, Any]:
        """Search SPL records by generic or brand drug name."""
        endpoint = "/spls.json"
        params = {
            "drug_name": drug_name,
            "pagesize": pagesize,
            "page": page
        }
        return self.get_json(endpoint, params=params)

    def get_spl_details(self, setid: str) -> Dict[str, Any]:
        """Fetch full metadata and XML reference for a specific SPL setid."""
        endpoint = f"/spls/{setid}.json"
        return self.get_json(endpoint)

    def get_drug_packaging(self, setid: str) -> Dict[str, Any]:
        """Fetch packaging and NDC codes for an SPL."""
        endpoint = f"/spls/{setid}/packaging.json"
        return self.get_json(endpoint)

