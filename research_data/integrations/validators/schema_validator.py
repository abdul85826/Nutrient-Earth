"""
Schema Validator for Nutrient Earth
Validates normalized records against JSON Schemas in research_data/schemas/
"""

import os
import json
from typing import Dict, Any, Tuple, List

SCHEMAS_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "schemas"))

class SchemaValidator:
    _loaded_schemas = {}

    @classmethod
    def load_schema(cls, schema_name: str) -> Dict[str, Any]:
        if schema_name not in cls._loaded_schemas:
            path = os.path.join(SCHEMAS_DIR, schema_name)
            if not os.path.exists(path):
                raise FileNotFoundError(f"Schema file not found: {path}")
            with open(path, "r", encoding="utf-8") as f:
                cls._loaded_schemas[schema_name] = json.load(f)
        return cls._loaded_schemas[schema_name]

    @classmethod
    def validate_record(cls, record: Dict[str, Any], schema_name: str) -> Tuple[bool, List[str]]:
        schema = cls.load_schema(schema_name)
        errors = []

        # 1. Validate required fields
        required_fields = schema.get("required", [])
        for field in required_fields:
            if field not in record or record[field] is None:
                errors.append(f"Missing required field: '{field}'")

        # 2. Validate types and enums for defined properties
        props = schema.get("properties", {})
        for k, v in record.items():
            if k in props:
                prop_spec = props[k]
                allowed_types = prop_spec.get("type")
                if isinstance(allowed_types, str):
                    allowed_types = [allowed_types]

                if v is not None and allowed_types:
                    # Check type match
                    type_ok = False
                    for t in allowed_types:
                        if t == "string" and isinstance(v, str):
                            type_ok = True
                        elif t == "integer" and isinstance(v, int) and not isinstance(v, bool):
                            type_ok = True
                        elif t == "number" and (isinstance(v, (int, float)) and not isinstance(v, bool)):
                            type_ok = True
                        elif t == "boolean" and isinstance(v, bool):
                            type_ok = True
                        elif t == "array" and isinstance(v, list):
                            type_ok = True
                        elif t == "object" and isinstance(v, dict):
                            type_ok = True
                        elif t == "null" and v is None:
                            type_ok = True
                    if not type_ok:
                        errors.append(f"Field '{k}' has invalid type '{type(v).__name__}', expected one of {allowed_types}")

                # Check enums
                if "enum" in prop_spec and v is not None:
                    if v not in prop_spec["enum"]:
                        errors.append(f"Field '{k}' has value '{v}' which is not in permitted enum {prop_spec['enum']}")

        return (len(errors) == 0, errors)

