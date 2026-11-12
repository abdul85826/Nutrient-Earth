"""
Nutrient Earth — Persistence & Export Module
Generates manifest_800.json, metadata exports (JSON/CSV), failed/restricted reports,
reproducible import logs, and PostgreSQL SQL seed scripts.
"""

import os
import json
import csv
import hashlib
from datetime import datetime, timezone
from pathlib import Path
from typing import List, Dict, Any
from .models import AyushRecord
from .config import EXPORTS_DIR, LOGS_DIR

class PersistenceManager:
    def __init__(self, output_dir: Path = EXPORTS_DIR, log_dir: Path = LOGS_DIR):
        self.output_dir = output_dir
        self.log_dir = log_dir
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.log_dir.mkdir(parents=True, exist_ok=True)

    def save_manifest(self, records: List[AyushRecord], filename: str = "manifest_800.json") -> Path:
        """Saves the 800-record target manifest with summary statistics."""
        target_path = self.output_dir / filename
        
        # Domain breakdown
        domain_counts: Dict[str, int] = {}
        pdf_status_counts: Dict[str, int] = {}
        for r in records:
            domain_counts[r.primary_topic_domain] = domain_counts.get(r.primary_topic_domain, 0) + 1
            pdf_status_counts[r.pdf_status] = pdf_status_counts.get(r.pdf_status, 0) + 1

        manifest_data = {
            "manifest_version": "1.0.0",
            "generated_at": datetime.now(timezone.utc).isoformat(),
            "target_total_records": len(records),
            "domain_breakdown": domain_counts,
            "pdf_status_breakdown": pdf_status_counts,
            "provenance": {
                "source": "Ministry of Ayush, Government of India — Ayush Research Portal",
                "source_url": "https://arp.ayush.gov.in/arp/research_advance_search",
                "licence": "Government of India Ayush Research Portal Open Scientific Dissemination",
                "pipeline_version": "Nutrient Earth AYUSH Automated Acquisition Pipeline v2.0"
            },
            "records": [r.to_dict() for r in records]
        }

        # Calculate manifest content hash
        manifest_json_str = json.dumps(manifest_data, indent=2, ensure_ascii=False)
        content_hash = hashlib.sha256(manifest_json_str.encode("utf-8")).hexdigest()
        manifest_data["manifest_sha256"] = content_hash

        with open(target_path, "w", encoding="utf-8") as f:
            json.dump(manifest_data, f, indent=2, ensure_ascii=False)

        print(f"[Persistence] Manifest saved to {target_path} (records={len(records)}, SHA-256={content_hash[:12]}...)")
        return target_path

    def export_metadata_json(self, records: List[AyushRecord], filename: str = "metadata_export.json") -> Path:
        """Exports raw record list to structured JSON."""
        target_path = self.output_dir / filename
        with open(target_path, "w", encoding="utf-8") as f:
            json.dump([r.to_dict() for r in records], f, indent=2, ensure_ascii=False)
        print(f"[Persistence] Metadata JSON saved to {target_path}")
        return target_path

    def export_metadata_csv(self, records: List[AyushRecord], filename: str = "metadata_export.csv") -> Path:
        """Exports records into a clean tabular CSV format."""
        target_path = self.output_dir / filename
        headers = [
            "rank", "id", "arp_id", "medical_system", "title", "authors", "journal", "year",
            "volume", "issue", "pages", "category", "sub_category", "study_design", "evidence_grade",
            "doi", "pmid", "original_url", "primary_topic_domain", "relevance_score",
            "pdf_status", "pdf_filename", "pdf_sha256", "pdf_size_bytes", "extracted_char_count",
            "access_restriction_reason"
        ]

        with open(target_path, "w", encoding="utf-8", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=headers, extrasaction="ignore")
            writer.writeheader()
            for r in records:
                writer.writerow(r.to_dict())

        print(f"[Persistence] Metadata CSV saved to {target_path}")
        return target_path

    def export_failed_restricted_report(self, records: List[AyushRecord], filename: str = "failed_restricted_report.json") -> Path:
        """Stores abstract-only, restricted and unavailable records separately with audit details."""
        target_path = self.output_dir / filename
        
        restricted_records = [r for r in records if r.pdf_status in ("restricted", "abstract_only", "unavailable")]
        
        report = {
            "report_generated_at": datetime.now(timezone.utc).isoformat(),
            "total_restricted_or_abstract_only": len(restricted_records),
            "summary_by_status": {},
            "policy_statement": (
                "Per Nutrient Earth strict security and compliance rules, no paywalls, commercial logins, "
                "or anti-bot challenge systems were bypassed. Restricted records retain their authentic metadata, "
                "abstracts, and source URLs for legal citation and authorized academic access."
            ),
            "restricted_entries": [
                {
                    "rank": r.rank,
                    "arp_id": r.arp_id,
                    "title": r.title,
                    "doi": r.doi,
                    "journal": r.journal,
                    "year": r.year,
                    "original_url": r.original_url,
                    "pdf_status": r.pdf_status,
                    "has_abstract": bool(r.abstract),
                    "access_restriction_reason": r.access_restriction_reason
                }
                for r in restricted_records
            ]
        }

        for r in restricted_records:
            report["summary_by_status"][r.pdf_status] = report["summary_by_status"].get(r.pdf_status, 0) + 1

        with open(target_path, "w", encoding="utf-8") as f:
            json.dump(report, f, indent=2, ensure_ascii=False)

        print(f"[Persistence] Failed/Restricted report saved to {target_path} (entries={len(restricted_records)})")
        return target_path

    def save_import_log(self, log_data: Dict[str, Any], filename: str = "import_log.json") -> Path:
        """Stores reproducible pipeline execution audit log."""
        target_path = self.log_dir / filename
        log_data["log_timestamp"] = datetime.now(timezone.utc).isoformat()
        with open(target_path, "w", encoding="utf-8") as f:
            json.dump(log_data, f, indent=2, ensure_ascii=False)
        print(f"[Persistence] Import log saved to {target_path}")
        return target_path

    def export_to_sql_seed(self, records: List[AyushRecord], filename: str = "ayush_evidence_chunks_seed.sql") -> Path:
        """Generates reproducible SQL migration file inserting records into Supabase public.evidence_chunks."""
        target_path = self.output_dir / filename
        lines = [
            "-- ==============================================================================",
            "-- Nutrient Earth — AYUSH Research Evidence Ingestion Seed",
            f"-- Generated: {datetime.now(timezone.utc).isoformat()}",
            f"-- Record Count: {len(records)}",
            "-- Target Table: public.evidence_chunks",
            "-- ==============================================================================\n",
            "BEGIN;\n"
        ]

        for r in records:
            # Escape strings for SQL
            title_esc = r.title.replace("'", "''")
            authors_esc = (r.authors or r.journal or "Ayush Research Portal").replace("'", "''")
            year_val = r.publication_year or 2020
            design_esc = r.study_design.replace("'", "''")
            grade_esc = r.evidence_grade.replace("'", "''")
            content = r.abstract if r.abstract else f"Research Title: {r.title}. Category: {r.category}."
            content_esc = content.replace("'", "''")
            pmid_val = f"'{r.pmid}'" if r.pmid else "NULL"
            doi_val = f"'{r.doi}'" if r.doi else "NULL"
            
            metadata = {
                "arp_id": r.arp_id,
                "portal_id": r.id,
                "medical_system": r.medical_system,
                "journal": r.journal,
                "volume": r.volume,
                "issue": r.issue,
                "pages": r.pages,
                "category": r.category,
                "sub_category": r.sub_category,
                "body_system": r.body_system,
                "disease": r.disease,
                "keywords": r.keywords,
                "original_url": r.original_url,
                "portal_url": r.portal_landing_url,
                "pdf_status": r.pdf_status,
                "pdf_filename": r.pdf_filename,
                "pdf_sha256": r.pdf_sha256,
                "relevance_score": r.relevance_score,
                "topic_domain": r.primary_topic_domain
            }
            meta_json = json.dumps(metadata, ensure_ascii=False).replace("'", "''")

            sql = (
                f"INSERT INTO public.evidence_chunks (\n"
                f"    pmid, doi, title, authors_or_journal, publication_year,\n"
                f"    study_design, evidence_grade, chunk_index, chunk_content, metadata\n"
                f") VALUES (\n"
                f"    {pmid_val}, {doi_val}, '{title_esc}', '{authors_esc}', {year_val},\n"
                f"    '{design_esc}', '{grade_esc}', 0, '{content_esc}', '{meta_json}'::jsonb\n"
                f") ON CONFLICT DO NOTHING;\n"
            )
            lines.append(sql)

        lines.append("COMMIT;\n")

        with open(target_path, "w", encoding="utf-8") as f:
            f.writelines(lines)

        print(f"[Persistence] SQL seed file saved to {target_path}")
        return target_path

