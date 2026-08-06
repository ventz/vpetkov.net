#!/bin/bash
# Upload media to the media-vpetkov-net R2 bucket and print blog-ready URLs.
#
# Usage:
#   ./r2-upload.sh file.png [more files...]          # -> blog/YYYY/MM/file.png (dated prefix)
#   ./r2-upload.sh -p diagrams file.png              # -> diagrams/file.png (custom prefix)
#   ./r2-upload.sh -f file.png                       # overwrite if the key already exists
#
# Prints the https://media.vpetkov.net/... URL and a paste-ready markdown line per file.
# Credentials: .env next to this script (gitignored; kept outside the repo).
set -euo pipefail

BUCKET="media-vpetkov-net"
PUBLIC_HOST="https://media.vpetkov.net"

cd "$(dirname "$0")"
if [ -f .env ]; then source .env; fi
: "${CLOUDFLARE_API_TOKEN:?Set CLOUDFLARE_API_TOKEN (missing .env?)}"
: "${CLOUDFLARE_ACCOUNT_ID:?Set CLOUDFLARE_ACCOUNT_ID (missing .env?)}"
API="https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/r2/buckets/$BUCKET/objects"

prefix="blog/$(date +%Y/%m)"
force=0
while getopts "p:fh" opt; do
    case $opt in
        p) prefix="${OPTARG%/}";;
        f) force=1;;
        h) sed -n '2,11p' "$0"; exit 0;;
        *) exit 1;;
    esac
done
shift $((OPTIND - 1))
[ $# -ge 1 ] || { echo "usage: $0 [-p prefix] [-f] file [file...]" >&2; exit 1; }

content_type() {
    case "${1##*.}" in
        png) echo image/png;; jpg|jpeg) echo image/jpeg;; gif) echo image/gif;;
        webp) echo image/webp;; avif) echo image/avif;; svg) echo image/svg+xml;;
        mp4) echo video/mp4;; webm) echo video/webm;; mp3) echo audio/mpeg;;
        pdf) echo application/pdf;; zip) echo application/zip;;
        txt) echo text/plain;; json) echo application/json;;
        *) echo application/octet-stream;;
    esac
}

urlencode() { python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1]))' "$1"; }

for f in "$@"; do
    [ -f "$f" ] || { echo "SKIP (not a file): $f" >&2; continue; }
    key="$prefix/$(basename "$f")"
    ekey=$(urlencode "$key")
    url="$PUBLIC_HOST/$key"

    if [ "$force" -ne 1 ]; then
        code=$(curl -s -o /dev/null -w '%{http_code}' -I "$url")
        if [ "$code" = "200" ]; then
            echo "EXISTS (use -f to overwrite): $url" >&2
            continue
        fi
    fi

    ok=$(curl -s -X PUT \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: $(content_type "$f")" \
        --data-binary "@$f" \
        "$API/$ekey" | python3 -c 'import json,sys; print(json.load(sys.stdin)["success"])')
    if [ "$ok" != "True" ]; then
        echo "FAILED: $f" >&2
        continue
    fi

    echo "$url"
    echo "  markdown: ![]($url)"
done
