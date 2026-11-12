"""
Nutrient Earth — Deduplication Engine
Deduplicates records using canonical DOI, ARP ID, and normalized title + publication year.
Merges query occurrences, keywords, and preserves the richest metadata set.
"""

from typing import List, Dict, Tuple, Set, Optional
from .models import AyushRecord, normalize_title

class Deduplicator:
    def __init__(self):
        self.by_doi: Dict[str, AyushRecord] = {}
        self.by_arp_id: Dict[str, AyushRecord] = {}
        self.by_title_year: Dict[str, AyushRecord] = {}
        self.duplicates_merged_count: int = 0
        self.deduplicated_records: List[AyushRecord] = []

    def add_record(self, record: AyushRecord) -> Tuple[AyushRecord, bool]:
        """
        Attempts to add record. If duplicate is found, merges into existing record.
        Returns (canonical_record, is_new).
        """
        existing: Optional[AyushRecord] = None
        
        # 1. Check DOI if valid
        doi_key = record.deduplication_key_doi
        if doi_key and doi_key in self.by_doi:
            existing = self.by_doi[doi_key]

        # 2. Check ARP ID if not yet matched
        if not existing and record.arp_id and record.arp_id in self.by_arp_id:
            existing = self.by_arp_id[record.arp_id]

        # 3. Check Normalized Title + Year
        if not existing and record.deduplication_key_title_year in self.by_title_year:
            existing = self.by_title_year[record.deduplication_key_title_year]

        # 4. Check Normalized Title alone if year is missing
        if not existing and record.normalized_title:
            clean_title = record.normalized_title
            for k, rec in self.by_title_year.items():
                existing_title = k.split("::")[0]
                if existing_title == clean_title and len(clean_title) > 15:
                    existing = rec
                    break

        if existing:
            # Merge information into existing record
            self._merge_records(existing, record)
            self.duplicates_merged_count += 1
            return existing, False
        else:
            # Register new record
            if doi_key:
                self.by_doi[doi_key] = record
            if record.arp_id:
                self.by_arp_id[record.arp_id] = record
            if record.deduplication_key_title_year:
                self.by_title_year[record.deduplication_key_title_year] = record
            self.deduplicated_records.append(record)
            return record, True

    def _merge_records(self, primary: AyushRecord, secondary: AyushRecord):
        """Merges secondary into primary, keeping the most complete fields."""
        # Merge matched queries
        for q in secondary.matched_queries:
            if q not in primary.matched_queries:
                primary.matched_queries.append(q)

        # Merge keywords
        for kw in secondary.keywords:
            if kw not in primary.keywords:
                primary.keywords.append(kw)

        # Prefer non-empty fields
        if not primary.abstract and secondary.abstract:
            primary.abstract = secondary.abstract
        elif len(secondary.abstract) > len(primary.abstract):
            primary.abstract = secondary.abstract

        if not primary.authors and secondary.authors:
            primary.authors = secondary.authors
        if not primary.affiliations and secondary.affiliations:
            primary.affiliations = secondary.affiliations
        if not primary.journal and secondary.journal:
            primary.journal = secondary.journal
        if not primary.doi and secondary.doi:
            primary.doi = secondary.doi
        if not primary.pmid and secondary.pmid:
            primary.pmid = secondary.pmid
        if not primary.original_url and secondary.original_url:
            primary.original_url = secondary.original_url

    def process_records(self, records: List[AyushRecord]) -> List[AyushRecord]:
        """Bulk deduplicates a list of records."""
        for r in records:
            self.add_record(r)
        return self.deduplicated_records

