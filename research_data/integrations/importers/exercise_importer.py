"""
Exercise Record Normalization Pipeline
Normalizes Compendium of Physical Activities MET values into NutrientEarthExerciseRecord conforming to exercise_record.schema.json.
"""

from typing import Dict, Any

class ExerciseImporter:
    @staticmethod
    def normalize_activity(
        code: str,
        heading: str,
        activity_name: str,
        met_value: float,
        description: str = "",
        muscles: list = None
    ) -> Dict[str, Any]:
        # Determine intensity
        if met_value < 3.0:
            intensity = "light"
        elif met_value < 6.0:
            intensity = "moderate"
        else:
            intensity = "vigorous"

        return {
            "activity_id": f"act_pac_{code}",
            "source_id": "src_pacompendium",
            "code_number": str(code),
            "major_heading": heading,
            "specific_activity_description": description or activity_name,
            "activity_name": activity_name,
            "met_value": float(met_value),
            "intensity_level": intensity,
            "primary_muscles_engaged": muscles or ["Quadriceps", "Hamstrings", "Gluteals", "Cardiorespiratory system"],
            "joint_movements": ["Hip flexion/extension", "Knee flexion/extension", "Ankle dorsiflexion/plantarflexion"],
            "biomechanics_model_path": None,
            "provenance_reference": "Ainsworth BE et al. 2011/2024 Compendium of Physical Activities"
        }

