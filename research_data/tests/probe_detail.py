import sys
import re
sys.path.insert(0, r"D:\Documents\NE_App\Nutrient_Earth\research_data")
from integrations.api_clients.ayush_client import AyushPortalClient

c = AyushPortalClient()
records = c.search_records("Ashwagandha", system="Ayurveda", max_results=1)
first_id = records[0]["article_id"]
url = f"{c.RESULT_URL}?IDD={first_id}"
headers = {"Referer": c.SEARCH_URL}
resp = c.session.get(url, headers=headers, verify=False, timeout=15)

# Find table rows with field names (Title, Author, Journal, etc.)
rows = re.findall(r'<td[^>]*>(.*?)</td>', resp.text, re.DOTALL | re.IGNORECASE)
clean_cells = [re.sub(r'<[^>]+>', '', cell).strip() for cell in rows if cell.strip()]
print("Found table cells:", len(clean_cells))
for i in range(0, min(len(clean_cells), 25)):
    if clean_cells[i]:
        print(f"  [{i}] {clean_cells[i][:80]}")
