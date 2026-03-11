#!/usr/bin/env bash

set -euo pipefail

MODE="${1:-}"
if [[ "$MODE" != "cuda" && "$MODE" != "sycl" ]]; then
    echo "Usage: $0 <cuda|sycl>" >&2
    exit 1
fi

INSTALL_DIR="/volume/${MODE}.install"

if [[ "$MODE" == "sycl" ]]; then
    export LD_LIBRARY_PATH=/dpcpp_home/install/lib:${LD_LIBRARY_PATH:-}
fi

mkdir -p /volume/workarea/out

LD_LIBRARY_PATH=/ismrmrd/lib:/boost/lib:$LD_LIBRARY_PATH \
    /ismrmrd/bin/ismrmrd_generate_cartesian_shepp_logan --output /volume/workarea/testdata.h5


# launch gadgetron in background
${INSTALL_DIR}/bin/gadgetron &
GADGETRON_PID=$!
sleep 2

CONFIGS=(
    generic_gpusense_cg.xml
    generic_gpusense_cg_singleshot.xml
    generic_gpusense_sb_singleshot.xml
    generic_gpusense_nlcg_singleshot.xml
    generic_gpu_ktsense_singleshot.xml
    fixed_radial_mode0_gpusense_cg.xml
    fixed_radial_mode1_gpusense_cg.xml
    golden_radial_mode2_gpusense_cg.xml
    golden_radial_mode3_gpusense_cg.xml
    fixed_radial_mode0_gpusense_sb.xml
    fixed_radial_mode1_gpusense_sb.xml
    golden_radial_mode2_gpusense_sb.xml
    # golden_radial_mode2_gpusense_nlcg.xml
    golden_radial_mode3_gpusense_sb.xml
    fixed_radial_mode0_gpu_ktsense.xml
    fixed_radial_mode1_gpu_ktsense.xml
    golden_radial_mode2_gpu_ktsense.xml
    fixed_radial_mode0_gpusense_cg_unoptimized.xml
    fixed_radial_mode1_gpusense_cg_unoptimized.xml
    golden_radial_mode2_gpusense_cg_unoptimized.xml
    golden_radial_mode2_gpusense_nlcg_unoptimized.xml
    fixed_radial_mode0_gpusense_sb_unoptimized.xml
    fixed_radial_mode1_gpusense_sb_unoptimized.xml
    golden_radial_mode2_gpusense_sb_unoptimized.xml
)

TIMING_FILE=/volume/workarea/timing.${MODE}.txt
> "$TIMING_FILE"

for cfg in "${CONFIGS[@]}"; do
    echo "Running config: $cfg"
    START=$(date +%s%N)

    ${INSTALL_DIR}/bin/gadgetron_ismrmrd_client \
        --filename /volume/workarea/testdata.h5 \
        --outfile "/volume/workarea/out/${MODE}.${cfg%.xml}.h5" \
        --config "$cfg" # || true

    END=$(date +%s%N)
    ELAPSED=$(echo "scale=3; ($END - $START) / 1000000000" | bc)
    echo "$cfg $ELAPSED" >> "$TIMING_FILE"
    echo "  -> ${ELAPSED}s"

    sleep 1
done

sleep 2
kill "$GADGETRON_PID" 2>/dev/null && wait "$GADGETRON_PID" 2>/dev/null || true

