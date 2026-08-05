#!/bin/bash
# The purpose of this script is to find all of the things I have modified outside of the "regular" PaperMod install
# and snapshot them into ventz-mods/ as a backup of the current customization overlay.
#
# NOTE: since PaperMod's Hugo 0.146+ restructure, the overlay uses:
#   layouts/            (was layouts/_default + layouts/partials -> now layouts/* + layouts/_partials)
#   assets/css/...      (unchanged location, but theme split typography into md-content.css)
set -e
cd "$(dirname "$0")"

dest="ventz-mods"
theme="themes/PaperMod"

# Start fresh so renamed/removed files don't linger from an older snapshot (keep the README)
rm -rf "$dest/layouts" "$dest/assets"
mkdir -p "$dest"

src_layouts="layouts"
echo "> Copying all custom $src_layouts"
cp -Rf "$src_layouts" "$dest"
echo ""

src_assets="assets"
# Get the list of differing files between the site assets and the theme's
# NOTE: full path for diff is needed in case we are overriding it in zsh (ex: adding color, which shifts the columns from 3->4)
files=$(/usr/bin/diff -rq "$src_assets" "$theme/$src_assets" 2>/dev/null | awk '/^Files /{print $2}')

echo "> Copying all changed $src_assets"
echo ""
# Copy each file, ensuring the directory structure is preserved
for file in $files; do
    echo "Changed File: $file"
    dest_path="$dest/$file"
    mkdir -p "$(dirname "$dest_path")"
    /bin/cp -f "$file" "$dest_path"
done

echo ""
echo "🎉 Files have been copied successfully!"
