"""
Herb Record Normalization Pipeline
Normalizes medicinal plant profiles, botanical nomenclature, traditional Ayurvedic properties,
and safety considerations into NutrientEarthHerbRecord conforming to herb_record.schema.json.
"""

from typing import Dict, Any, List

class HerbsImporter:
    @staticmethod
    def normalize_botanical_record(raw: Dict[str, Any]) -> Dict[str, Any]:
        herb_id = raw.get("herb_id") or f"herb_{raw.get('botanical_name', '').lower().replace(' ', '_')}"
        
        return {
            "herb_id": herb_id,
            "accepted_botanical_name": raw.get("botanical_name", "").strip(),
            "botanical_synonyms": raw.get("synonyms", []),
            "common_names": {
                "sanskrit": raw.get("sanskrit_names", []),
                "hindi": raw.get("hindi_names", []),
                "english": raw.get("english_names", []),
                "tamil": raw.get("tamil_names", []),
                "arabic_unani": raw.get("unani_names", [])
            },
            "plant_family": raw.get("family", "Unknown"),
            "plant_parts_used": raw.get("parts_used", []),
            "traditional_systems": raw.get("traditional_systems", ["Ayurveda"]),
            "traditional_properties": {
                "rasa": raw.get("rasa", []),
                "guna": raw.get("guna", []),
                "virya": raw.get("virya", ""),
                "vipaka": raw.get("vipaka", ""),
                "dosha_effects": raw.get("dosha_effects", {
                    "vata": "pacifies",
                    "pitta": "neutral",
                    "kapha": "pacifies"
                })
            },
            "traditional_uses": raw.get("traditional_uses", []),
            "documented_preparations": raw.get("preparations", ["Churna", "Kwatha", "Standardized Extract"]),
            "active_phytochemicals": raw.get("phytochemicals", []),
            "mechanisms_of_action": raw.get("mechanisms", []),
            "toxicity_and_safety": {
                "safety_class": raw.get("safety_class", "Generally Recognized as Safe with traditional dosage"),
                "contraindications": raw.get("contraindications", []),
                "adverse_effects": raw.get("adverse_effects", []),
                "herb_drug_interactions": raw.get("interactions", []),
                "pregnancy_lactation_safety": raw.get("pregnancy_safety", "Consult qualified healthcare professional")
            },
            "geographic_distribution": raw.get("distribution", ["India", "Subtropical Asia"]),
            "conservation_status": raw.get("conservation_status", "Least Concern (LC)"),
            "source_references": raw.get("references", []),
            "license": "Government Open Data / Public Domain (Attribution required)"
        }

