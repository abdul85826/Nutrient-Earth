"""
Nutrient Earth — AYUSH Research Automated Acquisition CLI
Entry point for running, inspecting, and managing the AYUSH ingestion pipeline.
"""

import sys
import argparse
from pathlib import Path

# Add project root to path
PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

from scripts.ayush_pipeline.config import TOTAL_TARGET_RECORDS, TOPIC_DOMAINS
from scripts.ayush_pipeline.pipeline import AyushAcquisitionPipeline
from scripts.ayush_pipeline.acquisition import AcquisitionEngine

def inspect_portal():
    """Checks AYUSH portal reachability and displays record pool across all 8 domains."""
    print("Inspecting AYUSH Research Portal (https://arp.ayush.gov.in)...")
    engine = AcquisitionEngine()
    if not engine.initialize_session():
        print("Error: Could not reach AYUSH portal.")
        sys.exit(1)

    print("\n--- Topic Domain Counts ---")
    total = 0
    for domain_key, info in TOPIC_DOMAINS.items():
        print(f"\n[{info['title']}]")
        domain_subtotal = 0
        for q in info["queries"]:
            count = engine._fetch_query_count(q)
            print(f"  - Query '{q}': {count:,} records")
            domain_subtotal += count
        total += domain_subtotal
        print(f"  Subtotal: {domain_subtotal:,} available candidates")

    print(f"\nTotal aggregate searchable candidate pool: ~{total:,} records.")

def main():
    parser = argparse.ArgumentParser(
        description="Nutrient Earth — AYUSH Research Automated Acquisition Pipeline"
    )
    subparsers = parser.add_subparsers(dest="command", help="Command to execute")

    # Run command
    run_parser = subparsers.add_parser("run", help="Run the full acquisition pipeline")
    run_parser.add_argument(
        "--target",
        type=int,
        default=TOTAL_TARGET_RECORDS,
        help=f"Target number of deduplicated top records to acquire (default: {TOTAL_TARGET_RECORDS})"
    )
    run_parser.add_argument(
        "--max-candidates-per-domain",
        type=int,
        default=150,
        help="Maximum raw candidates to inspect per topic domain (default: 150)"
    )
    run_parser.add_argument(
        "--skip-pdf",
        action="store_true",
        help="Skip downloading PDFs (metadata and text acquisition only)"
    )

    # Inspect command
    subparsers.add_parser("inspect", help="Inspect AYUSH portal counts and connectivity")

    args = parser.parse_args()

    if args.command == "inspect":
        inspect_portal()
    else:
        target = getattr(args, "target", TOTAL_TARGET_RECORDS)
        skip_pdf = getattr(args, "skip_pdf", False)
        max_candidates = getattr(args, "max_candidates_per_domain", 150)
        
        pipeline = AyushAcquisitionPipeline(target_records=target)
        pipeline.run(skip_pdf_downloads=skip_pdf, max_candidates_per_domain=max_candidates)

if __name__ == "__main__":
    main()

