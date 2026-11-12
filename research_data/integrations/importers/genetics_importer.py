"""
Genetics Record Normalization Pipeline
Normalizes GWAS Catalog associations and ClinVar variant clinical significance
into NutrientEarthGeneticsRecord conforming to genetics_record.schema.json.
"""

from typing import Dict, Any, List, Optional

class GeneticsImporter:
    @staticmethod
    def normalize_gwas_association(raw: Dict[str, Any], trait_name: str) -> Dict[str, Any]:
        rs_id = raw.get("strongestRiskAllele", {}).get("riskAlleleName", "unknown_var")
        study_acc = raw.get("study", {}).get("accessionId", "")
        
        return {
            "variant_id": rs_id,
            "source_id": "src_gwas_catalog",
            "gene_symbol": raw.get("reportedGene", "Unmapped"),
            "ncbi_gene_id": None,
            "ensembl_gene_id": None,
            "chromosome": str(raw.get("chromosomeName", "")),
            "position_bp": int(raw.get("chromosomePosition", 0)) if raw.get("chromosomePosition") else None,
            "genome_assembly": "GRCh38",
            "reference_allele": None,
            "alternate_allele": None,
            "risk_or_effect_allele": raw.get("riskFrequency"),
            "phenotype_or_trait": trait_name,
            "trait_efo_id": None,
            "clinical_significance": "Risk factor",
            "p_value": float(raw.get("pvalue", 0.0)) if raw.get("pvalue") else None,
            "odds_ratio_or_beta": float(raw.get("orValue", 1.0)) if raw.get("orValue") else None,
            "population_ancestry": "Multi-ancestry",
            "evidence_rating": "Genome-Wide Significant (p < 5e-8)" if raw.get("pvalueMantissa") else "Moderate",
            "publication_pmid": str(raw.get("publicationInfo", {}).get("pubmedId", "")) if raw.get("publicationInfo") else None
        }

    @staticmethod
    def normalize_clinvar_summary(var_id: str, summary: Dict[str, Any]) -> Dict[str, Any]:
        title = summary.get("title", "")
        genes = summary.get("genes", [])
        gene_symbol = genes[0].get("symbol") if genes else "Unknown"
        
        # Clinical significance
        germline_class = summary.get("germline_classification", {}).get("description", "Uncertain significance")
        
        return {
            "variant_id": f"var_clinvar_{var_id}",
            "source_id": "src_clinvar",
            "gene_symbol": gene_symbol,
            "ncbi_gene_id": str(genes[0].get("geneid")) if genes else None,
            "ensembl_gene_id": None,
            "chromosome": summary.get("variation_set", [{}])[0].get("chromosome"),
            "position_bp": None,
            "genome_assembly": "GRCh38",
            "reference_allele": None,
            "alternate_allele": None,
            "risk_or_effect_allele": None,
            "phenotype_or_trait": summary.get("trait_set", [{}])[0].get("trait_name", "Clinical condition"),
            "trait_efo_id": None,
            "clinical_significance": germline_class,
            "p_value": None,
            "odds_ratio_or_beta": None,
            "population_ancestry": None,
            "evidence_rating": summary.get("germline_classification", {}).get("review_status"),
            "publication_pmid": None
        }

