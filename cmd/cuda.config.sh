#!/usr/bin/env bash

set -euo pipefail

BUILD_DIR=/volume/cuda.build
INSTALL_DIR=/volume/cuda.install

mkdir -p ${BUILD_DIR}
find ${BUILD_DIR} -type d -name "CMakeFiles" -exec rm -rf {} + -o -type f -name "CMakeCache.txt" -delete

cmake                                                             \
  -S /gadgetron                                                   \
  -B ${BUILD_DIR}                                    \
  -G Ninja                                                        \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON                              \
  -DCMAKE_C_COMPILER=/dpcpp_home/install/bin/clang                \
  -DCMAKE_CXX_COMPILER=/dpcpp_home/install/bin/clang++            \
  -DBoost_NO_BOOST_CMAKE=TRUE                                     \
  -DBoost_NO_SYSTEM_PATHS=TRUE                                    \
  -DBOOST_ROOT:PATHNAME=/boost                                    \
  -DBoost_LIBRARY_DIRS:PATH=/boost/lib                            \
  -DISMRMRD_DIR:PATH=/ismrmrd/lib/cmake/ISMRMRD                   \
  -DHDF5_DIR:PATH=/libhdf5/./HDF_Group/HDF5/1.14.3/cmake          \
  -DPLPLOT_PATH:PATH=/plplot/include                              \
  -DPLPLOT_CXX_LIB:FILEPATH=/plplot/lib/libplplotcxx.so.15.0.0    \
  -DPLPLOT_LIB:FILEPATH=/plplot/lib/libplplot.so.17.0.0           \
  -DBUILD_PYTHON_SUPPORT=FALSE                                    \
  -DUSE_MKL=OFF                                                    \
  -DUSE_CUDA=ON                                                   \
  -DUSE_OPENMP=OFF                                                \
  -DCMAKE_INSTALL_PREFIX=/volume/cuda.install                     \
  -DBUILD_SUPPRESS_WARNINGS=TRUE                                  \
  -DBUILD_TESTING=ON                                              \
  -Wno-dev  