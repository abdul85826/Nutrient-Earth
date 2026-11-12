"""
Nutrient Earth — AYUSH Research Automated Acquisition Pipeline Data Models
Structured representations for raw items, normalized records, and manifest outputs.
"""

from dataclasses import dataclass, field, asdict
from typing import List, Dict, Optional, Any
import hashlib
import re

@dataclass
class AyushRecord:
    # Portal Identifiers
    id: int
    arp_id: str
    artid: str = ""
    medical_system: str = "AYURVEDA"
    
    # Bibliographic Metadata
    title: str = ""
    normalized_title: str = ""
    authors: str = ""
    affiliations: str = ""
    journal: str = ""
    year: str = ""
    publication_year: Optional[int] = None
    volume: str = ""
    issue: str = ""
    pages: str = ""
    
    # Classification & Evidence
    category: str = ""
    sub_category: str = ""
    body_system: str = ""
    disease: str = ""
    study_design: str = "unspecified"
    evidence_grade: str = "Evidence Synthesis"
    
    # Identifiers & Web Sources
    doi: str = ""
    pmid: str = ""
    original_url: str = ""
    portal_landing_url: str = ""
    
    # Clinical Content
    abstract: str = ""
    keywords: List[str] = field(default_factory=list)
    
    # Categorization & Scoring
    primary_topic_domain: str = ""
    matched_queries: List[str] = field(default_factory=list)
    relevance_score: float = 0.0
    rank: int = 0
    
    # Full-Text & PDF Management
    pdf_status: str = "pending"  # 'downloaded', 'abstract_only', 'restricted', 'unavailable'
    pdf_source: str = ""         # 'portal_record_pdf', 'open_access_fulltext', 'none'
    pdf_filename: str = ""
    pdf_sha256: str = ""
    pdf_size_bytes: int = 0
    extracted_text_path: str = ""
    extracted_char_count: int = 0
    access_restriction_reason: str = ""
    
    # Provenance & Licensing
    licence_attribution: str = "Ministry of Ayush, Government of India — Ayush Research Portal (https://arp.ayush.gov.in)"
    source_attribution: str = "Data acquired via official Ayush Research Portal discovery endpoints."

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> "AyushRecord":
        return cls(**{k: v for k, v in data.items() if k in cls.__annotations__})

    @property
    def deduplication_key_doi(self) -> Optional[str]:
        if self.doi and self.doi.lower() not in ("no", "ni", "na", "-", "none", ""):
            # Clean DOI
            clean = re.sub(r"^(https?://(dx\.)?doi\.org/|doi:)", "", self.doi.strip(), flags=re.I)
            return clean.strip().lower()
        return None

    @property
    def deduplication_key_title_year(self) -> str:
        t = self.normalized_title or normalize_title(self.title)
        y = self.year or "0"
        return f"{t}::{y}"


def normalize_title(title: str) -> str:
    """Normalize paper title for robust deduplication."""
    if not title:
        return ""
    # Lowercase
    t = title.lower()
    # Remove HTML entities and tags
    t = re.sub(r"<[^>]+>", " ", t)
    # Remove non-alphanumeric characters except space
    t = re.sub(r"[^\w\s]", " ", t)
    # Collapse multiple whitespaces
    t = " ".join(t.split())
    return t.strip()


def calculate_sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()

