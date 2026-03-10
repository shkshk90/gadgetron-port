#!/usr/bin/env bash

set -euo pipefail

# source /opt/intel/oneapi/setvars.sh 

dpct \
    -p /volume/cuda.build \
    --in-root /gadgetron \
    --out-root /gadgetron2 \
    --no-incremental-migration \
    --output-file=/volume/dpct.output \
    --stop-on-parse-err \
    --suppress-warnings-all \
    --sycl-file-extension=sycl-cpp \
    --sycl-named-lambda \
    --use-dpcpp-extensions=all \
    --use-experimental-features=all
