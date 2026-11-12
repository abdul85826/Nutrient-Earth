"""
OpenStax CMS API Client
Connects to https://openstax.org/apps/cms/api/v2/
Retrieves open-access curriculum metadata for Anatomy and Physiology 2e (CC BY 4.0).
"""

from typing import Dict, Any, List, Optional
from .base_client import BaseAPIClient

class OpenStaxClient(BaseAPIClient):
    def __init__(self, rate_limit_delay_sec: float = 0.5):
        super().__init__(
            base_url="https://openstax.org/apps/cms/api/v2",
            rate_limit_delay_sec=rate_limit_delay_sec,
            timeout_sec=15.0
        )

    def get_anatomy_book_metadata(self) -> Dict[str, Any]:
        """Fetch book overview, table of contents, and chapters for Anatomy and Physiology 2e."""
        params = {
            "type": "books.Book",
            "slug": "anatomy-and-physiology-2e"
        }
        return self.get_json("/pages/", params=params)

