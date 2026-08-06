#!/bin/bash
# Local preview server: ./hugo-preview.sh [extra hugo flags]
#
# Serves the site at http://localhost/ (port 80 — fine unprivileged on modern
# macOS) with drafts visible and a browser tab opened automatically.
set -euo pipefail
cd "$(dirname "$0")"

exec hugo server \
    --buildDrafts \
    --buildFuture \
    --port 80 \
    --bind 0.0.0.0 \
    --baseURL http://localhost/ \
    --appendPort=false \
    --ignoreCache \
    --minify \
    --openBrowser \
    --disableFastRender \
    --navigateToChanged \
    --noHTTPCache \
    --printPathWarnings \
    "$@"

# Flag rationale:
#   --buildDrafts / --buildFuture   see draft and future-dated posts
#   --port 80 + --appendPort=false  clean http://localhost/ URLs
#   --bind 0.0.0.0                  macOS only allows unprivileged port 80 on the
#                                   wildcard interface (not 127.0.0.1); also lets
#                                   you preview from other devices on the LAN
#   --ignoreCache                   don't trust stale file caches
#   --minify                        preview what production actually ships
#   --openBrowser                   open a tab on startup
#   --disableFastRender             full re-renders — REQUIRED for theme/overlay edits
#   --navigateToChanged             browser follows the file you're editing
#   --noHTTPCache                   browser never serves stale pages
#   --printPathWarnings             surfaces duplicate-output-path mistakes
