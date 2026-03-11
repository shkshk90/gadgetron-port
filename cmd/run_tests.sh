#!/usr/bin/env bash

set -euo pipefail

DIR_NAME=/volume/unit_tests/$(date +%y%m%d_%H%M%S)

CUDA_DIR=/volume/cuda.install
SYCL_DIR=/volume/sycl.install

FLAGS="--gtest_brief=1 --gtest_filter=cu*:-curve*"

mkdir -p /volume/unit_tests
mkdir -p "$DIR_NAME"

echo "Running CUDA tests"
${CUDA_DIR}/bin/test_all ${FLAGS} --gtest_output="json:${DIR_NAME}/cuda.json"

echo "Running sycl tests"
LD_LIBRARY_PATH=/dpcpp_home/install/lib:/oneMKLwithCublas/lib:/opt/intel/oneapi/2025.3/lib:\$LD_LIBRARY_PATH  \
    ${SYCL_DIR}/bin/test_all ${FLAGS} --gtest_output="json:${DIR_NAME}/sycl.json"

echo "Tests are done"
