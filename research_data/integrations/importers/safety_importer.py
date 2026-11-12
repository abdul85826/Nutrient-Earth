"""
Safety Record Normalization Pipeline
Normalizes LiverTox drug/herb hepatotoxicity assessments into NutrientEarthSafetyRecord conforming to safety_record.schema.json.
"""

from typing import Dict, Any, List

class SafetyImporter:
    @staticmethod
    def normalize_livertox_record(
        agent_name: str,
        category_score: str,
        pattern: str = "Hepatocellular",
        latency: str = "1 to 8 weeks",
        mechanism: str = "Idiosyncratic or metabolic bioactivation",
        agent_type: str = "pharmaceutical"
    ) -> Dict[str, Any]:
        safety_id = f"saf_livertox_{agent_name.lower().replace(' ', '_').replace('/', '_')}"
        
        return {
            "safety_id": safety_id,
            "source_id": "src_livertox",
            "agent_name": agent_name,
            "agent_type": agent_type,
            "cas_number": None,
            "livertox_likelihood_score": category_score,
            "pattern_of_injury": pattern,
            "latency_period": latency,
            "clinical_presentation": f"Serum ALT/AST elevation, jaundice, or cholestatic symptoms associated with {agent_name}.",
            "mechanism_of_toxicity": mechanism,
            "recommended_monitoring": ["Baseline and periodic liver enzyme panel (ALT, AST, Total Bilirubin, ALP)"],
            "contraindications": [f"Pre-existing severe acute liver injury or known hypersensitivity to {agent_name}."],
            "food_safety_limits": {
                "mrl_ppm": None,
                "adi_mg_per_kg": None,
                "jurisdiction": "US_NIH_NIDDK"
            },
            "reference_links": [f"https://www.ncbi.nlm.nih.gov/books/NBK547852/"]
        }

