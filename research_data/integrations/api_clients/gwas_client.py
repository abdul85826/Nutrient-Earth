"""
NHGRI-EBI GWAS Catalog REST API Client (v2)
Connects to https://www.ebi.ac.uk/gwas/rest/api/v2/
Retrieves genome-wide association studies, SNP-trait associations, odds ratios, and p-values.
"""

from typing import Dict, Any, List, Optional
from .base_client import BaseAPIClient

class GWASClient(BaseAPIClient):
    def __init__(self, rate_limit_delay_sec: float = 0.3):
        super().__init__(
            base_url="https://www.ebi.ac.uk/gwas/rest/api/v2",
            rate_limit_delay_sec=rate_limit_delay_sec,
            timeout_sec=15.0
        )

    def search_studies_by_trait(self, trait: str, size: int = 20, page: int = 0) -> Dict[str, Any]:
        """Search published GWAS studies by reported trait."""
        endpoint = "/studies"
        params = {
            "search": trait,
            "size": size,
            "page": page
        }
        return self.get_json(endpoint, params=params)

    def get_associations_for_variant(self, rs_id: str, size: int = 20) -> Dict[str, Any]:
        """Fetch all trait associations for a given rsID."""
        endpoint = f"/singleNucleotidePolymorphisms/{rs_id}/associations"
        params = {"size": size}
        return self.get_json(endpoint, params=params)

    def get_study_details(self, accession_id: str) -> Dict[str, Any]:
        """Fetch complete metadata for a GWAS study (GCST identifier)."""
        endpoint = f"/studies/{accession_id}"
        return self.get_json(endpoint)

