"""
Nutrient Earth — AYUSH Research Automated Acquisition Pipeline Configuration
Defines endpoints, topic categories, rate limits, scoring weights, and storage paths.
"""

import os
from pathlib import Path

# Base Paths
PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
DATA_DIR = PROJECT_ROOT / "data" / "ayush"
PDFS_RAW_DIR = DATA_DIR / "pdfs" / "raw"
EXTRACTED_TEXT_DIR = DATA_DIR / "extracted_text"
EXPORTS_DIR = DATA_DIR / "exports"
CHECKPOINTS_DIR = DATA_DIR / "checkpoints"
LOGS_DIR = DATA_DIR / "logs"

# Ensure all runtime directories exist
for directory in [DATA_DIR, PDFS_RAW_DIR, EXTRACTED_TEXT_DIR, EXPORTS_DIR, CHECKPOINTS_DIR, LOGS_DIR]:
    directory.mkdir(parents=True, exist_ok=True)

# Portal Endpoints
PORTAL_BASE_URL = "https://arp.ayush.gov.in/arp"
SEARCH_PAGE_URL = f"{PORTAL_BASE_URL}/research_advance_search"
FILTER_SEARCH_DATA_URL = f"{PORTAL_BASE_URL}/getFilter_Search_data"
FILTER_SEARCH_COUNT_URL = f"{PORTAL_BASE_URL}/getFilter_Search_dataCount"
LANDING_PAGE_URL = f"{PORTAL_BASE_URL}/View_Res_Landing_Url"
PDF_DOWNLOAD_URL = f"{PORTAL_BASE_URL}/View_Research_PDF"

# HTTP Client Settings
USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 (Nutrient Earth Scientific Research Crawler; +https://www.nutrientearth.win)"
REQUEST_TIMEOUT_SECONDS = 20
RATE_LIMIT_DELAY_SECONDS = 0.25  # Respectful delay between successive requests
RATE_LIMIT_JITTER_SECONDS = 0.10
MAX_RETRIES = 4
BACKOFF_FACTOR = 1.5

# 8 Required Topic Domains with Targeted Queries
TOPIC_DOMAINS = {
    "ayurveda_nutrition": {
        "title": "Ayurveda and Nutrition",
        "queries": ["nutrition", "malnutrition", "nutritional", "nutraceutical"],
        "target_quota": 100,
        "keywords": ["nutrition", "diet", "malnutrition", "ahara", "rasayana", "poshana", "nutrient", "nourishment", "food"]
    },
    "medicinal_plants_phytochemistry": {
        "title": "Medicinal Plants and Phytochemistry",
        "queries": ["medicinal plants", "phytochemistry", "phytochemical", "botanical"],
        "target_quota": 100,
        "keywords": ["plant", "extract", "phytochemical", "phytochemistry", "flavonoid", "alkaloid", "herb", "botanical", "chromatography"]
    },
    "diabetes_obesity_metabolic": {
        "title": "Diabetes, Obesity and Metabolic Health",
        "queries": ["diabetes", "obesity", "metabolic", "prameha", "medoroga"],
        "target_quota": 100,
        "keywords": ["diabetes", "diabetic", "glucose", "insulin", "obesity", "metabolic", "prameha", "lipid", "cholesterol", "weight"]
    },
    "prakriti_biomarkers": {
        "title": "Prakriti and Biomarkers",
        "queries": ["prakriti", "biomarker", "genomics", "phenotype"],
        "target_quota": 100,
        "keywords": ["prakriti", "dosha", "vata", "pitta", "kapha", "biomarker", "phenotype", "genomic", "constitution", "polymorphism"]
    },
    "digestion_gut_health": {
        "title": "Digestion and Gut Health",
        "queries": ["digestion", "gastrointestinal", "gut", "grahani", "agni"],
        "target_quota": 100,
        "keywords": ["digestion", "digestive", "gut", "microbiome", "gastrointestinal", "grahani", "agni", "bowel", "gastric", "ulcer", "ibs"]
    },
    "herb_safety_interactions": {
        "title": "Herb Safety and Interactions",
        "queries": ["safety", "toxicity", "adverse", "heavy metal", "interaction"],
        "target_quota": 100,
        "keywords": ["safety", "toxic", "toxicity", "adverse", "side effect", "heavy metal", "contraindication", "interaction", "standardization"]
    },
    "traditional_diets_food": {
        "title": "Traditional Diets and Food",
        "queries": ["diet", "food", "ahara", "pathya", "fermented"],
        "target_quota": 100,
        "keywords": ["diet", "dietary", "food", "ahara", "pathya", "recipe", "culinary", "cereal", "millet", "spices", "ghee", "honey"]
    },
    "clinical_trials_reviews": {
        "title": "Clinical Trials and Systematic Reviews",
        "queries": ["clinical trial", "systematic review", "randomized", "meta-analysis"],
        "target_quota": 100,
        "keywords": ["clinical trial", "randomized", "controlled trial", "systematic review", "meta-analysis", "rct", "efficacy", "double-blind"]
    }
}

TOTAL_TARGET_RECORDS = 800

# Scoring Weights
WEIGHTS = {
    "topic_keyword_match": 25.0,
    "clinical_evidence_grade": 30.0,
    "abstract_completeness": 20.0,
    "metadata_richness": 15.0,
    "recency": 10.0
}
