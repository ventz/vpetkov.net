#!/bin/bash
# Create a new blog post: ./new-post.sh "My Cool Hack"
#
# Creates content/posts/YYYY/MM/my-cool-hack.md (slugified) via `hugo new`,
# using archetypes/posts.md (title/date pre-filled, draft: true).
# The published URL comes from the DATE front matter, not the folder:
#   https://vpetkov.net/YYYY/MM/DD/my-cool-hack/
set -euo pipefail
cd "$(dirname "$0")"

[ $# -ge 1 ] || { echo "usage: $0 \"Post Title\"" >&2; exit 1; }

slug=$(printf '%s' "$*" | tr '[:upper:]' '[:lower:]' | /usr/bin/sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')
[ -n "$slug" ] || { echo "could not derive a slug from: $*" >&2; exit 1; }

rel="posts/$(date +%Y/%m)/$slug.md"
file="content/$rel"
[ ! -e "$file" ] || { echo "already exists: $file" >&2; exit 1; }

hugo new content "$rel"

cat << EOF

Created: $file
URL when published: https://vpetkov.net/$(date +%Y/%m/%d)/$slug/

Workflow:
  1. Write the post (front matter is pre-filled; it starts as draft: true)
  2. Images/files: ./r2-upload.sh screenshot.png
     -> paste the printed ![](https://media.vpetkov.net/blog/$(date +%Y/%m)/screenshot.png) line
  3. Preview: ./hugo-preview.sh   (serves drafts at http://localhost/)
  4. Set draft: false, then commit + push -- Cloudflare Pages deploys automatically
EOF
