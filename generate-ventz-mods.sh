#!/bin/bash
# Snapshot every site-level customization into ventz-mods/ so it can be backed up,
# shared, and RE-APPLIED after a PaperMod (or Hugo) upgrade.
#
# What gets captured:
#   layouts/ assets/ static/ archetypes/ i18n/   (mirrored roots, theme-aware)
#   hugo.yaml                                    (layouts depend on its params)
#   patches/                                     (unified diffs vs the theme, for re-apply)
#   MANIFEST.md                                  (provenance: theme commit, Hugo version)
#   reapply.sh                                   (generated re-apply helper)
#
# Every file under a mirrored root is classified against themes/PaperMod:
#   - identical to the theme  -> skipped entirely (not a customization)
#   - differs from the theme  -> THEME OVERRIDE: copied + a .patch is emitted
#   - no theme counterpart    -> SITE-ONLY: copied verbatim
#
# NOTE: since PaperMod's Hugo 0.146+ restructure the overlay uses layouts/* and
# layouts/_partials/ (was layouts/_default/ and layouts/partials/).
set -euo pipefail
cd "$(dirname "$0")"

dest="ventz-mods"
theme="themes/PaperMod"

# Roots mirrored between the site and the theme (or site-only, handled the same way)
roots=(layouts assets static archetypes i18n)
# Single files copied verbatim from the site root
extra_files=(hugo.yaml)
# Generated/editor cruft that is not a customization
exclude_re='(^|/)(jsconfig\.json|\.DS_Store)$'

[ -d "$theme" ] || { echo "ERROR: theme submodule missing at $theme (git submodule update --init)"; exit 1; }

# Start fresh so renamed/removed files don't linger from an older snapshot (keep README.md)
for r in "${roots[@]}"; do /bin/rm -rf "${dest:?}/$r"; done
/bin/rm -rf "$dest/patches" "$dest/base"
mkdir -p "$dest/patches" "$dest/base"

overrides=()   # files that override a theme file
siteonly=()    # files with no theme counterpart
unmarked=()    # override files whose diff has hunks with no "Ventz Changes" marker

copy_into_dest() {   # $1 = site-relative path
    local dest_path="$dest/$1"
    mkdir -p "$(dirname "$dest_path")"
    /bin/cp -f "$1" "$dest_path"
}

# Turn a path into a flat patch filename: assets/css/core/reset.css -> assets__css__core__reset.css.patch
patch_name() { echo "${1//\//__}.patch"; }

echo "> Classifying customizations against $theme"
echo ""

for root in "${roots[@]}"; do
    [ -d "$root" ] || continue
    # -print0/read -d '' so paths with spaces survive (old version word-split on $files)
    while IFS= read -r -d '' f; do
        [[ "$f" =~ $exclude_re ]] && continue
        tf="$theme/$f"
        if [ -f "$tf" ]; then
            if /usr/bin/diff -q "$tf" "$f" >/dev/null 2>&1; then
                continue   # identical to the theme -> not a customization
            fi
            overrides+=("$f")
            copy_into_dest "$f"
            # Pristine theme version = the merge BASE for reapply.sh. Storing it makes
            # the snapshot self-contained (no dependency on submodule history).
            mkdir -p "$(dirname "$dest/base/$f")"
            /bin/cp -f "$tf" "$dest/base/$f"
            # Human-readable diff for review/sharing. || true: diff exits 1 when files differ.
            /usr/bin/diff -u -L "a/$f" -L "b/$f" "$tf" "$f" > "$dest/patches/$(patch_name "$f")" || true
            echo "  override : $f"
        else
            siteonly+=("$f")
            copy_into_dest "$f"
            echo "  site-only: $f"
        fi
    done < <(find "$root" -type f -print0 | sort -z)
done

for f in "${extra_files[@]}"; do
    [ -f "$f" ] || continue
    siteonly+=("$f")
    copy_into_dest "$f"
    echo "  site-only: $f"
done

# ---------------------------------------------------------------------------
# Marker coverage: every hunk in an override patch should carry a "Ventz Changes"
# marker, so an upstream merge conflict is self-explaining. Report any that don't.
# ---------------------------------------------------------------------------
echo ""
echo "> Checking 'Ventz Changes' marker coverage"
for f in "${overrides[@]}"; do
    p="$dest/patches/$(patch_name "$f")"
    # Hunks with added/changed lines but no marker anywhere in the hunk body.
    bad=$(awk '
        /^@@/ { if (hunk && added && !marked) print hdr; hunk=1; added=0; marked=0; hdr=$0; next }
        hunk && /^[+]/ { added=1 }
        hunk && /Ventz Changes/ { marked=1 }
        END { if (hunk && added && !marked) print hdr }
    ' "$p")
    if [ -n "$bad" ]; then
        unmarked+=("$f")
        echo "  ⚠ UNMARKED HUNK(S) in $f:"
        echo "$bad" | sed 's/^/      /'
    fi
done
[ ${#unmarked[@]} -eq 0 ] && echo "  all ${#overrides[@]} override files fully marked"

# ---------------------------------------------------------------------------
# Provenance + re-apply helper
# ---------------------------------------------------------------------------
theme_commit=$(git -C "$theme" rev-parse HEAD)
theme_short=$(git -C "$theme" rev-parse --short HEAD)
theme_date=$(git -C "$theme" log -1 --format=%cs)
theme_remote=$(git -C "$theme" remote get-url origin 2>/dev/null || echo "unknown")
theme_min=$(awk -F'"' '/min_version/{print $2}' "$theme/theme.toml" 2>/dev/null || echo "unknown")
hugo_ver=$(hugo version 2>/dev/null | awk '{print $2}' || echo "unknown")
gen_date=$(date +%Y-%m-%d)

{
    echo "# MANIFEST — ventz-mods snapshot"
    echo ""
    echo "**Generated:** $gen_date by \`generate-ventz-mods.sh\` (do not edit by hand)"
    echo ""
    echo "## Base this overlay was built against"
    echo ""
    echo "| | |"
    echo "|---|---|"
    echo "| PaperMod commit | \`$theme_commit\` (\`$theme_short\`, $theme_date) |"
    echo "| PaperMod remote | $theme_remote |"
    echo "| Theme min Hugo  | $theme_min |"
    echo "| Hugo used       | $hugo_ver |"
    echo ""
    echo "The patches in \`patches/\` are diffs **from that exact theme commit**. Re-apply"
    echo "them after an upstream merge with \`./ventz-mods/reapply.sh\` (see README)."
    echo ""
    echo "## Theme overrides (${#overrides[@]}) — modified copies of theme files"
    echo ""
    echo "These conflict with upstream changes. Each has a patch in \`patches/\`."
    echo ""
    for f in "${overrides[@]}"; do
        adds=$(grep -c '^+[^+]' "$dest/patches/$(patch_name "$f")" || true)
        dels=$(grep -c '^-[^-]' "$dest/patches/$(patch_name "$f")" || true)
        echo "- \`$f\` — +$adds/-$dels"
    done
    echo ""
    echo "## Site-only files (${#siteonly[@]}) — no theme counterpart"
    echo ""
    echo "These never conflict; copy them in as-is."
    echo ""
    for f in "${siteonly[@]}"; do echo "- \`$f\`"; done
    echo ""
    if [ ${#unmarked[@]} -gt 0 ]; then
        echo "## ⚠ Unmarked hunks"
        echo ""
        echo "These override files contain changes with no \`Ventz Changes\` marker —"
        echo "add one so the intent survives an upstream merge:"
        echo ""
        for f in "${unmarked[@]}"; do echo "- \`$f\`"; done
        echo ""
    fi
} > "$dest/MANIFEST.md"

{
    echo "#!/bin/bash"
    echo "# GENERATED by generate-ventz-mods.sh on $gen_date — do not edit by hand."
    echo "#"
    echo "# Re-applies the Ventz overlay after a PaperMod upgrade (or onto a fresh site)."
    echo "# Snapshot base: PaperMod $theme_short ($theme_date), Hugo $hugo_ver."
    echo "#"
    echo "# Run from the SITE ROOT, with the theme submodule already updated:"
    echo "#   ./ventz-mods/reapply.sh"
    echo "#"
    echo "# Site-only files are copied verbatim. Theme overrides are resolved by a real"
    echo "# 3-way merge (git merge-file):"
    echo "#     base   = ventz-mods/base/<f>   the theme file this overlay was built on"
    echo "#     ours   = ventz-mods/<f>        the customized version"
    echo "#     theirs = themes/PaperMod/<f>   the NEW upstream version"
    echo "# Non-overlapping upstream changes merge silently; overlapping ones land as"
    echo "# <<<<<<< conflict markers. (BSD patch on macOS has no --merge, hence git.)"
    echo "set -uo pipefail"
    echo "cd \"\$(dirname \"\$0\")/..\""
    echo "mods=\"ventz-mods\""
    echo "theme=\"themes/PaperMod\""
    echo "fail=0"
    echo ""
    echo "# Safety: never silently clobber a site-only file that has drifted from the"
    echo "# snapshot (e.g. hugo.yaml edited since the last generate). FORCE=1 overrides."
    echo 'copy_site_only() {   # $1 = site-relative path'
    echo '    local f="$1"'
    echo '    if [ -f "$f" ] && ! /usr/bin/diff -q "$mods/$f" "$f" >/dev/null 2>&1 && [ "${FORCE:-0}" != "1" ]; then'
    echo '        echo "    SKIPPED  : $f differs from the snapshot — re-run with FORCE=1 to overwrite"; fail=1; return'
    echo '    fi'
    echo '    mkdir -p "$(dirname "$f")"; /bin/cp -f "$mods/$f" "$f"'
    echo '}'
    echo ""
    echo "echo '> Copying site-only files'"
    for f in "${siteonly[@]}"; do
        printf 'copy_site_only %q\n' "$f"
    done
    echo ""
    echo 'merge_override() {   # $1 = site-relative path'
    echo '    local f="$1"'
    echo '    if [ ! -f "$theme/$f" ]; then'
    echo '        echo "    GONE     : $f no longer exists in the theme — snapshot copy used verbatim"'
    echo '        mkdir -p "$(dirname "$f")"; /bin/cp -f "$mods/$f" "$f"; fail=1; return'
    echo '    fi'
    echo '    mkdir -p "$(dirname "$f")"'
    echo '    /bin/cp -f "$mods/$f" "$f"          # ours -> working file, merged in place'
    echo '    if git merge-file \'
    echo '            -L "Ventz overlay" -L "PaperMod base ('"$theme_short"')" -L "PaperMod (new)" \'
    echo '            "$f" "$mods/base/$f" "$theme/$f"; then'
    echo '        if /usr/bin/diff -q "$mods/$f" "$f" >/dev/null 2>&1; then'
    echo '            echo "    ok       : $f (upstream unchanged here)"'
    echo '        else'
    echo '            echo "    merged   : $f (upstream changes folded in cleanly)"'
    echo '        fi'
    echo '    else'
    echo '        echo "    CONFLICT : $f  <-- resolve the <<<<<<< markers, keep the Ventz Changes intent"; fail=1'
    echo '    fi'
    echo '}'
    echo ""
    echo "echo '> Re-applying theme overrides (3-way merge)'"
    for f in "${overrides[@]}"; do
        printf 'merge_override %q\n' "$f"
    done
    echo ""
    echo "echo ''"
    echo "if [ \$fail -eq 0 ]; then"
    echo "    echo '🎉 Overlay re-applied cleanly. Rebuild: hugo server -D --disableFastRender'"
    echo "else"
    echo "    echo '⚠ Re-applied with conflicts — resolve them, then run ./generate-ventz-mods.sh'"
    echo "fi"
    echo "exit \$fail"
} > "$dest/reapply.sh"
chmod +x "$dest/reapply.sh"

echo ""
echo "> Wrote $dest/MANIFEST.md and $dest/reapply.sh"
echo "  ${#overrides[@]} theme overrides (+ patches), ${#siteonly[@]} site-only files"
echo ""
echo "🎉 Files have been copied successfully!"
