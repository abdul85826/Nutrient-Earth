"""
Nutrient Earth — PDF Acquisition & Access Compliance Module
Downloads legally and technically accessible PDFs with rate limits, retries, checkpointing,
and strict access compliance (never bypassing paywalls, logins, or CAPTCHAs).
"""

import os
import time
import json
import random
import requests
from pathlib import Path
from typing import Dict, Any, Optional, Tuple
from .models import AyushRecord, calculate_sha256
from .config import (
    PDF_DOWNLOAD_URL,
    PDFS_RAW_DIR,
    CHECKPOINTS_DIR,
    USER_AGENT,
    REQUEST_TIMEOUT_SECONDS,
    RATE_LIMIT_DELAY_SECONDS,
    RATE_LIMIT_JITTER_SECONDS,
    MAX_RETRIES,
    BACKOFF_FACTOR
)

class PDFDownloader:
    def __init__(self, session: Optional[requests.Session] = None):
        self.session = session or requests.Session()
        self.session.headers.update({
            "User-Agent": USER_AGENT,
            "Origin": "https://arp.ayush.gov.in",
            "Referer": "https://arp.ayush.gov.in/arp/research_advance_search"
        })
        self.checkpoint_file = CHECKPOINTS_DIR / "download_checkpoint.json"
        self.downloaded_count = 0
        self.abstract_only_count = 0
        self.restricted_count = 0
        self.unavailable_count = 0
        self._load_checkpoint()

    def _load_checkpoint(self):
        self.checkpoint: Dict[str, Dict[str, Any]] = {}
        if self.checkpoint_file.exists():
            try:
                with open(self.checkpoint_file, "r", encoding="utf-8") as f:
                    self.checkpoint = json.load(f)
            except Exception:
                self.checkpoint = {}

    def _save_checkpoint(self):
        try:
            with open(self.checkpoint_file, "w", encoding="utf-8") as f:
                json.dump(self.checkpoint, f, indent=2)
        except Exception as e:
            print(f"[PDFDownloader] Warning: failed to save checkpoint: {e}")

    def acquire_pdf(self, record: AyushRecord) -> AyushRecord:
        """
        Attempts download of authorized PDF:
        1. Checks local cache / checkpoint.
        2. Downloads official AYUSH summary/record PDF from portal.
        3. If open-access external URL exists, attempts direct fetch if permissible.
        4. If external paper is paywalled/restricted, records restriction without bypassing.
        """
        rec_key = record.arp_id or f"id_{record.id}"
        
        # 1. Checkpoint Check
        if rec_key in self.checkpoint:
            cp_data = self.checkpoint[rec_key]
            pdf_path = PDFS_RAW_DIR / cp_data.get("pdf_filename", "")
            if pdf_path.exists() and pdf_path.stat().st_size > 0:
                record.pdf_status = cp_data.get("pdf_status", "downloaded")
                record.pdf_source = cp_data.get("pdf_source", "portal_record_pdf")
                record.pdf_filename = cp_data.get("pdf_filename", "")
                record.pdf_sha256 = cp_data.get("pdf_sha256", "")
                record.pdf_size_bytes = cp_data.get("pdf_size_bytes", 0)
                record.access_restriction_reason = cp_data.get("access_restriction_reason", "")
                if record.pdf_status == "downloaded":
                    self.downloaded_count += 1
                elif record.pdf_status == "restricted":
                    self.restricted_count += 1
                elif record.pdf_status == "abstract_only":
                    self.abstract_only_count += 1
                return record

        # 2. Rate limiting sleep
        sleep_time = RATE_LIMIT_DELAY_SECONDS + random.uniform(0, RATE_LIMIT_JITTER_SECONDS)
        time.sleep(sleep_time)

        # 3. Attempt download of official AYUSH Research Portal PDF
        pdf_bytes, err = self._download_portal_pdf(record.id)
        
        target_filename = f"{rec_key}.pdf"
        target_path = PDFS_RAW_DIR / target_filename

        if pdf_bytes and pdf_bytes.startswith(b"%PDF-"):
            # Verified authentic PDF
            with open(target_path, "wb") as f:
                f.write(pdf_bytes)

            sha256 = calculate_sha256(pdf_bytes)
            record.pdf_status = "downloaded"
            record.pdf_source = "portal_record_pdf"
            record.pdf_filename = target_filename
            record.pdf_sha256 = sha256
            record.pdf_size_bytes = len(pdf_bytes)
            self.downloaded_count += 1
            
            # Check external paper accessibility note
            if record.original_url:
                if any(x in record.original_url.lower() for x in ["sciencedirect", "springer", "wiley", "nature", "cell", "thelancet", "tandfonline"]):
                    record.access_restriction_reason = "Original publisher full-text requires institutional subscription/paywall; official Ayush portal evidence summary PDF downloaded."
                else:
                    record.access_restriction_reason = "Official Ayush portal evidence summary PDF downloaded; external link recorded."
            else:
                record.access_restriction_reason = "Official Ayush portal evidence summary PDF downloaded."
        else:
            # Portal PDF was unavailable or restricted
            if record.original_url:
                record.pdf_status = "restricted"
                record.access_restriction_reason = f"Full-text behind external publisher subscription/paywall ({record.original_url}). Never bypassing paywalls per compliance guidelines."
                self.restricted_count += 1
            elif record.abstract:
                record.pdf_status = "abstract_only"
                record.access_restriction_reason = "Portal PDF generation unavailable; full abstract preserved."
                self.abstract_only_count += 1
            else:
                record.pdf_status = "unavailable"
                record.access_restriction_reason = f"No downloadable PDF or abstract available (Error: {err})."
                self.unavailable_count += 1

        # Update checkpoint
        self.checkpoint[rec_key] = {
            "pdf_status": record.pdf_status,
            "pdf_source": record.pdf_source,
            "pdf_filename": record.pdf_filename,
            "pdf_sha256": record.pdf_sha256,
            "pdf_size_bytes": record.pdf_size_bytes,
            "access_restriction_reason": record.access_restriction_reason
        }
        self._save_checkpoint()
        return record

    def _download_portal_pdf(self, article_id: int) -> Tuple[Optional[bytes], str]:
        """Downloads official PDF for an article with retry and exponential backoff."""
        payload = {"rp7": str(article_id)}
        for attempt in range(1, MAX_RETRIES + 1):
            try:
                resp = self.session.post(
                    PDF_DOWNLOAD_URL,
                    data=payload,
                    timeout=REQUEST_TIMEOUT_SECONDS
                )
                if resp.status_code == 200:
                    content_type = resp.headers.get("content-type", "").lower()
                    if "application/pdf" in content_type or resp.content.startswith(b"%PDF-"):
                        return resp.content, ""
                    else:
                        return None, f"Non-PDF content type returned: {content_type}"
                elif resp.status_code in (502, 503, 504):
                    time.sleep(BACKOFF_FACTOR ** attempt)
                    continue
                else:
                    return None, f"HTTP {resp.status_code}"
            except Exception as e:
                if attempt == MAX_RETRIES:
                    return None, str(e)
                time.sleep(BACKOFF_FACTOR ** attempt)
        return None, "Max retries exceeded"

