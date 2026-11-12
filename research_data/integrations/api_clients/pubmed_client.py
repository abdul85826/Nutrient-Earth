"""
Nutrient Earth — PubMed & NCBI E-utilities API Client
Production client for searching and fetching biomedical, botanical, and nutritional publications.
Integrates with NCBI ESearch, ESummary, and EFetch using official developer credentials.
"""

import os
import xml.etree.ElementTree as ET
from typing import Dict, Any, List, Optional
from .base_client import BaseAPIClient

class PubMedClient(BaseAPIClient):
    def __init__(self, api_key: Optional[str] = None, email: Optional[str] = None):
        super().__init__(
            base_url="https://eutils.ncbi.nlm.nih.gov/entrez/eutils",
            rate_limit_delay_sec=0.15 if (api_key or os.getenv("NCBI_API_KEY")) else 0.35,
            timeout_sec=20.0
        )
        self.api_key = api_key or os.getenv("NCBI_API_KEY")
        self.email = email or os.getenv("NCBI_EMAIL", "contact@nutrientearth.com")

    def _default_params(self) -> Dict[str, str]:
        params = {"email": self.email, "retmode": "json"}
        if self.api_key:
            params["api_key"] = self.api_key
        return params

    def search(self, query: str, max_results: int = 10, db: str = "pubmed") -> List[str]:
        """Search PubMed and return list of PMIDs."""
        params = self._default_params()
        params.update({
            "db": db,
            "term": query,
            "retmax": str(max_results),
            "sort": "pub_date"
        })
        data = self.get_json("esearch.fcgi", params=params)
        id_list = data.get("esearchresult", {}).get("idlist", [])
        return id_list

    def fetch_summaries(self, pmids: List[str], db: str = "pubmed") -> List[Dict[str, Any]]:
        """Fetch publication summaries for PMIDs using ESummary."""
        if not pmids:
            return []
        
        params = self._default_params()
        params.update({
            "db": db,
            "id": ",".join(pmids)
        })
        data = self.get_json("esummary.fcgi", params=params)
        result_dict = data.get("result", {})
        
        records = []
        for pmid in pmids:
            if pmid in result_dict:
                item = result_dict[pmid]
                authors = [a.get("name") for a in item.get("authors", []) if "name" in a]
                article_ids = {id_obj.get("idtype"): id_obj.get("value") for id_obj in item.get("articleids", [])}
                
                records.append({
                    "pmid": pmid,
                    "title": item.get("title", "").rstrip("."),
                    "authors": authors,
                    "journal": item.get("source", ""),
                    "pubdate": item.get("pubdate", ""),
                    "volume": item.get("volume", ""),
                    "issue": item.get("issue", ""),
                    "pages": item.get("pages", ""),
                    "doi": article_ids.get("doi"),
                    "pmc": article_ids.get("pmc"),
                    "pubtypes": item.get("pubtype", []),
                    "full_url": f"https://pubmed.ncbi.nlm.nih.gov/{pmid}/"
                })
        return records

    def fetch_abstract_xml(self, pmid: str, db: str = "pubmed") -> Dict[str, Any]:
        """Fetch complete abstract and MeSH terms via EFetch XML."""
        params = {
            "db": db,
            "id": pmid,
            "retmode": "xml"
        }
        if self.api_key:
            params["api_key"] = self.api_key
        if self.email:
            params["email"] = self.email

        resp = self.get("efetch.fcgi", params=params)
        root = ET.fromstring(resp.content)
        
        article = root.find(".//Article")
        if article is None:
            return {"pmid": pmid, "abstract": "", "mesh_terms": []}

        # Abstract text sections
        abstract_parts = []
        for elem in article.findall(".//AbstractText"):
            label = elem.get("Label")
            text = "".join(elem.itertext())
            if label:
                abstract_parts.append(f"{label}: {text}")
            else:
                abstract_parts.append(text)
        abstract = "\n\n".join(abstract_parts)

        # MeSH Headings
        mesh_terms = []
        for mesh in root.findall(".//MeshHeading/DescriptorName"):
            mesh_terms.append(mesh.text)

        return {
            "pmid": pmid,
            "abstract": abstract,
            "mesh_terms": mesh_terms
        }

