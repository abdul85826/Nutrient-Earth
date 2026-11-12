"""
RxNorm / RxNav REST API Client
Connects to https://rxnav.nlm.nih.gov/REST/
Resolves clinical drug concepts, RxCUIs, active ingredient hierarchies, and dosage forms.
"""

from typing import Dict, Any, List, Optional
from .base_client import BaseAPIClient

class RxNormClient(BaseAPIClient):
    def __init__(self, rate_limit_delay_sec: float = 0.2):
        super().__init__(
            base_url="https://rxnav.nlm.nih.gov/REST",
            rate_limit_delay_sec=rate_limit_delay_sec,
            timeout_sec=12.0
        )

    def find_rxcui_by_name(self, name: str) -> Optional[str]:
        """Find the primary RxCUI concept identifier for a drug name."""
        data = self.get_json("/rxcui.json", params={"name": name})
        id_group = data.get("idGroup", {})
        rxnorm_ids = id_group.get("rxnormId", [])
        return rxnorm_ids[0] if rxnorm_ids else None

    def get_rxcui_properties(self, rxcui: str) -> Dict[str, Any]:
        """Fetch standardized properties (name, synonym, TTY) for an RxCUI."""
        endpoint = f"/rxcui/{rxcui}/properties.json"
        return self.get_json(endpoint)

    def get_all_related_concepts(self, rxcui: str) -> Dict[str, Any]:
        """Fetch ingredients, branded forms, and clinical drug components related to an RxCUI."""
        endpoint = f"/rxcui/{rxcui}/allrelated.json"
        return self.get_json(endpoint)

    def get_drugs_by_name(self, name: str) -> Dict[str, Any]:
        """Fetch clinical drug representations (ingredient + strength + dose form)."""
        return self.get_json("/drugs.json", params={"name": name})

