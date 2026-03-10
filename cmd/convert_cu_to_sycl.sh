#!/usr/bin/env bash
# Convert .cu files from /gadgetron to SYCL using dpct, one by one.
# Extracts include directories and flags from the CUDA build's cmake scripts.
# Places output under /gadgetron2/ preserving directory structure.

set -euo pipefail

BUILD_DIR="/volume/cuda.build"
SRC_ROOT="/gadgetron"
DST_ROOT="/volume/gadgetron2"
LOG_DIR="/volume/dpct_cu_logs"

mkdir -p "$LOG_DIR"

# Find all .cu.o.Release.cmake files (these contain the nvcc flags/includes)
mapfile -t cmake_scripts < <(find "$BUILD_DIR" -name '*_generated_*.cu.o.Release.cmake' 2>/dev/null)

if [ ${#cmake_scripts[@]} -eq 0 ]; then
    echo "ERROR: No CUDA cmake scripts found in $BUILD_DIR"
    exit 1
fi

echo "Found ${#cmake_scripts[@]} .cu files to convert"

success=0
fail=0
skip=0

for script in "${cmake_scripts[@]}"; do
    # Extract source .cu file path from the cmake script
    cu_file=$(grep 'set(source_file' "$script" | grep -oP '"[^"]*\.cu"' | tr -d '"')
    if [ -z "$cu_file" ]; then
        echo "SKIP: Could not extract source file from $script"
        skip=$((skip + 1))
        continue
    fi

    if [ ! -f "$cu_file" ]; then
        echo "SKIP: Source file not found: $cu_file"
        skip=$((skip + 1))
        continue
    fi

    # Compute relative path and destination
    rel_path="${cu_file#$SRC_ROOT/}"
    dst_dir="$DST_ROOT/$(dirname "$rel_path")"
    basename_cu=$(basename "$cu_file")
    logfile="$LOG_DIR/${basename_cu}.log"

    # Extract include dirs from the cmake script
    include_dirs=$(grep 'set(CUDA_NVCC_INCLUDE_DIRS' "$script" \
        | grep -oP '\[==\[.*?\]==\]' \
        | sed 's/\[==\[//;s/\]==\]//' \
        | tr ';' '\n' \
        | grep -v '^$' \
        | sort -u)

    # Build --extra-arg=-I flags for dpct
    extra_args=""
    while IFS= read -r dir; do
        [ -n "$dir" ] && extra_args="$extra_args --extra-arg=-I$dir"
    done <<< "$include_dirs"

    mkdir -p "$dst_dir"

    echo "Converting: $cu_file"
    echo "  -> $dst_dir/"

    # Run dpct on single .cu file
    if dpct \
        --in-root "$SRC_ROOT" \
        --out-root "$DST_ROOT" \
        --cuda-include-path=/usr/local/cuda/include \
        $extra_args \
        --extra-arg="-std=c++17" \
        --extra-arg="-DUSE_CUDA" \
        --extra-arg="-D__CUDACC__" \
        --no-incremental-migration \
        --sycl-file-extension=sycl-cpp \
        --sycl-named-lambda \
        --use-dpcpp-extensions=all \
        --use-experimental-features=all \
        --suppress-warnings-all \
        "$cu_file" \
        > "$logfile" 2>&1; then
        echo "  OK"
        success=$((success + 1))
    else
        echo "  FAILED (see $logfile)"
        fail=$((fail + 1))
    fi
done

echo ""
echo "Done: $success succeeded, $fail failed, $skip skipped (out of ${#cmake_scripts[@]} total)"
