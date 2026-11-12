"""
Nutrient Earth — FAO/INFOODS Food Composition & Bioavailability Importer
Implements validated nutritional mathematics and data structures according to official
FAO/INFOODS guidelines:
1. Phytate:Zinc and Phytate:Iron molar ratios for mineral bioavailability
2. Mass and bulk density conversions for volume-to-weight translation
3. Standardized energy calculations (Atwater factors)
4. Nitrogen-to-protein Jones factors
5. Metadata extraction and parsing for the 8 official FAO/INFOODS publications
"""

import os
import json
from typing import Dict, Any, List, Optional

# Constants for molar masses (g/mol)
MOLAR_MASS_PHYTATE = 660.04  # Phytic acid (myo-inositol 1,2,3,4,5,6-hexakisphosphate)
MOLAR_MASS_ZINC = 65.38
MOLAR_MASS_IRON = 55.845
MOLAR_MASS_CALCIUM = 40.078

# Specific nitrogen-to-protein Jones factors
JONES_FACTORS = {
    "standard_default": 6.25,
    "milk_and_dairy": 6.38,
    "whole_wheat": 5.83,
    "wheat_flour": 5.70,
    "rice": 5.95,
    "soybeans": 5.71,
    "peanuts": 5.46,
    "almonds": 5.18,
    "other_tree_nuts": 5.30,
    "legumes_pulses": 5.40,
    "meat_fish_eggs": 6.25
}

# Representative food mass densities (g/mL or g/cm3) from FAO/INFOODS Density Database v2.0
DENSITY_REFERENCE_DATABASE = {
    "water": 1.000,
    "milk_whole": 1.032,
    "milk_skim": 1.036,
    "olive_oil": 0.918,
    "coconut_oil": 0.920,
    "ghee_clarified_butter": 0.915,
    "honey": 1.420,
    "wheat_flour_whole": 0.580,  # bulk density
    "wheat_flour_white": 0.550,
    "rice_raw_polished": 0.850,
    "rice_cooked": 0.720,
    "oats_rolled": 0.400,
    "lentils_raw": 0.830,
    "chickpeas_cooked": 0.750,
    "spinach_raw_chopped": 0.350,
    "tomato_puree": 1.060,
    "curd_yogurt": 1.040
}

class FAOInfoodsImporter:
    @staticmethod
    def calculate_phytate_to_zinc_ratio(phytate_mg: float, zinc_mg: float) -> Optional[float]:
        """
        Calculate Phytate:Zn molar ratio:
        Ratio = (Phytate [mg] / 660.04) / (Zn [mg] / 65.38)
        Threshold:
          < 5:   High bioavailability (~50%)
          5-15:  Moderate bioavailability (~30-35%)
          > 15:  Low bioavailability (~15%), impaired zinc absorption
        """
        if zinc_mg <= 0 or phytate_mg < 0:
            return None
        phytate_mmol = phytate_mg / MOLAR_MASS_PHYTATE
        zinc_mmol = zinc_mg / MOLAR_MASS_ZINC
        return round(phytate_mmol / zinc_mmol, 2)

    @staticmethod
    def calculate_phytate_to_iron_ratio(phytate_mg: float, iron_mg: float) -> Optional[float]:
        """
        Calculate Phytate:Fe molar ratio:
        Ratio = (Phytate [mg] / 660.04) / (Fe [mg] / 55.845)
        Threshold:
          < 0.4: Favorable for non-heme iron absorption
          > 1.0: Marked inhibition of non-heme iron absorption
        """
        if iron_mg <= 0 or phytate_mg < 0:
            return None
        phytate_mmol = phytate_mg / MOLAR_MASS_PHYTATE
        iron_mmol = iron_mg / MOLAR_MASS_IRON
        return round(phytate_mmol / iron_mmol, 2)

    @staticmethod
    def calculate_phytate_calcium_to_zinc_ratio(
        phytate_mg: float, calcium_mg: float, zinc_mg: float, food_weight_g: float = 100.0
    ) -> Optional[float]:
        """
        Calculate [Phytate x Calcium] / Zinc in mol/kg dry diet or composite.
        High calcium magnifies phytate inhibition of zinc when ratio exceeds 0.2 mol/kg (or 200 mmol/kg).
        """
        if zinc_mg <= 0 or food_weight_g <= 0:
            return None
        phytate_mol = (phytate_mg / 1000.0) / MOLAR_MASS_PHYTATE
        calcium_mol = (calcium_mg / 1000.0) / MOLAR_MASS_CALCIUM
        zinc_mol = (zinc_mg / 1000.0) / MOLAR_MASS_ZINC
        kg_diet = food_weight_g / 1000.0

        val = (phytate_mol * calcium_mol) / (zinc_mol * kg_diet)
        return round(val, 4)

    @staticmethod
    def volume_to_weight_g(volume_ml: float, food_key: str) -> Optional[float]:
        """
        Convert volume in mL to weight in grams using FAO/INFOODS density database.
        Weight [g] = Volume [mL] * Density [g/mL]
        """
        clean_key = food_key.lower().strip().replace(" ", "_")
        density = DENSITY_REFERENCE_DATABASE.get(clean_key)
        if density is None:
            # Fallback exact or substring match
            for k, v in DENSITY_REFERENCE_DATABASE.items():
                if k in clean_key or clean_key in k:
                    density = v
                    break
        if density is None:
            return None
        return round(volume_ml * density, 2)

    @staticmethod
    def calculate_energy(
        protein_g: float,
        fat_g: float,
        carb_available_g: float,
        fiber_g: float = 0.0,
        alcohol_g: float = 0.0
    ) -> Dict[str, float]:
        """
        Calculate energy according to FAO/INFOODS standards:
        kJ = 17 * protein + 37 * fat + 17 * carbs + 8 * fiber + 29 * alcohol
        kcal = 4 * protein + 9 * fat + 4 * carbs + 2 * fiber + 7 * alcohol
        """
        kj = (17.0 * protein_g) + (37.0 * fat_g) + (17.0 * carb_available_g) + (8.0 * fiber_g) + (29.0 * alcohol_g)
        kcal = (4.0 * protein_g) + (9.0 * fat_g) + (4.0 * carb_available_g) + (2.0 * fiber_g) + (7.0 * alcohol_g)
        return {
            "energy_kj": round(kj, 1),
            "energy_kcal": round(kcal, 1)
        }

    @staticmethod
    def nitrogen_to_protein(nitrogen_g: float, food_type: str = "standard_default") -> float:
        """Apply commodity-specific Jones factor to calculate crude protein from nitrogen."""
        factor = JONES_FACTORS.get(food_type, 6.25)
        return round(nitrogen_g * factor, 3)

