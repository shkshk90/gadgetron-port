#!/usr/bin/env bash

set -euo pipefail

BUILD_DIR=/volume/sycl.build
INSTALL_DIR=/volume/sycl.install

ZE_INCLUDE=/dpcpp_home/_deps/level-zero-loader-src/include
DPL_INCLUDE=/opt/intel/oneapi/dpl/2022.10/include

mkdir -p ${BUILD_DIR}
rm -rf ${BUILD_DIR}/*

cmake                                                             \
  -S /gadgetron2                                                  \
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
  -DUSE_MKL=OFF                                                   \
  -DUSE_SYCL=ON                                                   \
  -DUSE_OPENMP=OFF                                                \
  -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}                           \
  -DBUILD_SUPPRESS_WARNINGS=TRUE                                  \
  -DBUILD_TESTING=ON                                              \
  -DONEMKL_PATH=/oneMKLwithCublas                                 \
  -DLIBSYCL=/dpcpp_home/install/lib/libsycl.so                    \
  -DDPCT_INCLUDE_PATH=/opt/intel/oneapi/dpcpp-ct/2025.3/include   \
  -DZERO_LEVEL_INCLUDE_PATH=${ZE_INCLUDE}                         \
  -DONEAPI_DPL_INCLUDE_PATH=${DPL_INCLUDE}                        \
  -DMKL_INCLUDE_PATH=/oneMKLwithCublas/include                    \
  -DSYCL_INCLUDE_PATH=/dpcpp_home/include                         \
  -Wno-dev  