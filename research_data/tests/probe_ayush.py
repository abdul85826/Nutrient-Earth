import sys
import os
sys.path.insert(0, r"D:\Documents\NE_App\Nutrient_Earth\research_data")
from integrations.api_clients.ayush_client import AyushPortalClient
import re

c = AyushPortalClient()
c.init_session()
print("Session initialized. Viewstate length:", len(c.viewstate) if c.viewstate else 0)

payload = {
    "__EVENTTARGET": "",
    "__EVENTARGUMENT": "",
    "__VIEWSTATE": c.viewstate,
    "__VIEWSTATEGENERATOR": c.viewstate_gen or "805D7A94",
    "__EVENTVALIDATION": c.event_validation,
    "ctl00$ContentPlaceHolder1$optnMS": "Ayurveda",
    "ctl00$ContentPlaceHolder1$txtSrch1": "Ashwagandha",
    "ctl00$ContentPlaceHolder1$btnSrch1": "Search"
}
headers = {
    "Referer": c.SEARCH_URL,
    "Origin": c.BASE_URL
}
r = c.session.post(c.SEARCH_URL, data=payload, headers=headers, verify=False, timeout=15)
print("POST status:", r.status_code, "HTML length:", len(r.text))
matches = re.findall(r'href=[\'"]?(ShowRslt2\.aspx\?IDD=\d+)[\'"]?', r.text, re.I)
print("Href matches count:", len(matches), matches[:3])
if len(matches) == 0:
    # Check if there is an error message or table name
    grid = re.findall(r'GridView\w*', r.text)
    print("GridView occurrences:", grid)
    labels = re.findall(r'<span[^>]*lbl[^>]*>([^<]+)</span>', r.text)
    print("Labels found:", labels)

