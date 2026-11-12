"""
Nutrient Earth — Production Base API Client
Features:
- Configurable retries with exponential backoff and jitter
- Strict rate limiting per client
- Timeout handling
- Typed error classification
- Structured JSON and raw streaming support
"""

import time
import random
import logging
import requests
import urllib3
from typing import Optional, Dict, Any, Union

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

class APIClientError(Exception):
    """Base exception for API client operations."""
    pass

class RateLimitError(APIClientError):
    """Raised when an API rate limit (HTTP 429) is encountered."""
    pass

class AuthenticationError(APIClientError):
    """Raised when authentication fails (HTTP 401/403)."""
    pass

class ResourceNotFoundError(APIClientError):
    """Raised when a requested resource does not exist (HTTP 404)."""
    pass

class BaseAPIClient:
    def __init__(
        self,
        base_url: str,
        rate_limit_delay_sec: float = 0.5,
        max_retries: int = 3,
        timeout_sec: float = 15.0,
        verify_ssl: bool = True,
        default_headers: Optional[Dict[str, str]] = None
    ):
        self.base_url = base_url.rstrip("/")
        self.rate_limit_delay_sec = rate_limit_delay_sec
        self.max_retries = max_retries
        self.timeout_sec = timeout_sec
        self.verify_ssl = verify_ssl
        self.last_request_time = 0.0

        self.session = requests.Session()
        self.session.verify = self.verify_ssl
        
        headers = {
            "User-Agent": "NutrientEarth-ScientificPipeline/1.0 (Health Research & Botanical Protocol Integration; contact: dev@nutrientearth.win)",
            "Accept": "application/json, text/plain, */*"
        }
        if default_headers:
            headers.update(default_headers)
        self.session.headers.update(headers)

        self.logger = logging.getLogger(self.__class__.__name__)

    def _wait_for_rate_limit(self):
        elapsed = time.time() - self.last_request_time
        if elapsed < self.rate_limit_delay_sec:
            time.sleep(self.rate_limit_delay_sec - elapsed)
        self.last_request_time = time.time()

    def get(
        self,
        endpoint: str,
        params: Optional[Dict[str, Any]] = None,
        headers: Optional[Dict[str, str]] = None,
        stream: bool = False
    ) -> requests.Response:
        url = endpoint if endpoint.startswith("http") else f"{self.base_url}/{endpoint.lstrip('/')}"
        
        for attempt in range(1, self.max_retries + 1):
            self._wait_for_rate_limit()
            try:
                resp = self.session.get(
                    url,
                    params=params,
                    headers=headers,
                    timeout=self.timeout_sec,
                    stream=stream
                )
                
                if resp.status_code == 200 or resp.status_code == 206:
                    return resp
                elif resp.status_code == 429:
                    jitter = random.uniform(1.0, 2.5)
                    wait_time = (2 ** attempt) + jitter
                    self.logger.warning(f"Rate limited (429) on {url}. Retrying in {wait_time:.1f}s...")
                    time.sleep(wait_time)
                    continue
                elif resp.status_code in [401, 403]:
                    raise AuthenticationError(f"HTTP {resp.status_code} on {url}: Credentials required or rejected.")
                elif resp.status_code == 404:
                    raise ResourceNotFoundError(f"HTTP 404 on {url}: Resource not found.")
                elif resp.status_code >= 500:
                    wait_time = (2 ** attempt) + random.uniform(0.5, 1.5)
                    self.logger.warning(f"Server error ({resp.status_code}) on {url}. Retrying in {wait_time:.1f}s...")
                    time.sleep(wait_time)
                    continue
                else:
                    resp.raise_for_status()

            except (requests.exceptions.Timeout, requests.exceptions.ConnectionError) as e:
                if attempt == self.max_retries:
                    raise APIClientError(f"Connection failed after {self.max_retries} attempts: {e}")
                wait_time = (2 ** attempt) + random.uniform(0.5, 1.5)
                time.sleep(wait_time)

        raise APIClientError(f"Failed to GET {url} after {self.max_retries} retries.")

    def get_json(
        self,
        endpoint: str,
        params: Optional[Dict[str, Any]] = None,
        headers: Optional[Dict[str, str]] = None
    ) -> Any:
        resp = self.get(endpoint, params=params, headers=headers)
        try:
            return resp.json()
        except Exception as e:
            raise APIClientError(f"Invalid JSON returned from {endpoint}: {e}")

