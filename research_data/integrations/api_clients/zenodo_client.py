"""
Zenodo REST API Client
Connects to https://zenodo.org/api/
Retrieves open scientific research records, clinical datasets, and academic publications.
"""

from typing import Dict, Any, List, Optional
from .base_client import BaseAPIClient

class ZenodoClient(BaseAPIClient):
    def __init__(self, access_token: Optional[str] = None, rate_limit_delay_sec: float = 0.5):
        super().__init__(
            base_url="https://zenodo.org/api",
            rate_limit_delay_sec=rate_limit_delay_sec,
            timeout_sec=15.0
        )
        self.access_token = access_token

    def search_records(self, query: str, size: int = 20, page: int = 1) -> Dict[str, Any]:
        """Search Zenodo records by query string, size, and page."""
        params = {
            "q": query,
            "size": size,
            "page": page,
            "status": "published"
        }
        if self.access_token:
            params["access_token"] = self.access_token
        return self.get_json("/records", params=params)

    def get_record(self, record_id: str) -> Dict[str, Any]:
        """Fetch full metadata and file links for a specific Zenodo record."""
        endpoint = f"/records/{record_id}"
        params = {}
        if self.access_token:
            params["access_token"] = self.access_token
        return self.get_json(endpoint, params=params)

