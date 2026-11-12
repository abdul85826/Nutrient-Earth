"""
OpenStreetMap Nominatim REST API Client
Connects to https://nominatim.openstreetmap.org/
Discovers health facilities, pharmacies, ayurvedic dispensaries, and organic markets.
Strict rate limit: <= 1.0 request per second in compliance with OSM usage policy.
"""

from typing import Dict, Any, List, Optional
from .base_client import BaseAPIClient

class OSMNominatimClient(BaseAPIClient):
    def __init__(self, rate_limit_delay_sec: float = 1.0):
        super().__init__(
            base_url="https://nominatim.openstreetmap.org",
            rate_limit_delay_sec=rate_limit_delay_sec,
            timeout_sec=15.0,
            default_headers={
                "User-Agent": "NutrientEarth-ScientificPipeline/1.0 (Health & Botanical Discovery; dev@nutrientearth.win)"
            }
        )

    def search_amenities(self, query: str, limit: int = 20) -> List[Dict[str, Any]]:
        """Search Points of Interest (POIs) such as clinics, pharmacies, and markets."""
        params = {
            "q": query,
            "format": "json",
            "limit": limit,
            "addressdetails": 1
        }
        return self.get_json("/search", params=params)

    def reverse_geocode(self, latitude: float, longitude: float) -> Dict[str, Any]:
        """Convert geographic coordinates to formatted administrative address."""
        params = {
            "lat": latitude,
            "lon": longitude,
            "format": "json",
            "addressdetails": 1
        }
        return self.get_json("/reverse", params=params)

