"""
Nutrient Earth — USDA FoodData Central (FDC) API Client
Connects to USDA FDC REST API for official food composition, macro/micronutrient profiles,
and serving size calibrations using the official API key.
"""

import os
from typing import Dict, Any, List, Optional
from .base_client import BaseAPIClient

class USDAFoodDataCentralClient(BaseAPIClient):
    def __init__(self, api_key: Optional[str] = None):
        super().__init__(
            base_url="https://api.nal.usda.gov/fdc/v1",
            rate_limit_delay_sec=0.25,
            timeout_sec=20.0
        )
        self.api_key = api_key or os.getenv("FDC_API_KEY", "dhK8Ngpm9mMtrjHNFjRpcKHCCLDzdMrTwhQrNDkF")

    def search_foods(
        self,
        query: str,
        page_size: int = 10,
        data_type: Optional[List[str]] = None
    ) -> List[Dict[str, Any]]:
        """Search foods in USDA FoodData Central."""
        params = {
            "api_key": self.api_key,
            "query": query,
            "pageSize": str(page_size)
        }
        if data_type:
            params["dataType"] = ",".join(data_type)

        data = self.get_json("foods/search", params=params)
        foods = data.get("foods", [])

        normalized = []
        for f in foods:
            fdc_id = f.get("fdcId")
            description = f.get("description", "")
            category = f.get("foodCategory", "")
            serving_size = f.get("servingSize", 100.0)
            serving_unit = f.get("servingSizeUnit", "g")

            nutrients = {}
            for n in f.get("foodNutrients", []):
                n_name = n.get("nutrientName", "")
                n_val = n.get("value", 0.0)
                n_unit = n.get("unitName", "").lower()

                # Clean macro mapping
                if "Energy" in n_name and ("KCAL" in n_unit.upper() or "kcal" in n_name.lower()):
                    nutrients["energy_kcal"] = n_val
                elif "Protein" in n_name:
                    nutrients["protein_g"] = n_val
                elif "Total lipid (fat)" in n_name:
                    nutrients["total_fat_g"] = n_val
                elif "Carbohydrate, by difference" in n_name:
                    nutrients["carbohydrate_g"] = n_val
                elif "Fiber, total dietary" in n_name:
                    nutrients["dietary_fiber_g"] = n_val
                elif "Calcium" in n_name:
                    nutrients["calcium_mg"] = n_val
                elif "Iron" in n_name:
                    nutrients["iron_mg"] = n_val
                elif "Zinc" in n_name:
                    nutrients["zinc_mg"] = n_val
                elif "Magnesium" in n_name:
                    nutrients["magnesium_mg"] = n_val
                elif "Potassium" in n_name:
                    nutrients["potassium_mg"] = n_val
                elif "Vitamin C" in n_name:
                    nutrients["vitamin_c_mg"] = n_val
                elif "Vitamin D" in n_name:
                    nutrients["vitamin_d_ug"] = n_val

            normalized.append({
                "fdc_id": fdc_id,
                "food_name": description,
                "food_category": category,
                "data_type": f.get("dataType"),
                "serving_size_g": serving_size,
                "serving_size_unit": serving_unit,
                "energy_kcal": nutrients.get("energy_kcal", 0.0),
                "protein_g": nutrients.get("protein_g", 0.0),
                "carbohydrate_g": nutrients.get("carbohydrate_g", 0.0),
                "total_fat_g": nutrients.get("total_fat_g", 0.0),
                "dietary_fiber_g": nutrients.get("dietary_fiber_g", 0.0),
                "micronutrients": nutrients,
                "publication_date": f.get("publicationDate"),
                "source_url": f"https://fdc.nal.usda.gov/fdc-app.html#/food-details/{fdc_id}/nutrients"
            })
        return normalized

    def get_food_details(self, fdc_id: int) -> Dict[str, Any]:
        """Fetch complete nutritional breakdown for a specific FDC ID."""
        params = {"api_key": self.api_key}
        return self.get_json(f"food/{fdc_id}", params=params)

