#!/bin/bash
# The purpose of this script is to find all of the things I have modified outside of the "regular" PaperMod install
dest="ventz-mods"
mkdir -p "$dest"

src_layouts="layouts"
echo "> Copying all custom $src_layouts"
cp -rf $src_layouts $dest
echo ""

src_assets="assets"
# Get the list of differing files between the two directories
# NOTE: full path for diff is needed in case we are overriding it in zsh (ex: adding color, which shifts the columns from 3->4)
files=$(/usr/bin/diff -r $src_assets themes/PaperMod/$src_assets | grep 'diff' | awk '{print $3}')

echo "> Copying all changed $src_assets"
echo ""
# Copy each file, ensuring the directory structure is preserved
for file in $files; do
    echo "Changed File: $file"
    # Get the full path for the destination
    dest_path="$dest/$file"

    # Create the directory structure in the destination
    mkdir -p "$(dirname "$dest_path")"

    # Copy the file
    cp -f "$file" "$dest_path"
done

echo ""
echo "🎉 Files have been copied successfully!"

