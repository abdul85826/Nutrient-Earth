"""
Environmental Record Normalization Pipeline
Normalizes weather, air quality observations, and OSM health amenities
into NutrientEarthEnvironmentalRecord conforming to environmental_record.schema.json.
"""

from typing import Dict, Any

class EnvironmentalImporter:
    @staticmethod
    def normalize_weather_observation(
        source_id: str,
        lat: float,
        lon: float,
        temp_c: float,
        humidity_pct: float,
        precip_mm: float,
        timestamp: str,
        city: str = None
    ) -> Dict[str, Any]:
        record_id = f"env_{source_id}_{int(lat*100)}_{int(lon*100)}_{timestamp[:10]}"
        return {
            "record_id": record_id,
            "source_id": source_id,
            "record_type": "weather_observation",
            "location": {
                "latitude": float(lat),
                "longitude": float(lon),
                "city": city,
                "state_or_province": None,
                "country": None
            },
            "timestamp_or_date": timestamp,
            "air_quality_metrics": None,
            "weather_metrics": {
                "temperature_celsius": float(temp_c),
                "relative_humidity_pct": float(humidity_pct),
                "precipitation_mm": float(precip_mm),
                "solar_irradiance_wm2": None
            },
            "amenity_details": None,
            "conservation_details": None
        }

    @staticmethod
    def normalize_osm_amenity(raw_poi: Dict[str, Any]) -> Dict[str, Any]:
        osm_id = str(raw_poi.get("place_id") or raw_poi.get("osm_id", "unknown"))
        lat = float(raw_poi.get("lat", 0.0))
        lon = float(raw_poi.get("lon", 0.0))
        display_name = raw_poi.get("display_name", "")
        amenity_type = raw_poi.get("type", "health_facility")

        return {
            "record_id": f"env_osm_{osm_id}",
            "source_id": "src_openstreetmap",
            "record_type": "geographic_amenity",
            "location": {
                "latitude": lat,
                "longitude": lon,
                "city": raw_poi.get("address", {}).get("city") or raw_poi.get("address", {}).get("town"),
                "state_or_province": raw_poi.get("address", {}).get("state"),
                "country": raw_poi.get("address", {}).get("country")
            },
            "timestamp_or_date": "2026-11-11",
            "air_quality_metrics": None,
            "weather_metrics": None,
            "amenity_details": {
                "amenity_type": amenity_type,
                "name": raw_poi.get("name") or display_name.split(",")[0],
                "address": display_name
            },
            "conservation_details": None
        }

