"""
AYUSH Research Portal API & Scraper Client
Extracts structured research publications across Ayurveda, Siddha, Unani, Yoga & Naturopathy
Endpoint: https://ayushportal.nic.in/
"""

import re
import os
import time
import urllib3
import requests
from typing import List, Dict, Any, Optional

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

class AyushPortalClient:
    BASE_URL = "https://ayushportal.nic.in"
    SEARCH_URL = f"{BASE_URL}/srch1.aspx"
    RESULT_URL = f"{BASE_URL}/ShowRslt2.aspx"

    def __init__(self, delay_sec: float = 0.4):
        self.session = requests.Session()
        self.session.verify = False
        self.delay_sec = delay_sec
        self.session.headers.update({
            "User-Agent": "NutrientEarth-ResearchCollector/1.0 (Windows NT 10.0; Win64; x64)",
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
        })
        self.viewstate = None
        self.viewstate_gen = None
        self.event_validation = None
        self.initialized = False

    def init_session(self):
        resp = self.session.get(self.SEARCH_URL, timeout=15)
        resp.raise_for_status()
        self._extract_form_tokens(resp.text)
        self.initialized = True

    def _extract_form_tokens(self, html: str):
        vs_m = re.search(r'id="__VIEWSTATE"\s+value="([^"]+)"', html)
        gen_m = re.search(r'id="__VIEWSTATEGENERATOR"\s+value="([^"]+)"', html)
        ev_m = re.search(r'id="__EVENTVALIDATION"\s+value="([^"]+)"', html)
        if vs_m:
            self.viewstate = vs_m.group(1)
        if gen_m:
            self.viewstate_gen = gen_m.group(1)
        if ev_m:
            self.event_validation = ev_m.group(1)

    def search_records(self, keyword: str, system: str = "Ayurveda", max_results: int = 50) -> List[Dict[str, Any]]:
        if not self.initialized:
            self.init_session()

        payload = {
            "__EVENTTARGET": "",
            "__EVENTARGUMENT": "",
            "__VIEWSTATE": self.viewstate,
            "__VIEWSTATEGENERATOR": self.viewstate_gen or "805D7A94",
            "__EVENTVALIDATION": self.event_validation,
            "ctl00$ContentPlaceHolder1$optnMS": system,
            "ctl00$ContentPlaceHolder1$txtSrch1": keyword,
            "ctl00$ContentPlaceHolder1$btnSrch1": "Search"
        }

        headers = {
            "Referer": self.SEARCH_URL,
            "Origin": self.BASE_URL,
            "Content-Type": "application/x-www-form-urlencoded"
        }

        resp = self.session.post(self.SEARCH_URL, data=payload, headers=headers, timeout=20)
        self._extract_form_tokens(resp.text)

        # Extract GridView2 rows
        records = []
        pattern = re.compile(
            r'href=[\'"]ShowRslt2\.aspx\?IDD=(\d+)[\'"][^>]*>.*?</a>.*?</font>\s*</td>\s*<td>(?:<font[^>]*>)?(.*?)(?:</font>)?\s*</td>',
            re.IGNORECASE | re.DOTALL
        )
        matches = pattern.findall(resp.text)
        for article_id, raw_title in matches:
            clean_title = re.sub(r'<[^>]+>', '', raw_title).strip()
            records.append({
                "article_id": article_id,
                "title": clean_title,
                "system": system,
                "keyword": keyword
            })
            if len(records) >= max_results:
                break

        return records

    def fetch_record_details(self, article_id: str) -> Optional[Dict[str, Any]]:
        time.sleep(self.delay_sec)
        url = f"{self.RESULT_URL}?IDD={article_id}"
        headers = {
            "Referer": self.SEARCH_URL
        }

        try:
            resp = self.session.get(url, headers=headers, timeout=15)
            if resp.status_code != 200:
                return None
            
            html = resp.text
            # Extract key-value table cells
            rows = re.findall(r'<td[^>]*>(.*?)</td>', html, re.DOTALL | re.IGNORECASE)
            clean_cells = [re.sub(r'<[^>]+>', '', cell).strip() for cell in rows if cell.strip()]

            data = {
                "article_id": article_id,
                "url": url,
                "title": None,
                "authors": [],
                "journal": None,
                "year": None,
                "volume": None,
                "issue": None,
                "pages": None,
                "abstract": None,
                "disease": None,
                "keywords": [],
                "pdf_url": None
            }

            # Map key-value pairs
            for i in range(len(clean_cells) - 1):
                label = clean_cells[i].lower()
                val = clean_cells[i+1]
                
                if "title of the" in label:
                    data["title"] = val
                elif "journal" in label and not data["journal"]:
                    data["journal"] = val
                    # Parse Journal line: e.g. Annals of Ayurvedic Medicine | Year: 2021 | Volume: 10 | Issue: 1 | Page: 10-19.
                    yr_m = re.search(r'Year:\s*(\d{4})', val)
                    if yr_m: data["year"] = yr_m.group(1)
                    vol_m = re.search(r'Volume:\s*([^|]+)', val)
                    if vol_m: data["volume"] = vol_m.group(1).strip()
                    iss_m = re.search(r'Issue:\s*([^|]+)', val)
                    if iss_m: data["issue"] = iss_m.group(1).strip()
                    pg_m = re.search(r'Page:\s*([^.]+)', val)
                    if pg_m: data["pages"] = pg_m.group(1).strip()
                elif "author(s)" in label and not data["authors"]:
                    # Clean author numbering e.g. 1. Kavya Mohan \n 2. Shailaja
                    lines = [re.sub(r'^\d+\.\s*', '', line).strip() for line in val.split("\n") if line.strip()]
                    data["authors"] = lines
                elif "disease related" in label:
                    data["disease"] = val
                elif "keywords" in label and not data["keywords"]:
                    data["keywords"] = [k.strip() for k in re.split(r'[,;]', val) if k.strip()]
                elif "abstract" in label or "synopsis" in label:
                    data["abstract"] = val
                elif "article url" in label:
                    # Check text or href
                    if "http" in val:
                        data["pdf_url"] = val.strip()
                    else:
                        url_m = re.search(r'href=[\'"]([^\'"]+)[\'"]', rows[i+1], re.I)
                        if url_m and "http" in url_m.group(1):
                            data["pdf_url"] = url_m.group(1).strip()

            return data

        except Exception as e:
            return None
