"""
Nutrient Earth — Open Food Facts API Client
Retrieves packaged food data, ingredients, allergens, Nutri-Score, NOVA groups,
and macro breakdowns with proper ODbL licensing attribution.
"""

from typing import Dict, Any, List, Optional
from .base_client import BaseAPIClient

class OpenFoodFactsClient(BaseAPIClient):
    def __init__(self):
        super().__init__(
            base_url="https://world.openfoodfacts.org",
            rate_limit_delay_sec=0.5,
            timeout_sec=20.0,
            default_headers={
                "User-Agent": "NutrientEarth-FoodEngine/1.0 (Nutrition Verification; contact: contact@nutrientearth.com)"
            }
        )

    def search_products(self, query: str, page_size: int = 10) -> List[Dict[str, Any]]:
        """Search products by name or ingredient."""
        params = {
            "search_terms": query,
            "search_simple": "1",
            "action": "process",
            "json": "1",
            "page_size": str(page_size)
        }
        data = self.get_json("cgi/search.pl", params=params)
        products = data.get("products", [])

        normalized = []
        for p in products:
            code = p.get("code")
            nutriments = p.get("nutriments", {})

            normalized.append({
                "barcode": code,
                "product_name": p.get("product_name", ""),
                "brands": p.get("brands", ""),
                "categories": p.get("categories", ""),
                "ingredients_text": p.get("ingredients_text", ""),
                "allergens": p.get("allergens_tags", []),
                "nutriscore_grade": p.get("nutriscore_grade", "").upper(),
                "nova_group": p.get("nova_group"),
                "energy_kcal_100g": nutriments.get("energy-kcal_100g", 0.0),
                "proteins_100g": nutriments.get("proteins_100g", 0.0),
                "carbohydrates_100g": nutriments.get("carbohydrates_100g", 0.0),
                "fat_100g": nutriments.get("fat_100g", 0.0),
                "fiber_100g": nutriments.get("fiber_100g", 0.0),
                "image_url": p.get("image_front_url"),
                "license": "ODbL 1.0 (Open Database License)",
                "source_url": f"https://world.openfoodfacts.org/product/{code}"
            })
        return normalized

    def get_by_barcode(self, barcode: str) -> Optional[Dict[str, Any]]:
        """Fetch exact product details by barcode."""
        endpoint = f"api/v2/product/{barcode}.json"
        try:
            data = self.get_json(endpoint)
            if data.get("status") == 1:
                p = data.get("product", {})
                nutriments = p.get("nutriments", {})
                return {
                    "barcode": barcode,
                    "product_name": p.get("product_name"),
                    "brands": p.get("brands"),
                    "ingredients_text": p.get("ingredients_text"),
                    "allergens": p.get("allergens_tags", []),
                    "nutriscore_grade": p.get("nutriscore_grade", "").upper(),
                    "nova_group": p.get("nova_group"),
                    "energy_kcal_100g": nutriments.get("energy-kcal_100g", 0.0),
                    "proteins_100g": nutriments.get("proteins_100g", 0.0),
                    "carbohydrates_100g": nutriments.get("carbohydrates_100g", 0.0),
                    "fat_100g": nutriments.get("fat_100g", 0.0),
                    "image_url": p.get("image_front_url"),
                    "license": "ODbL 1.0"
                }
            return None
        except Exception as e:
            self.logger.warning(f"Error fetching barcode {barcode}: {e}")
            return None

