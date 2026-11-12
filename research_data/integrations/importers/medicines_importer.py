"""
Medicine Record Normalization Pipeline
Normalizes DailyMed SPL and RxNorm concept data into NutrientEarthMedicineRecord conforming to medicine_record.schema.json.
"""

from typing import Dict, Any, List

class MedicinesImporter:
    @staticmethod
    def normalize_dailymed_spl(spl_raw: Dict[str, Any], rxcui: str = None) -> Dict[str, Any]:
        setid = spl_raw.get("setid") or spl_raw.get("spl_setid", "unknown")
        title = spl_raw.get("title", "")
        
        # Extract generic name from title
        generic_name = title.split("(")[0].strip() if "(" in title else title.strip()
        
        return {
            "medicine_id": f"med_dailymed_{setid[:12]}",
            "source_id": "src_dailymed",
            "generic_name": generic_name,
            "brand_names": [title] if title else [],
            "rxcui": rxcui,
            "spl_set_id": setid,
            "active_ingredients": [
                {
                    "name": generic_name,
                    "strength": None,
                    "rxcui": rxcui
                }
            ],
            "dosage_forms": [spl_raw.get("dosage_form", "oral tablet")],
            "routes_of_administration": ["oral"],
            "pharmacological_class": [],
            "boxed_warnings": [],
            "contraindications": [],
            "adverse_reactions": [],
            "drug_interactions": [],
            "food_and_herb_interactions": [],
            "label_source_url": f"https://dailymed.nlm.nih.gov/dailymed/lookup.cfm?setid={setid}",
            "effective_date": spl_raw.get("published_date")
        }

