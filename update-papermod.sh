#!/bin/bash
# Update the PaperMod fork from upstream and re-apply the Ventz overlay.
#
#   ./update-papermod.sh
#
# Flow (see README "Updating the theme"):
#   1. themes/PaperMod: fetch upstream, fast-forward the fork, push it
#   2. stage the submodule pointer bump in the site repo
#   3. ./ventz-mods/reapply.sh      -- 3-way merge the overlay onto the new theme
#   4. ./generate-ventz-mods.sh     -- refresh the snapshot against the new commit
#
# The script STAGES but never commits — review the result, then commit.
set -euo pipefail
cd "$(dirname "$0")"

theme="themes/PaperMod"
UPSTREAM_URL="https://github.com/adityatelange/hugo-PaperMod.git"

[ -d "$theme/.git" ] || [ -f "$theme/.git" ] || {
    echo "ERROR: theme submodule missing — run: git submodule update --init" >&2; exit 1; }

# Fresh clones only have origin; upstream is local config
git -C "$theme" remote get-url upstream >/dev/null 2>&1 || {
    echo "> Adding upstream remote ($UPSTREAM_URL)"
    git -C "$theme" remote add upstream "$UPSTREAM_URL"
}

# Refuse to run on a dirty theme checkout — mods NEVER belong in the submodule
if [ -n "$(git -C "$theme" status --porcelain)" ]; then
    echo "ERROR: $theme has local changes. Customizations belong in the site overlay," >&2
    echo "       never in the submodule. Inspect: git -C $theme status" >&2
    exit 1
fi

echo "> Updating fork from upstream"
git -C "$theme" checkout -q master
git -C "$theme" fetch upstream
before=$(git -C "$theme" rev-parse HEAD)
git -C "$theme" merge --ff-only upstream/master
after=$(git -C "$theme" rev-parse HEAD)

if [ "$before" = "$after" ]; then
    echo ""
    echo "Already up to date with upstream ($(git -C "$theme" rev-parse --short HEAD)) — nothing to do."
    exit 0
fi

echo "> Pushing fork ($(git -C "$theme" rev-parse --short "$before") -> $(git -C "$theme" rev-parse --short "$after"))"
git -C "$theme" push origin master

echo "> Upstream changes pulled in:"
git -C "$theme" log --oneline "$before..$after" | head -20
n=$(git -C "$theme" rev-list --count "$before..$after")
[ "$n" -gt 20 ] && echo "  ... ($n commits total)"

echo ""
echo "> Staging submodule pointer bump"
git add "$theme"

echo ""
echo "> Re-applying overlay (3-way merge)"
./ventz-mods/reapply.sh

echo ""
echo "> Refreshing snapshot against the new theme commit"
./generate-ventz-mods.sh

cat << 'EOF'

Done. Next steps:
  1. Resolve any CONFLICT/GONE files reported above (search for <<<<<<< markers)
  2. Verify visually:   ./hugo-preview.sh
  3. Commit everything (pointer bump + overlay + snapshot)
EOF
