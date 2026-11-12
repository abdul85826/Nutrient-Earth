"""
Nutrient Record Normalization Pipeline
Normalizes vitamins, minerals, RDAs, and Upper Tolerable Intake Levels (UL)
into NutrientEarthNutrientRecord conforming to nutrient_record.schema.json.
"""

from typing import Dict, Any, List

class NutrientsImporter:
    @staticmethod
    def normalize_nutrient_record(raw: Dict[str, Any]) -> Dict[str, Any]:
        return {
            "nutrient_id": raw["nutrient_id"],
            "nutrient_name": raw["nutrient_name"],
            "category": raw["category"],
            "chemical_forms": raw.get("chemical_forms", []),
            "unit": raw["unit"],
            "physiological_functions": raw.get("physiological_functions", []),
            "reference_intakes": raw["reference_intakes"],
            "deficiency_symptoms": raw.get("deficiency_symptoms", []),
            "toxicity_symptoms": raw.get("toxicity_symptoms", []),
            "dietary_food_sources": raw.get("dietary_food_sources", []),
            "interactions": raw.get("interactions", {
                "synergists": [],
                "antagonists": [],
                "drug_interactions": []
            }),
            "jurisdiction": raw.get("jurisdiction", "US_NIH_ODS"),
            "effective_date": raw.get("effective_date", "2024-01-01"),
            "evidence_source": raw.get("evidence_source", "NIH Office of Dietary Supplements Dietary Reference Intakes")
        }

