#!/bin/bash
# Copy .h and .xml files that exist in /gadgetron but not in /gadgetron2,
# preserving directory structure.

set -euo pipefail

SRC="/gadgetron"
DST="/gadgetron2"

count=0

find "$SRC" \( -name '*.h' -o -name '*.xml' \) -print0 |
while IFS= read -r -d '' file; do
    rel="${file#$SRC/}"
    dest="$DST/$rel"
    if [ ! -f "$dest" ]; then
        mkdir -p "$(dirname "$dest")"
        cp "$file" "$dest"
        echo "Copied: $rel"
        count=$((count + 1))
    fi
done

echo "Done. Copied missing .h and .xml files from $SRC to $DST."
