import requests
import re
import urllib3
from urllib.parse import urljoin

urllib3.disable_warnings()

headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"}

def check_site(name, url):
    print(f"\n--- Checking {name} ({url}) ---")
    try:
        r = requests.get(url, headers=headers, verify=False, timeout=15)
        print(f"Status: {r.status_code}, Length: {len(r.text)}")
        pdfs = re.findall(r'href=[\'"]([^\'"]+\.pdf[^\'"]*)[\'"]', r.text, re.I)
        print(f"Direct PDF links found: {len(pdfs)}")
        for p in pdfs[:5]:
            full_url = urljoin(url, p)
            print(f"  PDF: {full_url}")
        
        # Also find sub-pages related to publications, books, downloads
        pages = re.findall(r'href=[\'"]([^\'"]+(?:publication|download|book|document|guideline|journal|monograph)[^\'"]*)[\'"]', r.text, re.I)
        print(f"Relevant sub-pages found: {len(pages)}")
        for pg in list(set(pages))[:5]:
            print(f"  Subpage: {urljoin(url, pg)}")
    except Exception as e:
        print(f"Error checking {name}: {e}")

check_site("AYUSH Portal Home", "https://ayushportal.nic.in/")
check_site("CCRAS Home", "https://ccras.nic.in/")
check_site("CCRAS Publications", "https://ccras.nic.in/content/publications")
check_site("CCRAS E-Books", "https://ccras.nic.in/content/e-books")
check_site("NMPB Home", "https://nmpb.nic.in/")
check_site("NMPB Publications", "https://nmpb.nic.in/content/publications")
check_site("Ayush Ministry Documents", "https://ayush.gov.in/documents")
check_site("FSSAI Regulations", "https://www.fssai.gov.in/cms/food-safety-and-standards-regulations.php")

