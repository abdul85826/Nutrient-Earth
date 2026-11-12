import requests
import re
import urllib3
from urllib.parse import urljoin

urllib3.disable_warnings()
headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"}

def get_pdfs(url):
    try:
        r = requests.get(url, headers=headers, verify=False, timeout=15)
        pdfs = re.findall(r'href=[\'"]([^\'"]+\.pdf[^\'"]*)[\'"]', r.text, re.I)
        return [urljoin(url, p) for p in pdfs]
    except Exception as e:
        print(f"Error {url}: {e}")
        return []

links = [
    "https://ayushportal.nic.in/",
    "https://ccras.nic.in/content/e-books",
    "https://ccras.nic.in/publication/ayurveda-handboooks/",
    "https://ccras.nic.in/annual-publications/"
]

all_pdfs = set()
for l in links:
    found = get_pdfs(l)
    print(f"Page {l} has {len(found)} PDFs")
    for p in found:
        all_pdfs.add(p)

print(f"\nTotal unique official PDFs found across Ayush & CCRAS: {len(all_pdfs)}")
for p in sorted(list(all_pdfs)):
    print("  *", p)

