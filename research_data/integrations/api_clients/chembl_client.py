"""
Nutrient Earth — ChEMBL Bioactive Molecules API Client
Searches EMBL-EBI ChEMBL for bioactive drug molecules, clinical phases,
and bioactivity data.
"""

from typing import Dict, Any, List, Optional
from .base_client import BaseAPIClient

class ChEMBLClient(BaseAPIClient):
    def __init__(self):
        super().__init__(
            base_url="https://www.ebi.ac.uk/chembl/api/data",
            rate_limit_delay_sec=0.3,
            timeout_sec=20.0
        )

    def search_molecules(self, query: str, limit: int = 5) -> List[Dict[str, Any]]:
        """Search ChEMBL molecules by name or synonym."""
        params = {
            "q": query,
            "limit": str(limit),
            "format": "json"
        }
        try:
            data = self.get_json("molecule/search.json", params=params)
            molecules = data.get("molecules", [])

            results = []
            for m in molecules:
                props = m.get("molecule_properties") or {}
                struct = m.get("molecule_structures") or {}

                results.append({
                    "chembl_id": m.get("molecule_chembl_id"),
                    "pref_name": m.get("pref_name") or query,
                    "max_phase": m.get("max_phase"),
                    "molecular_weight": float(props.get("full_mwt", 0.0)) if props.get("full_mwt") else None,
                    "smiles": struct.get("canonical_smiles"),
                    "inchikey": struct.get("standard_inchi_key"),
                    "url": f"https://www.ebi.ac.uk/chembl/compound_report_card/{m.get('molecule_chembl_id')}/"
                })
            return results
        except Exception as e:
            self.logger.warning(f"Error querying ChEMBL for {query}: {e}")
            return []

