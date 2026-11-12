"""
Nutrient Earth — Metadata Normalization Module
Parses raw AJAX search rows and detailed landing page HTML into clean AyushRecord instances.
"""

import re
from typing import Dict, Any, List, Optional
from .models import AyushRecord, normalize_title
from .config import PORTAL_BASE_URL

def parse_search_row(row: Dict[str, Any], query: str, domain_key: str) -> AyushRecord:
    """Create initial AyushRecord from getFilter_Search_data JSON row."""
    rec_id = int(row.get("id") or 0)
    arp_id = str(row.get("arp_id") or "").strip()
    artid = str(row.get("artid") or "").strip()
    medical_system = str(row.get("system") or "AYURVEDA").strip()
    category = str(row.get("category") or "").strip()
    year_str = str(row.get("year") or "").strip()
    title = str(row.get("title_manual") or "").strip()
    volume = str(row.get("volume") or "").strip()
    issue = str(row.get("issue") or "").strip()
    
    # Try parsing publication year
    pub_year: Optional[int] = None
    if year_str.isdigit():
        pub_year = int(year_str)
    else:
        y_match = re.search(r"\b(19\d\d|20\d\d)\b", year_str)
        if y_match:
            pub_year = int(y_match.group(1))

    # Parse journal details HTML snippet if present
    journal_details_html = str(row.get("journal_details") or "")
    journal = ""
    doi = ""
    pmid = ""
    
    if journal_details_html:
        # Journal name
        j_match = re.search(r'<span class="value-title">([^<]+)</span>\s*;\s*(\d{4})', journal_details_html, re.I)
        if j_match:
            journal = j_match.group(1).strip()
        else:
            j_match2 = re.search(r'<span class="custom-data-value"><span class="value-title">([^<]+)</span>', journal_details_html, re.I)
            if j_match2:
                journal = j_match2.group(1).strip()

        # DOI
        doi_match = re.search(r'<span class="value-title">doi:</span>\s*([^<]+)</span>', journal_details_html, re.I)
        if doi_match:
            doi_val = doi_match.group(1).strip()
            if doi_val.lower() not in ("no", "ni", "na", "-", "none"):
                doi = doi_val

        # PMID
        pmid_match = re.search(r'<span class="value-title">PMID:</span>\s*([^<]+)</span>', journal_details_html, re.I)
        if pmid_match:
            pmid_val = pmid_match.group(1).strip()
            if pmid_val.lower() not in ("no", "ni", "na", "-", "none"):
                pmid = pmid_val

    record = AyushRecord(
        id=rec_id,
        arp_id=arp_id,
        artid=artid,
        medical_system=medical_system,
        title=title,
        normalized_title=normalize_title(title),
        journal=journal,
        year=year_str,
        publication_year=pub_year,
        volume=volume,
        issue=issue,
        category=category,
        doi=doi,
        pmid=pmid,
        portal_landing_url=f"{PORTAL_BASE_URL}/View_Res_Landing_Url?rp6={rec_id}",
        primary_topic_domain=domain_key,
        matched_queries=[query]
    )
    return record


def enrich_record_from_landing_html(record: AyushRecord, html: str) -> AyushRecord:
    """Enrich an existing AyushRecord with full metadata extracted from its landing page HTML."""
    if not html:
        return record

    # Extract all labeled field pairs
    # Pattern: <label>Label :</label> <span class="value-bind" id="...">Value</span>
    field_pairs = re.findall(
        r'<label>\s*([^<:]+)\s*:\s*</label>\s*<span[^>]*class=["\']value-bind["\'][^>]*>([\s\S]*?)</span>',
        html,
        re.I
    )

    for raw_label, raw_val in field_pairs:
        label = raw_label.strip()
        val_clean = re.sub(r'<[^>]+>', ' ', raw_val).strip()
        val_clean = ' '.join(val_clean.split())

        if label == "Journal" and not record.journal:
            record.journal = val_clean
        elif label == "Year" and (not record.year or record.year == "0"):
            record.year = val_clean
            if val_clean.isdigit():
                record.publication_year = int(val_clean)
        elif label == "Volume" and not record.volume:
            record.volume = val_clean
        elif label == "Issue" and not record.issue:
            record.issue = val_clean
        elif label == "Page":
            record.pages = val_clean
        elif label == "Authors":
            record.authors = val_clean
        elif label == "Author's Affiliation":
            record.affiliations = val_clean
        elif label == "Category" and not record.category:
            record.category = val_clean
        elif label == "Sub-Category":
            record.sub_category = val_clean
        elif label == "Body System":
            record.body_system = val_clean
        elif label == "Disease":
            record.disease = val_clean
        elif label == "DOI":
            if val_clean.lower() not in ("no", "ni", "na", "-", "none", ""):
                record.doi = val_clean
        elif label == "PMID":
            if val_clean.lower() not in ("no", "ni", "na", "-", "none", ""):
                record.pmid = val_clean
        elif label == "Keywords":
            kws = [k.strip() for k in re.split(r"[,;]+", val_clean) if k.strip()]
            record.keywords = list(dict.fromkeys(kws))
        elif "URL" in label:
            # Check for direct anchor href
            href_m = re.search(r'href=["\']([^"\']+)["\']', raw_val)
            if href_m:
                record.original_url = href_m.group(1).strip()
            elif val_clean.startswith("http"):
                record.original_url = val_clean

    # Determine study design and evidence grade
    sub_cat_upper = (record.sub_category or record.category).upper()
    if "GRADE A" in sub_cat_upper or "SYSTEMATIC REVIEW" in sub_cat_upper or "META-ANALYSIS" in sub_cat_upper:
        record.evidence_grade = "Grade A — Systematic Review / Meta-Analysis"
        record.study_design = "systematic_review"
    elif "GRADE B" in sub_cat_upper or "RANDOMIZED" in sub_cat_upper or "RCT" in sub_cat_upper:
        record.evidence_grade = "Grade B — Randomized Controlled Trial"
        record.study_design = "randomized_controlled_trial"
    elif "GRADE C" in sub_cat_upper or "CLINICAL RESEARCH" in sub_cat_upper:
        record.evidence_grade = "Grade C — Controlled Clinical Study / Cohort"
        record.study_design = "clinical_trial"
    elif "PRE-CLINICAL" in sub_cat_upper or "PHARMACOLOGICAL" in sub_cat_upper or "IN VIVO" in sub_cat_upper:
        record.evidence_grade = "Grade D — Pre-Clinical In Vivo / In Vitro Study"
        record.study_design = "pre_clinical"
    elif "DRUG RESEARCH" in sub_cat_upper or "STANDARDIZATION" in sub_cat_upper or "PHYTOCHEMICAL" in sub_cat_upper:
        record.evidence_grade = "Grade D — Botanical & Phytochemical Characterization"
        record.study_design = "phytochemical_analysis"
    else:
        record.evidence_grade = "Evidence Synthesis & Literature Review"
        record.study_design = "review"

    # Abstract parsing
    # The portal puts structured abstract sections inside <div class="field-box abstract" id="abstract">
    abs_div_m = re.search(r'<div[^>]*class=["\']field-box abstract["\'][^>]*>([\s\S]*?)(?:<div[^>]*class=["\']field-box|$)', html, re.I)
    if abs_div_m:
        abs_block = abs_div_m.group(1)
        # Find sections like Background, Aims, Methods, Results, Conclusion
        sec_matches = re.findall(
            r'<label>\s*([^<:]+)\s*:\s*</label>\s*<span[^>]*class=["\']value-bind["\'][^>]*>([\s\S]*?)</span>',
            abs_block,
            re.I
        )
        sections = []
        for s_label, s_val in sec_matches:
            s_label_clean = s_label.strip()
            # Skip keywords and URL which appear in this div
            if s_label_clean.lower() in ("keywords", "url (for abstract/ full paper)", "doi", "pmid"):
                continue
            s_text = re.sub(r'<[^>]+>', ' ', s_val).strip()
            s_text = ' '.join(s_text.split())
            if s_text and s_text not in ("-", "NA", "None"):
                sections.append(f"{s_label_clean}: {s_text}")

        if sections:
            record.abstract = "\n\n".join(sections)
        else:
            # Fallback to cleaning the whole block if no sub-labels
            raw_text = re.sub(r'<[^>]+>', ' ', abs_block).strip()
            raw_clean = ' '.join(raw_text.split())
            # Clean header words
            raw_clean = re.sub(r'^Abstract/\s*Summary/\s*Synopsis/\s*Outline:\s*', '', raw_clean, flags=re.I)
            record.abstract = raw_clean

    return record

