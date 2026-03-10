#!/usr/bin/env bash

set -euo pipefail

BUILD_DIR=/volume/sycl.build
INSTALL_DIR=/volume/sycl.install

mkdir -p ${INSTALL_DIR}


cmake --build ${BUILD_DIR} -j16 --config Release # --verbose # --target test_all
mkdir -p ${INSTALL_DIR}
cmake --install ${BUILD_DIR} --prefix  ${INSTALL_DIR} # --component test_all

echo "run :: "
echo "       LD_LIBRARY_PATH=/dpcpp_home/install/lib:/oneMKLwithCublas/lib:/opt/intel/oneapi/2025.3/lib:\$LD_LIBRARY_PATH  ${INSTALL_DIR}/bin/test_all"