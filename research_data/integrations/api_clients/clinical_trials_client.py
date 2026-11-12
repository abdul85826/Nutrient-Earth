"""
Nutrient Earth — ClinicalTrials.gov API v2 Client
Production client for querying active, completed, and recruiting clinical studies on dietary
supplements, traditional botanical medicines, lifestyle interventions, and metabolic biomarkers.
"""

from typing import Dict, Any, List, Optional
from .base_client import BaseAPIClient

class ClinicalTrialsClient(BaseAPIClient):
    def __init__(self):
        super().__init__(
            base_url="https://clinicaltrials.gov/api/v2",
            rate_limit_delay_sec=0.3,
            timeout_sec=20.0
        )

    def search_studies(
        self,
        query: str,
        page_size: int = 10,
        status: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """Search studies in ClinicalTrials.gov API v2."""
        params = {
            "query.term": query,
            "pageSize": str(page_size)
        }
        if status:
            params["filter.overallStatus"] = status

        data = self.get_json("studies", params=params)
        studies = data.get("studies", [])

        normalized = []
        for s in studies:
            protocol = s.get("protocolSection", {})
            ident = protocol.get("identificationModule", {})
            status_mod = protocol.get("statusModule", {})
            design = protocol.get("designModule", {})
            interventions_mod = protocol.get("armsInterventionsModule", {})
            eligibility = protocol.get("eligibilityModule", {})
            outcomes_mod = protocol.get("outcomesModule", {})

            nct_id = ident.get("nctId")
            interventions = [
                i.get("name") for i in interventions_mod.get("interventions", []) if "name" in i
            ]
            conditions = protocol.get("conditionsModule", {}).get("conditions", [])

            normalized.append({
                "nct_id": nct_id,
                "brief_title": ident.get("briefTitle"),
                "overall_status": status_mod.get("overallStatus"),
                "start_date": status_mod.get("startDateStruct", {}).get("date"),
                "completion_date": status_mod.get("completionDateStruct", {}).get("date"),
                "conditions": conditions,
                "interventions": interventions,
                "study_type": design.get("studyType"),
                "allocation": design.get("designInfo", {}).get("allocation"),
                "masking": design.get("designInfo", {}).get("maskingInfo", {}).get("masking"),
                "eligibility_criteria": eligibility.get("eligibilityCriteria"),
                "url": f"https://clinicaltrials.gov/study/{nct_id}"
            })
        return normalized

