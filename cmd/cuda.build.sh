#!/usr/bin/env bash

set -euo pipefail

BUILD_DIR=/volume/cuda.build
INSTALL_DIR=/volume/cuda.install

mkdir -p ${INSTALL_DIR}


cmake --build ${BUILD_DIR} -j16 --config Release # --verbose # --target test_all
mkdir -p ${INSTALL_DIR}
cmake --install ${BUILD_DIR} --prefix  ${INSTALL_DIR} # --component test_all

echo "run :: "
echo "       ${INSTALL_DIR}/bin/test_all"