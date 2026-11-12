"""
Nutrient Earth — PubChem PUG REST API Client
Fetches chemical structures, molecular formulas, weights, canonical SMILES,
and InChIKeys for compounds from NCBI PubChem.
"""

from typing import Dict, Any, List, Optional
from .base_client import BaseAPIClient

class PubChemClient(BaseAPIClient):
    def __init__(self):
        super().__init__(
            base_url="https://pubchem.ncbi.nlm.nih.gov/rest/pug",
            rate_limit_delay_sec=0.25,
            timeout_sec=20.0
        )

    def get_compound_properties(self, compound_name: str) -> Optional[Dict[str, Any]]:
        """Retrieve standard chemical properties by compound name."""
        props = "Title,MolecularFormula,MolecularWeight,IUPACName,InChIKey,CanonicalSMILES"
        endpoint = f"compound/name/{compound_name}/property/{props}/JSON"

        try:
            data = self.get_json(endpoint)
            prop_table = data.get("PropertyTable", {}).get("Properties", [])
            if not prop_table:
                return None
            p = prop_table[0]

            return {
                "cid": p.get("CID"),
                "name": p.get("Title") or compound_name,
                "formula": p.get("MolecularFormula"),
                "molecular_weight": float(p.get("MolecularWeight", 0.0)),
                "iupac_name": p.get("IUPACName"),
                "inchikey": p.get("InChIKey"),
                "smiles": p.get("CanonicalSMILES"),
                "pubchem_url": f"https://pubchem.ncbi.nlm.nih.gov/compound/{p.get('CID')}"
            }
        except Exception as e:
            self.logger.warning(f"Error fetching PubChem data for {compound_name}: {e}")
            return None

    def get_by_cid(self, cid: int) -> Optional[Dict[str, Any]]:
        """Retrieve properties by PubChem CID."""
        props = "Title,MolecularFormula,MolecularWeight,IUPACName,InChIKey,CanonicalSMILES"
        endpoint = f"compound/cid/{cid}/property/{props}/JSON"
        try:
            data = self.get_json(endpoint)
            prop_table = data.get("PropertyTable", {}).get("Properties", [])
            if not prop_table:
                return None
            p = prop_table[0]
            return {
                "cid": cid,
                "name": p.get("Title"),
                "formula": p.get("MolecularFormula"),
                "molecular_weight": float(p.get("MolecularWeight", 0.0)),
                "iupac_name": p.get("IUPACName"),
                "inchikey": p.get("InChIKey"),
                "smiles": p.get("CanonicalSMILES"),
                "pubchem_url": f"https://pubchem.ncbi.nlm.nih.gov/compound/{cid}"
            }
        except Exception as e:
            self.logger.warning(f"Error fetching PubChem CID {cid}: {e}")
            return None

