"""
Nutrient Earth — Relevance Ranking & Selection Engine
Scores candidates across the 8 core topic domains and selects the top 800 balanced records.
"""

import re
from typing import List, Dict, Tuple
from .models import AyushRecord
from .config import TOPIC_DOMAINS, WEIGHTS, TOTAL_TARGET_RECORDS

class RelevanceRanker:
    def __init__(self, target_count: int = TOTAL_TARGET_RECORDS):
        self.target_count = target_count

    def compute_score(self, record: AyushRecord) -> float:
        """
        Computes a multi-factor relevance score (0.0 - 100.0) based on:
        - Keyword relevance in title and abstract (max 25)
        - Clinical study design & evidence grade (max 30)
        - Abstract presence and depth (max 20)
        - Metadata richness: DOI, PMID, authors, journal (max 15)
        - Publication recency (max 10)
        """
        score = 0.0
        
        # 1. Topic Keyword Match (Title is 3x weighted, Abstract 1x)
        domain_info = TOPIC_DOMAINS.get(record.primary_topic_domain)
        keywords = domain_info["keywords"] if domain_info else [
            "ayurveda", "nutrition", "diet", "herb", "clinical", "safety", "metabolic"
        ]
        
        title_text = record.title.lower()
        abstract_text = record.abstract.lower()
        
        title_matches = sum(1 for kw in keywords if re.search(r'\b' + re.escape(kw) + r'\b', title_text))
        abstract_matches = sum(1 for kw in keywords if re.search(r'\b' + re.escape(kw) + r'\b', abstract_text))
        
        kw_score = min(25.0, (title_matches * 5.0) + (abstract_matches * 2.0))
        score += kw_score

        # 2. Clinical Evidence Grade & Study Design
        sub_cat = (record.sub_category or record.category).upper()
        if "GRADE A" in sub_cat or "SYSTEMATIC REVIEW" in sub_cat or "META-ANALYSIS" in sub_cat:
            score += 30.0
        elif "GRADE B" in sub_cat or "RANDOMIZED" in sub_cat or "RCT" in sub_cat:
            score += 28.0
        elif "GRADE C" in sub_cat or "CLINICAL RESEARCH" in sub_cat:
            score += 24.0
        elif "STANDARDIZATION" in sub_cat or "PHYTOCHEMICAL" in sub_cat:
            score += 18.0
        elif "PHARMACOLOGICAL" in sub_cat or "PRE-CLINICAL" in sub_cat:
            score += 15.0
        else:
            score += 10.0

        # 3. Abstract Completeness
        abs_len = len(record.abstract)
        if abs_len > 800:
            score += 20.0
        elif abs_len > 400:
            score += 15.0
        elif abs_len > 100:
            score += 10.0
        else:
            score += 2.0

        # 4. Metadata Richness
        meta_score = 0.0
        if record.authors: meta_score += 4.0
        if record.journal: meta_score += 4.0
        if record.doi: meta_score += 4.0
        if record.pmid: meta_score += 3.0
        score += min(15.0, meta_score)

        # 5. Publication Recency
        if record.publication_year:
            y = record.publication_year
            if y >= 2020:
                score += 10.0
            elif y >= 2015:
                score += 8.0
            elif y >= 2010:
                score += 6.0
            elif y >= 2000:
                score += 4.0
            else:
                score += 2.0
        else:
            score += 3.0

        record.relevance_score = round(score, 2)
        return record.relevance_score

    def select_top_records(self, records: List[AyushRecord]) -> List[AyushRecord]:
        """
        Scores all records and performs balanced selection across all 8 topic domains,
        ensuring comprehensive representation without domain starvation.
        """
        # Score each record
        for r in records:
            self.compute_score(r)

        # Group by topic domain
        domain_groups: Dict[str, List[AyushRecord]] = {k: [] for k in TOPIC_DOMAINS.keys()}
        unassigned: List[AyushRecord] = []

        for r in records:
            if r.primary_topic_domain in domain_groups:
                domain_groups[r.primary_topic_domain].append(r)
            else:
                unassigned.append(r)

        # Sort each domain group by score descending
        for d in domain_groups:
            domain_groups[d].sort(key=lambda x: x.relevance_score, reverse=True)

        selected: List[AyushRecord] = []
        selected_ids = set()

        # Phase 1: Allocate quotas for each of the 8 topic domains
        quota_per_domain = self.target_count // len(TOPIC_DOMAINS)  # e.g. 100
        for domain_key, group in domain_groups.items():
            taken = 0
            for r in group:
                if taken >= quota_per_domain:
                    break
                if r.id not in selected_ids:
                    selected.append(r)
                    selected_ids.add(r.id)
                    taken += 1

        # Phase 2: If quota remains, take highest scoring records across the entire remaining pool
        if len(selected) < self.target_count:
            remaining_pool = [r for r in records if r.id not in selected_ids]
            remaining_pool.sort(key=lambda x: x.relevance_score, reverse=True)
            needed = self.target_count - len(selected)
            for r in remaining_pool[:needed]:
                selected.append(r)
                selected_ids.add(r.id)

        # Final sort by relevance score descending
        selected.sort(key=lambda x: x.relevance_score, reverse=True)
        for rank, r in enumerate(selected, start=1):
            r.rank = rank

        return selected

