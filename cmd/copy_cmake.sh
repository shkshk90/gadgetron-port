#!/bin/bash
# Copy all CMake files from gadgetron/ to gadgetron2/ preserving directory structure.

set -euo pipefail

SRC="/gadgetron"
DST="/gadgetron2"

# Find all CMake-related files: CMakeLists.txt, *.cmake, *.cmake.in
find "$SRC" \( -name 'CMakeLists.txt' -o -name '*.cmake' -o -name '*.cmake.in' \) -print0 |
while IFS= read -r -d '' file; do
    rel="${file#$SRC/}"
    dest="$DST/$rel"
    mkdir -p "$(dirname "$dest")"
    cp "$file" "$dest"
done

echo "Copied all CMake files from gadgetron/ to gadgetron2/"
