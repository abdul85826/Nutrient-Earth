"""
Open-Meteo Weather REST API Client
Connects to https://api.open-meteo.com/v1/
Retrieves hourly and daily meteorological observations, UV index, and temperature.
"""

from typing import Dict, Any, List, Optional
from .base_client import BaseAPIClient

class OpenMeteoClient(BaseAPIClient):
    def __init__(self, rate_limit_delay_sec: float = 0.2):
        super().__init__(
            base_url="https://api.open-meteo.com/v1",
            rate_limit_delay_sec=rate_limit_delay_sec,
            timeout_sec=12.0
        )

    def get_current_and_daily(self, latitude: float, longitude: float) -> Dict[str, Any]:
        """Fetch current conditions and 7-day daily forecast for geographic coordinates."""
        params = {
            "latitude": latitude,
            "longitude": longitude,
            "current": "temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code",
            "daily": "temperature_2m_max,temperature_2m_min,uv_index_max,precipitation_sum",
            "timezone": "auto"
        }
        return self.get_json("/forecast", params=params)

