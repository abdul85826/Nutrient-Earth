"""
LiverTox NCBI E-utilities Client
Retrieves clinical hepatotoxicity assessments, likelihood scores (Category A to E/X),
and drug/herb-induced liver injury patterns from NCBI Bookshelf (NBK547852).
"""

import re
from typing import Dict, Any, List, Optional
from .base_client import BaseAPIClient

class LiverToxClient(BaseAPIClient):
    def __init__(self, api_key: Optional[str] = None, rate_limit_delay_sec: float = 0.4):
        super().__init__(
            base_url="https://eutils.ncbi.nlm.nih.gov/entrez/eutils",
            rate_limit_delay_sec=rate_limit_delay_sec,
            timeout_sec=15.0
        )
        self.api_key = api_key

    def search_agent(self, agent_name: str) -> List[str]:
        """Search LiverTox bookshelf chapters for a drug or botanical name."""
        params = {
            "db": "books",
            "term": f"LiverTox[book] AND {agent_name}",
            "retmode": "json",
            "retmax": 5
        }
        if self.api_key:
            params["api_key"] = self.api_key

        data = self.get_json("/esearch.fcgi", params=params)
        id_list = data.get("esearchresult", {}).get("idlist", [])
        return id_list

    def get_summary(self, book_id: str) -> Dict[str, Any]:
        """Retrieve chapter summary and title for a specific LiverTox book item."""
        params = {
            "db": "books",
            "id": book_id,
            "retmode": "json"
        }
        if self.api_key:
            params["api_key"] = self.api_key

        data = self.get_json("/esummary.fcgi", params=params)
        result = data.get("result", {}).get(book_id, {})
        return result

