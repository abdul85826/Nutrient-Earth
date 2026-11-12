import sys
import re
sys.path.insert(0, r"D:\Documents\NE_App\Nutrient_Earth\research_data")
from integrations.api_clients.ayush_client import AyushPortalClient

c = AyushPortalClient()
c.init_session()
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
r = c.session.post(c.SEARCH_URL, data=payload, headers={"Referer": c.SEARCH_URL}, verify=False, timeout=15)

# Pattern matching ID and Title from the table row
pattern = re.compile(r'href=[\'"]ShowRslt2\.aspx\?IDD=(\d+)[\'"][^>]*>.*?</a>.*?</font>\s*</td>\s*<td>(?:<font[^>]*>)?(.*?)(?:</font>)?\s*</td>', re.IGNORECASE | re.DOTALL)
matches = pattern.findall(r.text)
print("Extracted matches:", len(matches))
for art_id, title in matches[:5]:
    clean_title = re.sub(r'<[^>]+>', '', title).strip()
    print(f"  ID: {art_id} | Title: {clean_title}")
