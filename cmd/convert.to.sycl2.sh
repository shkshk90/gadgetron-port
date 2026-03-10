#!/usr/bin/env bash

set -euo pipefail


dpct \
    -p /volume/cuda.build \
    --in-root /gadgetron \
    --out-root /volume/gadgetron4 \
    --no-incremental-migration \
    --output-file=/volume/dpct.output2 \
    --stop-on-parse-err \
    --suppress-warnings-all \
    --sycl-file-extension=sycl-cpp \
    --sycl-named-lambda \
    --use-dpcpp-extensions=all \
    --use-experimental-features=all
