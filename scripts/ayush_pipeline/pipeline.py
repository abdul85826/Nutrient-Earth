"""
Nutrient Earth — Master AYUSH Research Acquisition Pipeline
Orchestrates the complete 8-phase acquisition, enrichment, ranking, PDF downloading,
text extraction, and persistence workflow.
"""

import time
from datetime import datetime, timezone
from typing import List, Dict, Any, Optional

from .config import (
    TOTAL_TARGET_RECORDS,
    TOPIC_DOMAINS,
    DATA_DIR,
    EXPORTS_DIR,
    PDFS_RAW_DIR,
    EXTRACTED_TEXT_DIR
)
from .models import AyushRecord
from .acquisition import AcquisitionEngine
from .deduplication import Deduplicator
from .relevance import RelevanceRanker
from .downloader import PDFDownloader
from .text_extractor import PDFTextExtractor
from .persistence import PersistenceManager

class AyushAcquisitionPipeline:
    def __init__(self, target_records: int = TOTAL_TARGET_RECORDS):
        self.target_records = target_records
        self.acquisition = AcquisitionEngine()
        self.deduplicator = Deduplicator()
        self.ranker = RelevanceRanker(target_count=target_records)
        self.downloader = PDFDownloader(session=self.acquisition.session)
        self.extractor = PDFTextExtractor()
        self.persistence = PersistenceManager()
        self.execution_log: Dict[str, Any] = {
            "pipeline_name": "Nutrient Earth AYUSH Acquisition Pipeline",
            "start_time": datetime.now(timezone.utc).isoformat(),
            "target_records": target_records,
            "steps": {}
        }

    def run(self, skip_pdf_downloads: bool = False, max_candidates_per_domain: int = 150) -> Dict[str, Any]:
        """Executes the full automated acquisition pipeline."""
        start_ts = time.time()
        print("\n" + "=" * 75)
        print(f"NUTRIENT EARTH — AYUSH RESEARCH AUTOMATED ACQUISITION PIPELINE")
        print(f"Target: {self.target_records} Records across 8 Core Topic Domains")
        print("=" * 75)

        # ----------------------------------------------------------------------
        # Phase 1: Portal Inspection & Connectivity
        # ----------------------------------------------------------------------
        step1_start = time.time()
        print("\n[Phase 1/8] Inspecting AYUSH portal and establishing secure session...")
        session_ok = self.acquisition.initialize_session()
        if not session_ok:
            raise ConnectionError("Failed to establish session with https://arp.ayush.gov.in")
        self.execution_log["steps"]["phase_1_session"] = {
            "status": "success",
            "duration_seconds": round(time.time() - step1_start, 2)
        }

        # ----------------------------------------------------------------------
        # Phase 2: Multi-Domain Query Acquisition
        # ----------------------------------------------------------------------
        step2_start = time.time()
        print(f"\n[Phase 2/8] Acquiring candidates across all 8 topic domains...")
        raw_candidates = self.acquisition.query_topic_candidates(max_per_domain=max_candidates_per_domain)
        self.execution_log["steps"]["phase_2_acquisition"] = {
            "status": "success",
            "raw_candidates_found": len(raw_candidates),
            "duration_seconds": round(time.time() - step2_start, 2)
        }

        # ----------------------------------------------------------------------
        # Phase 3: Deduplication
        # ----------------------------------------------------------------------
        step3_start = time.time()
        print(f"\n[Phase 3/8] Deduplicating candidates by DOI, ARP ID, and normalized title...")
        deduped_candidates = self.deduplicator.process_records(raw_candidates)
        print(f"  Deduplicated pool: {len(deduped_candidates)} records (Merged {self.deduplicator.duplicates_merged_count} duplicates)")
        self.execution_log["steps"]["phase_3_deduplication"] = {
            "status": "success",
            "unique_candidates": len(deduped_candidates),
            "duplicates_merged": self.deduplicator.duplicates_merged_count,
            "duration_seconds": round(time.time() - step3_start, 2)
        }

        # ----------------------------------------------------------------------
        # Phase 4: Relevance Ranking & 800-Record Selection
        # ----------------------------------------------------------------------
        step4_start = time.time()
        print(f"\n[Phase 4/8] Computing multi-factor relevance scores and selecting top {self.target_records} records...")
        selected_records = self.ranker.select_top_records(deduped_candidates)
        print(f"  Selected {len(selected_records)} highest-ranked records with balanced domain representation.")
        self.execution_log["steps"]["phase_4_ranking"] = {
            "status": "success",
            "selected_count": len(selected_records),
            "min_score": min(r.relevance_score for r in selected_records) if selected_records else 0,
            "max_score": max(r.relevance_score for r in selected_records) if selected_records else 0,
            "avg_score": round(sum(r.relevance_score for r in selected_records) / len(selected_records), 2) if selected_records else 0,
            "duration_seconds": round(time.time() - step4_start, 2)
        }

        # ----------------------------------------------------------------------
        # Phase 5: Detailed Landing Page Metadata Enrichment
        # ----------------------------------------------------------------------
        step5_start = time.time()
        print(f"\n[Phase 5/8] Enriching {len(selected_records)} selected records with full landing page metadata...")
        enriched_records = self.acquisition.enrich_records(selected_records)
        self.execution_log["steps"]["phase_5_enrichment"] = {
            "status": "success",
            "enriched_count": len(enriched_records),
            "records_with_abstracts": sum(1 for r in enriched_records if r.abstract),
            "records_with_doi": sum(1 for r in enriched_records if r.doi),
            "records_with_authors": sum(1 for r in enriched_records if r.authors),
            "duration_seconds": round(time.time() - step5_start, 2)
        }

        # ----------------------------------------------------------------------
        # Phase 6: PDF Acquisition & Verification
        # ----------------------------------------------------------------------
        step6_start = time.time()
        if skip_pdf_downloads:
            print("\n[Phase 6/8] Skipping PDF download stage (--skip-pdf specified).")
            for r in enriched_records:
                r.pdf_status = "abstract_only"
                r.access_restriction_reason = "Download skipped via pipeline configuration."
        else:
            print(f"\n[Phase 6/8] Downloading legally accessible PDFs with rate limits and SHA-256 verification...")
            total = len(enriched_records)
            for idx, r in enumerate(enriched_records, start=1):
                self.downloader.acquire_pdf(r)
                if idx % 25 == 0 or idx == total:
                    print(f"  Downloaded: {self.downloader.downloaded_count} | Restricted: {self.downloader.restricted_count} | Abstract-only: {self.downloader.abstract_only_count} ({idx}/{total})")

        self.execution_log["steps"]["phase_6_pdf_download"] = {
            "status": "success",
            "downloaded": self.downloader.downloaded_count,
            "restricted": self.downloader.restricted_count,
            "abstract_only": self.downloader.abstract_only_count,
            "unavailable": self.downloader.unavailable_count,
            "duration_seconds": round(time.time() - step6_start, 2)
        }

        # ----------------------------------------------------------------------
        # Phase 7: Non-Destructive PDF Text Extraction
        # ----------------------------------------------------------------------
        step7_start = time.time()
        print(f"\n[Phase 7/8] Extracting text from downloaded PDFs (retaining original binaries unchanged)...")
        extracted_count = 0
        total_chars = 0
        for r in enriched_records:
            if r.pdf_status == "downloaded":
                self.extractor.extract_text_from_record(r)
                if r.extracted_char_count > 0:
                    extracted_count += 1
                    total_chars += r.extracted_char_count

        print(f"  Extracted text for {extracted_count} PDFs ({total_chars:,} total characters extracted).")
        self.execution_log["steps"]["phase_7_text_extraction"] = {
            "status": "success",
            "extracted_count": extracted_count,
            "total_extracted_characters": total_chars,
            "duration_seconds": round(time.time() - step7_start, 2)
        }

        # ----------------------------------------------------------------------
        # Phase 8: Deliverables Persistence & Audit Reports
        # ----------------------------------------------------------------------
        step8_start = time.time()
        print(f"\n[Phase 8/8] Generating deliverables and audit reports...")
        manifest_path = self.persistence.save_manifest(enriched_records)
        json_path = self.persistence.export_metadata_json(enriched_records)
        csv_path = self.persistence.export_metadata_csv(enriched_records)
        restricted_path = self.persistence.export_failed_restricted_report(enriched_records)
        sql_seed_path = self.persistence.export_to_sql_seed(enriched_records)

        total_duration = round(time.time() - start_ts, 2)
        self.execution_log["end_time"] = datetime.now(timezone.utc).isoformat()
        self.execution_log["total_duration_seconds"] = total_duration
        self.execution_log["deliverables"] = {
            "manifest_path": str(manifest_path),
            "metadata_json_path": str(json_path),
            "metadata_csv_path": str(csv_path),
            "failed_restricted_report_path": str(restricted_path),
            "sql_seed_path": str(sql_seed_path),
            "pdfs_raw_dir": str(PDFS_RAW_DIR),
            "extracted_text_dir": str(EXTRACTED_TEXT_DIR)
        }

        log_path = self.persistence.save_import_log(self.execution_log)
        print(f"  Import audit log saved to {log_path}")

        print("\n" + "=" * 75)
        print("AYUSH RESEARCH PIPELINE EXECUTION COMPLETED SUCCESSFULLY")
        print(f"Total Duration: {total_duration:.1f}s")
        print(f"Target Records Manifested: {len(enriched_records)}")
        print(f"Legally Accessible PDFs Downloaded: {self.downloader.downloaded_count}")
        print(f"Restricted / Abstract-Only Records Documented: {self.downloader.restricted_count + self.downloader.abstract_only_count}")
        print(f"Manifest File: {manifest_path}")
        print("=" * 75 + "\n")

        return self.execution_log

