"""
Nutrient Earth — Acquisition Engine
Executes rate-limited, retriable searches across the 8 required topic domains,
paginates through result sets, and fetches detailed landing pages.
"""

import time
import json
import random
import requests
from typing import List, Dict, Any, Optional
from pathlib import Path

from .models import AyushRecord
from .config import (
    PORTAL_BASE_URL,
    SEARCH_PAGE_URL,
    FILTER_SEARCH_DATA_URL,
    FILTER_SEARCH_COUNT_URL,
    LANDING_PAGE_URL,
    TOPIC_DOMAINS,
    USER_AGENT,
    REQUEST_TIMEOUT_SECONDS,
    RATE_LIMIT_DELAY_SECONDS,
    RATE_LIMIT_JITTER_SECONDS,
    MAX_RETRIES,
    BACKOFF_FACTOR,
    CHECKPOINTS_DIR
)
from .normalization import parse_search_row, enrich_record_from_landing_html
from .deduplication import Deduplicator

class AcquisitionEngine:
    def __init__(self, session: Optional[requests.Session] = None):
        self.session = session or requests.Session()
        self.session.headers.update({
            "User-Agent": USER_AGENT,
            "Referer": SEARCH_PAGE_URL,
            "X-Requested-With": "XMLHttpRequest",
            "Origin": "https://arp.ayush.gov.in"
        })
        self.raw_checkpoint_file = CHECKPOINTS_DIR / "raw_candidates_checkpoint.json"
        self.enriched_checkpoint_file = CHECKPOINTS_DIR / "enriched_checkpoint.json"

    def initialize_session(self) -> bool:
        """Visits search page to establish session cookies and verify connectivity."""
        try:
            resp = self.session.get(SEARCH_PAGE_URL, timeout=REQUEST_TIMEOUT_SECONDS)
            if resp.status_code == 200:
                print(f"[Acquisition] Established session with AYUSH portal (status={resp.status_code})")
                return True
            else:
                print(f"[Acquisition] Session initialization failed (status={resp.status_code})")
                return False
        except Exception as e:
            print(f"[Acquisition] Session initialization error: {e}")
            return False

    def query_topic_candidates(self, max_per_domain: int = 150) -> List[AyushRecord]:
        """
        Executes search queries across all 8 topic categories and aggregates candidate records.
        Uses checkpointing to avoid re-querying on restarts.
        """
        if self.raw_checkpoint_file.exists():
            try:
                with open(self.raw_checkpoint_file, "r", encoding="utf-8") as f:
                    cached = json.load(f)
                    records = [AyushRecord.from_dict(d) for d in cached]
                    print(f"[Acquisition] Loaded {len(records)} raw candidates from checkpoint: {self.raw_checkpoint_file}")
                    return records
            except Exception as e:
                print(f"[Acquisition] Failed to load checkpoint: {e}")

        deduplicator = Deduplicator()
        page_size = 50

        print(f"\n[Acquisition] Beginning acquisition across {len(TOPIC_DOMAINS)} topic domains...")

        for domain_key, domain_info in TOPIC_DOMAINS.items():
            domain_title = domain_info["title"]
            queries = domain_info["queries"]
            collected_for_domain = 0
            print(f"\n---> Domain: {domain_title} (Target: {domain_info['target_quota']})")

            for query in queries:
                if collected_for_domain >= max_per_domain:
                    break

                # First get total count
                total_available = self._fetch_query_count(query)
                print(f"  Searching '{query}' -> Total portal records: {total_available}")

                start_page = 0
                while start_page < total_available and collected_for_domain < max_per_domain:
                    rows, err = self._fetch_search_page(query, start_page=start_page, page_length=page_size)
                    if not rows:
                        break

                    for row in rows:
                        record = parse_search_row(row, query=query, domain_key=domain_key)
                        _, is_new = deduplicator.add_record(record)
                        if is_new:
                            collected_for_domain += 1
                        if collected_for_domain >= max_per_domain:
                            break

                    start_page += page_size
                    time.sleep(RATE_LIMIT_DELAY_SECONDS + random.uniform(0, RATE_LIMIT_JITTER_SECONDS))

            print(f"  Collected {collected_for_domain} unique candidates for {domain_title}")

        records = deduplicator.deduplicated_records
        print(f"\n[Acquisition] Total deduplicated candidate pool: {len(records)} records")

        # Save checkpoint
        try:
            with open(self.raw_checkpoint_file, "w", encoding="utf-8") as f:
                json.dump([r.to_dict() for r in records], f, indent=2)
            print(f"[Acquisition] Saved raw candidates checkpoint ({len(records)} records)")
        except Exception as e:
            print(f"[Acquisition] Warning: failed to save raw checkpoint: {e}")

        return records

    def _fetch_query_count(self, query: str) -> int:
        """Queries count endpoint for a search keyword."""
        payload = {
            "Search": query,
            "arp_id": "0",
            "artid": "0",
            "system_id": "0",
            "app_status": "1",
            "category": "0",
            "keyword_string": "",
            "jsonData": ""
        }
        for attempt in range(1, MAX_RETRIES + 1):
            try:
                resp = self.session.post(FILTER_SEARCH_COUNT_URL, data=payload, timeout=REQUEST_TIMEOUT_SECONDS)
                if resp.status_code == 200:
                    text = resp.text.strip()
                    return int(text) if text.isdigit() else 0
                time.sleep(BACKOFF_FACTOR ** attempt)
            except Exception:
                time.sleep(BACKOFF_FACTOR ** attempt)
        return 0

    def _fetch_search_page(self, query: str, start_page: int, page_length: int = 50) -> tuple[List[Dict[str, Any]], str]:
        """Fetches a single page of results with retry logic."""
        payload = {
            "startPage": str(start_page),
            "pageLength": str(page_length),
            "Search": query,
            "orderColunm": "1",
            "orderType": "asc",
            "arp_id": "0",
            "artid": "0",
            "system_id": "0",
            "app_status": "1",
            "category": "0",
            "keyword_string": "",
            "jsonData": ""
        }
        for attempt in range(1, MAX_RETRIES + 1):
            try:
                resp = self.session.post(FILTER_SEARCH_DATA_URL, data=payload, timeout=REQUEST_TIMEOUT_SECONDS)
                if resp.status_code == 200:
                    return resp.json(), ""
                time.sleep(BACKOFF_FACTOR ** attempt)
            except Exception as e:
                if attempt == MAX_RETRIES:
                    return [], str(e)
                time.sleep(BACKOFF_FACTOR ** attempt)
        return [], "Max retries exceeded"

    def enrich_records(self, records: List[AyushRecord]) -> List[AyushRecord]:
        """Fetches full landing pages for records to extract abstract, authors, and full citations."""
        enriched_map: Dict[int, Dict[str, Any]] = {}
        if self.enriched_checkpoint_file.exists():
            try:
                with open(self.enriched_checkpoint_file, "r", encoding="utf-8") as f:
                    enriched_map = {d["id"]: d for d in json.load(f)}
                    print(f"[Acquisition] Found {len(enriched_map)} enriched records in checkpoint")
            except Exception:
                enriched_map = {}

        total = len(records)
        print(f"[Acquisition] Enriching {total} records from landing pages...")

        for idx, rec in enumerate(records, start=1):
            if rec.id in enriched_map:
                # Rehydrate from checkpoint
                cached_data = enriched_map[rec.id]
                for k, v in cached_data.items():
                    if hasattr(rec, k) and v:
                        setattr(rec, k, v)
                continue

            # Fetch landing page
            html = self._fetch_landing_page(rec.id)
            if html:
                enrich_record_from_landing_html(rec, html)
            
            enriched_map[rec.id] = rec.to_dict()

            if idx % 25 == 0 or idx == total:
                print(f"  Enriched {idx}/{total} records ({(idx/total)*100:.1f}%)")
                # Periodic checkpoint save
                self._save_enriched_checkpoint(enriched_map)

            time.sleep(RATE_LIMIT_DELAY_SECONDS + random.uniform(0, RATE_LIMIT_JITTER_SECONDS))

        self._save_enriched_checkpoint(enriched_map)
        return records

    def _fetch_landing_page(self, article_id: int) -> str:
        """Fetches the HTML of an article landing page."""
        url = f"{LANDING_PAGE_URL}?rp6={article_id}"
        for attempt in range(1, MAX_RETRIES + 1):
            try:
                resp = self.session.get(url, timeout=REQUEST_TIMEOUT_SECONDS)
                if resp.status_code == 200:
                    return resp.text
                time.sleep(BACKOFF_FACTOR ** attempt)
            except Exception:
                time.sleep(BACKOFF_FACTOR ** attempt)
        return ""

    def _save_enriched_checkpoint(self, enriched_map: Dict[int, Dict[str, Any]]):
        try:
            with open(self.enriched_checkpoint_file, "w", encoding="utf-8") as f:
                json.dump(list(enriched_map.values()), f, indent=2)
        except Exception as e:
            print(f"[Acquisition] Warning: failed to save enriched checkpoint: {e}")

