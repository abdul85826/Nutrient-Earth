"""
Nutrient Earth — Automated Verification Suite for AYUSH Research Acquisition Pipeline
Tests metadata normalization, deduplication, relevance scoring, balanced domain selection,
PDF text extraction, checkpointing, and persistence.
"""

import unittest
import tempfile
import json
import zlib
from pathlib import Path

import sys
cur = Path(__file__).absolute()
PROJECT_ROOT = None
for p in [cur] + list(cur.parents):
    if (p / "scripts" / "ayush_pipeline").exists():
        PROJECT_ROOT = p
        break
if not PROJECT_ROOT:
    PROJECT_ROOT = Path("D:/Documents/NE_App/Nutrient_Earth")

if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from scripts.ayush_pipeline.models import AyushRecord, normalize_title, calculate_sha256
from scripts.ayush_pipeline.normalization import parse_search_row, enrich_record_from_landing_html
from scripts.ayush_pipeline.deduplication import Deduplicator
from scripts.ayush_pipeline.relevance import RelevanceRanker
from scripts.ayush_pipeline.text_extractor import PDFTextExtractor
from scripts.ayush_pipeline.persistence import PersistenceManager
from scripts.ayush_pipeline.config import TOPIC_DOMAINS

class TestAyushPipeline(unittest.TestCase):

    def test_normalize_title(self):
        raw = "  <b>MANAGEMENT OF IRON DEFICIENCY</b> & Anaemia in Females: (Clinical Trial)  "
        clean = normalize_title(raw)
        self.assertEqual(clean, "management of iron deficiency anaemia in females clinical trial")

    def test_parse_search_row(self):
        sample_row = {
            "id": 101,
            "arp_id": "ARP_AYU000101",
            "artid": "554(Ay)",
            "system": "AYURVEDA",
            "category": "CLINICAL RESEARCH",
            "year": "2021",
            "volume": "12",
            "issue": "3",
            "title_manual": "Efficacy of Ashwagandha in Chronic Fatigue Syndrome",
            "journal_details": (
                '<div class="custom-data-sec"><a class="view_res_landing"><span>Title</span></a>'
                '<span class="custom-data-value"><span class="value-title">Journal of Ayurveda and Integrative Medicine</span>; 2021; 12(3): 10-15</span> '
                '<span class="custom-data-value"><span class="value-title">doi:</span>10.1016/j.jaim.2021.01.002</span> '
                '<span class="custom-data-value"><span class="value-title">PMID:</span>33456789</span></div>'
            )
        }

        record = parse_search_row(sample_row, query="fatigue", domain_key="ayurveda_nutrition")
        self.assertEqual(record.id, 101)
        self.assertEqual(record.arp_id, "ARP_AYU000101")
        self.assertEqual(record.journal, "Journal of Ayurveda and Integrative Medicine")
        self.assertEqual(record.publication_year, 2021)
        self.assertEqual(record.doi, "10.1016/j.jaim.2021.01.002")
        self.assertEqual(record.pmid, "33456789")
        self.assertEqual(record.primary_topic_domain, "ayurveda_nutrition")
        self.assertEqual(record.matched_queries, ["fatigue"])

    def test_enrich_record_from_landing_html(self):
        record = AyushRecord(id=202, arp_id="ARP_AYU000202", title="Curcumin in Type 2 Diabetes")
        landing_html = """
        <div class="field-box title">
            <label>Authors :</label> <span class="value-bind">1. Dr. Sharma AK, 2. Dr. Gupta V.</span>
            <label>Author's Affiliation :</label> <span class="value-bind">All India Institute of Ayurveda, New Delhi</span>
            <label>Sub-Category :</label> <span class="value-bind">CLINICAL RESEARCH EVIDENCE GRADE B</span>
            <label>Body System :</label> <span class="value-bind">ENDOCRINE AND METABOLIC</span>
            <label>Disease :</label> <span class="value-bind">DIABETES MELLITUS TYPE 2</span>
            <label>URL (for Abstract/ Full paper) :</label> <span class="value-bind"><a href="https://example.org/curcumin-diabetes.pdf">Link</a></span>
        </div>
        <div class="field-box abstract" id="abstract">
            <label>Background :</label> <span class="value-bind">Type 2 diabetes represents a major metabolic burden. Curcumin has shown insulin sensitizing effects.</span>
            <label>Methods :</label> <span class="value-bind">Randomized double-blind placebo-controlled study on 60 patients for 12 weeks.</span>
            <label>Results :</label> <span class="value-bind">Statistically significant reduction in HbA1c (p < 0.01) and fasting blood glucose.</span>
            <label>Keywords :</label> <span class="value-bind">Curcumin, Type 2 Diabetes, Insulin Sensitivity, HbA1c</span>
        </div>
        """

        enriched = enrich_record_from_landing_html(record, landing_html)
        self.assertEqual(enriched.authors, "1. Dr. Sharma AK, 2. Dr. Gupta V.")
        self.assertEqual(enriched.affiliations, "All India Institute of Ayurveda, New Delhi")
        self.assertEqual(enriched.body_system, "ENDOCRINE AND METABOLIC")
        self.assertEqual(enriched.original_url, "https://example.org/curcumin-diabetes.pdf")
        self.assertIn("Background: Type 2 diabetes represents", enriched.abstract)
        self.assertIn("Methods: Randomized double-blind", enriched.abstract)
        self.assertIn("Curcumin", enriched.keywords)
        self.assertEqual(enriched.study_design, "randomized_controlled_trial")
        self.assertIn("Grade B", enriched.evidence_grade)

    def test_deduplicator(self):
        dedup = Deduplicator()

        # Record 1
        r1 = AyushRecord(
            id=1,
            arp_id="ARP_AYU000001",
            title="Punarnava Mandura in Anaemia",
            normalized_title=normalize_title("Punarnava Mandura in Anaemia"),
            year="2009",
            doi="10.1234/jaim.2009.001",
            abstract="Short summary",
            matched_queries=["nutrition"]
        )

        # Record 2: Same DOI, different query, longer abstract
        r2 = AyushRecord(
            id=99,
            arp_id="ARP_AYU000099",
            title="Punarnava Mandura in Anaemia: Clinical Study",
            normalized_title=normalize_title("Punarnava Mandura in Anaemia Clinical Study"),
            year="2009",
            doi="10.1234/jaim.2009.001",
            abstract="A comprehensive randomized trial investigating Punarnava Mandura in iron deficiency anaemia across female cohorts.",
            matched_queries=["traditional_diet"]
        )

        # Record 3: Distinct record
        r3 = AyushRecord(
            id=3,
            arp_id="ARP_AYU000003",
            title="Triphala in Gut Microbiome Diversity",
            normalized_title=normalize_title("Triphala in Gut Microbiome Diversity"),
            year="2022",
            doi="10.1234/jaim.2022.003",
            abstract="Triphala modulation of intestinal microbiota.",
            matched_queries=["gut"]
        )

        dedup.add_record(r1)
        res_r2, is_new2 = dedup.add_record(r2)
        res_r3, is_new3 = dedup.add_record(r3)

        self.assertFalse(is_new2)
        self.assertTrue(is_new3)
        self.assertEqual(len(dedup.deduplicated_records), 2)
        self.assertEqual(dedup.duplicates_merged_count, 1)

        # Confirm merged fields
        self.assertIn("nutrition", res_r2.matched_queries)
        self.assertIn("traditional_diet", res_r2.matched_queries)
        self.assertIn("comprehensive randomized trial", res_r2.abstract)

    def test_relevance_ranking_and_selection(self):
        ranker = RelevanceRanker(target_count=4)

        records = []
        domains = list(TOPIC_DOMAINS.keys())
        
        # Create records across different domains
        for i, dom in enumerate(domains):
            r = AyushRecord(
                id=i + 1,
                arp_id=f"ARP_AYU{i+1:06d}",
                title=f"Clinical Study on {dom.replace('_', ' ')} Interventions",
                primary_topic_domain=dom,
                year="2022",
                publication_year=2022,
                category="CLINICAL RESEARCH",
                sub_category="CLINICAL RESEARCH EVIDENCE GRADE B",
                abstract="Clinical trial evaluating therapeutic efficacy and metabolic biomarkers in patient cohorts.",
                doi=f"10.1000/ayush.{i+1}",
                authors="Dr. Author"
            )
            records.append(r)

        selected = ranker.select_top_records(records)
        self.assertEqual(len(selected), 4)
        for rank, r in enumerate(selected, start=1):
            self.assertEqual(r.rank, rank)
            self.assertGreater(r.relevance_score, 50.0)

    def test_text_extractor_flate_stream(self):
        # Synthesize a minimal valid PDF with a compressed FlateDecode text stream
        extractor = PDFTextExtractor()
        
        raw_text = b"(Nutrient Earth AYUSH Research Verification) Tj"
        compressed_stream = zlib.compress(raw_text)
        
        pdf_bytes = (
            b"%PDF-1.4\n"
            b"1 0 obj\n<< /Length " + str(len(compressed_stream)).encode() + b" /Filter /FlateDecode >>\n"
            b"stream\n" + compressed_stream + b"\nendstream\nendobj\n"
            b"%%EOF\n"
        )

        with tempfile.TemporaryDirectory() as tmp_dir:
            pdf_path = Path(tmp_dir) / "test_doc.pdf"
            with open(pdf_path, "wb") as f:
                f.write(pdf_bytes)

            extracted = extractor._extract_text_from_pdf_file(pdf_path)
            self.assertIn("Nutrient Earth AYUSH Research Verification", extracted)

    def test_persistence_manager(self):
        with tempfile.TemporaryDirectory() as tmp_dir:
            tmp_path = Path(tmp_dir)
            pm = PersistenceManager(output_dir=tmp_path / "exports", log_dir=tmp_path / "logs")

            record = AyushRecord(
                id=500,
                arp_id="ARP_AYU000500",
                title="Guduchi Immunomodulatory Study",
                normalized_title="guduchi immunomodulatory study",
                journal="AYU Journal",
                year="2023",
                publication_year=2023,
                category="CLINICAL RESEARCH",
                sub_category="GRADE B",
                primary_topic_domain="ayurveda_nutrition",
                relevance_score=88.5,
                pdf_status="downloaded",
                pdf_filename="ARP_AYU000500.pdf",
                abstract="Immunomodulatory effects of Tinospora cordifolia."
            )

            # Test Manifest
            manifest_path = pm.save_manifest([record], filename="test_manifest.json")
            self.assertTrue(manifest_path.exists())
            with open(manifest_path, "r", encoding="utf-8") as f:
                m_data = json.load(f)
                self.assertEqual(m_data["target_total_records"], 1)
                self.assertIn("manifest_sha256", m_data)

            # Test Metadata JSON and CSV
            json_path = pm.export_metadata_json([record], filename="test_meta.json")
            csv_path = pm.export_metadata_csv([record], filename="test_meta.csv")
            self.assertTrue(json_path.exists())
            self.assertTrue(csv_path.exists())

            # Test Restricted Report
            record_restricted = AyushRecord(
                id=501,
                arp_id="ARP_AYU000501",
                title="Commercial Clinical Paper",
                original_url="https://sciencedirect.com/article/123",
                pdf_status="restricted",
                access_restriction_reason="Paywalled journal."
            )
            report_path = pm.export_failed_restricted_report([record, record_restricted], filename="test_report.json")
            self.assertTrue(report_path.exists())
            with open(report_path, "r", encoding="utf-8") as f:
                rep_data = json.load(f)
                self.assertEqual(rep_data["total_restricted_or_abstract_only"], 1)

            # Test SQL Seed
            sql_path = pm.export_to_sql_seed([record], filename="test_seed.sql")
            self.assertTrue(sql_path.exists())
            with open(sql_path, "r", encoding="utf-8") as f:
                sql_content = f.read()
                self.assertIn("INSERT INTO public.evidence_chunks", sql_content)
                self.assertIn("Guduchi Immunomodulatory Study", sql_content)

if __name__ == "__main__":
    unittest.main()
