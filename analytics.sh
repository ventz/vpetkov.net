#!/bin/bash
# Page-hit analytics from Cloudflare's edge — the modern version of reading Apache logs.
#
#   ./analytics.sh          # last 24h
#   ./analytics.sh 7        # last 7 days (one API query per day — free-plan quota)
#
# NO client-side tracking: no beacon, no cookies, no JS. This reads the request
# counts Cloudflare's proxy already has (sampled at high traffic). Sections:
# page hits (HTML, status 200) and a status-code summary. (Referrer data is not
# exposed on the free-plan GraphQL dataset.)
# Credentials: .env next to this script (needs Zone:Analytics:Read + Zone:Read).
set -euo pipefail
cd "$(dirname "$0")"
if [ -f .env ]; then set -a; source .env; set +a; fi   # set -a: export vars to python below
: "${CLOUDFLARE_API_TOKEN:?Set CLOUDFLARE_API_TOKEN (missing .env?)}"
: "${CLOUDFLARE_ZONE_ID:?Set CLOUDFLARE_ZONE_ID (missing .env?)}"

HOST="vpetkov.net"
DAYS="${1:-1}"

python3 - "$DAYS" << 'PYEOF'
import json, os, sys, urllib.request
from datetime import datetime, timedelta, timezone
from collections import Counter

TOKEN = os.environ["CLOUDFLARE_API_TOKEN"]
ZONE = os.environ["CLOUDFLARE_ZONE_ID"]
HOST = "vpetkov.net"
days = max(1, min(int(sys.argv[1]), 30))

def gql(query):
    req = urllib.request.Request(
        "https://api.cloudflare.com/client/v4/graphql",
        data=json.dumps({"query": query}).encode(),
        headers={"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"},
    )
    d = json.load(urllib.request.urlopen(req))
    if d.get("errors"):
        sys.exit(f"API error: {d['errors'][0]['message']}")
    return d["data"]["viewer"]["zones"][0]

# Non-page noise we don't count as "page hits"
ASSET_EXT = (".png", ".jpg", ".gif", ".ico", ".css", ".js", ".xml", ".txt",
             ".webmanifest", ".json", ".svg", ".woff", ".woff2", ".zip")
def is_page(p):
    return not (p.endswith(ASSET_EXT) or p.startswith((".", "/assets/", "/.well-known", "/wp-", "/cdn-cgi")))

pages, statuses = Counter(), Counter()
now = datetime.now(timezone.utc)
for i in range(days):
    end = now - timedelta(days=i)
    start = end - timedelta(hours=24)
    window = f'datetime_gt: "{start:%Y-%m-%dT%H:%M:%SZ}", datetime_leq: "{end:%Y-%m-%dT%H:%M:%SZ}", clientRequestHTTPHost: "{HOST}"'
    z = gql(f'''{{ viewer {{ zones(filter: {{zoneTag: "{ZONE}"}}) {{
        paths: httpRequestsAdaptiveGroups(limit: 500, filter: {{{window}, edgeResponseStatus: 200}}, orderBy: [count_DESC])
            {{ count dimensions {{ clientRequestPath }} }}
        codes: httpRequestsAdaptiveGroups(limit: 20, filter: {{{window}}}, orderBy: [count_DESC])
            {{ count dimensions {{ edgeResponseStatus }} }}
    }} }} }}''')
    for g in z["paths"]:
        p = g["dimensions"]["clientRequestPath"]
        if is_page(p):
            pages[p] += g["count"]
    for g in z["codes"]:
        statuses[g["dimensions"]["edgeResponseStatus"]] += g["count"]

label = "24h" if days == 1 else f"{days} days"
print(f"\n== Page hits (status 200, last {label}) ==")
for p, c in pages.most_common(25):
    print(f"{c:7}  {p}")
print(f"\n== Status codes (all requests) ==")
for s, c in sorted(statuses.items()):
    print(f"{c:7}  {s}")
print(f"\nNote: edge data is sampled at high traffic; counts include bots/crawlers (like raw Apache logs did).")
PYEOF
