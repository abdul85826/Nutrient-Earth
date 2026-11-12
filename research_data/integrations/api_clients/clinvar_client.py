"""
NCBI ClinVar E-utilities API Client
Connects to https://eutils.ncbi.nlm.nih.gov/entrez/eutils/
Queries genomic variants and retrieves clinical significance, review status, and disease associations.
"""

from typing import Dict, Any, List, Optional
from .base_client import BaseAPIClient

class ClinVarClient(BaseAPIClient):
    def __init__(self, api_key: Optional[str] = None, rate_limit_delay_sec: float = 0.4):
        super().__init__(
            base_url="https://eutils.ncbi.nlm.nih.gov/entrez/eutils",
            rate_limit_delay_sec=rate_limit_delay_sec,
            timeout_sec=15.0
        )
        self.api_key = api_key

    def search_variants(self, term: str, retmax: int = 20) -> List[str]:
        """Search ClinVar for variant IDs matching gene symbol or disease phenotype."""
        params = {
            "db": "clinvar",
            "term": term,
            "retmode": "json",
            "retmax": retmax
        }
        if self.api_key:
            params["api_key"] = self.api_key

        data = self.get_json("/esearch.fcgi", params=params)
        id_list = data.get("esearchresult", {}).get("idlist", [])
        return id_list

    def get_variant_summaries(self, id_list: List[str]) -> Dict[str, Any]:
        """Fetch summary objects for a list of ClinVar variation IDs."""
        if not id_list:
            return {}
        
        params = {
            "db": "clinvar",
            "id": ",".join(id_list),
            "retmode": "json"
        }
        if self.api_key:
            params["api_key"] = self.api_key

        data = self.get_json("/esummary.fcgi", params=params)
        return data.get("result", {})

