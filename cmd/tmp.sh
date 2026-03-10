SRC_ROOT="/gadgetron"
DST_ROOT="/volume/gadgetron2"
cu_file=${SRC_ROOT}/toolboxes/nfft/gpu/cuNFFT.cu

dpct --extra-arg=-I/boost/include --extra-arg=-I/gadgetron/apps/gadgetron --extra-arg=-I/gadgetron/core --extra-arg=-I/gadgetron/gadgets/mri_core --extra-arg=-I/gadgetron/toolboxes --extra-arg=-I/gadgetron/toolboxes/cmr --extra-arg=-I/gadgetron/toolboxes/core --extra-arg=-I/gadgetron/toolboxes/core/cpu --extra-arg=-I/gadgetron/toolboxes/core/cpu/algorithm --extra-arg=-I/gadgetron/toolboxes/core/cpu/hostutils --extra-arg=-I/gadgetron/toolboxes/core/cpu/image --extra-arg=-I/gadgetron/toolboxes/core/cpu/math --extra-arg=-I/gadgetron/toolboxes/core/gpu --extra-arg=-I/gadgetron/toolboxes/denoise --extra-arg=-I/gadgetron/toolboxes/dwt/cpu --extra-arg=-I/gadgetron/toolboxes/dwt/gpu/ --extra-arg=-I/gadgetron/toolboxes/ffd --extra-arg=-I/gadgetron/toolboxes/fft/cpu --extra-arg=-I/gadgetron/toolboxes/fft/gpu --extra-arg=-I/gadgetron/toolboxes/image/cpu --extra-arg=-I/gadgetron/toolboxes/image_io --extra-arg=-I/gadgetron/toolboxes/klt/cpu --extra-arg=-I/gadgetron/toolboxes/log --extra-arg=-I/gadgetron/toolboxes/mri/hyper --extra-arg=-I/gadgetron/toolboxes/mri/pmri/gpu --extra-arg=-I/gadgetron/toolboxes/mri/sdc --extra-arg=-I/gadgetron/toolboxes/mri/sdc/cpu --extra-arg=-I/gadgetron/toolboxes/mri/sdc/cpu/.. --extra-arg=-I/gadgetron/toolboxes/mri/sdc/gpu --extra-arg=-I/gadgetron/toolboxes/mri_core --extra-arg=-I/gadgetron/toolboxes/mri_image --extra-arg=-I/gadgetron/toolboxes/nfft --extra-arg=-I/gadgetron/toolboxes/nfft/cpu --extra-arg=-I/gadgetron/toolboxes/nfft/cpu/.. --extra-arg=-I/gadgetron/toolboxes/nfft/gpu --extra-arg=-I/gadgetron/toolboxes/operators --extra-arg=-I/gadgetron/toolboxes/operators/cpu --extra-arg=-I/gadgetron/toolboxes/operators/gpu --extra-arg=-I/gadgetron/toolboxes/pattern_recognition --extra-arg=-I/gadgetron/toolboxes/registration/optical_flow/ --extra-arg=-I/gadgetron/toolboxes/registration/optical_flow/cpu --extra-arg=-I/gadgetron/toolboxes/registration/optical_flow/cpu/.. --extra-arg=-I/gadgetron/toolboxes/registration/optical_flow/cpu/application --extra-arg=-I/gadgetron/toolboxes/registration/optical_flow/cpu/dissimilarity --extra-arg=-I/gadgetron/toolboxes/registration/optical_flow/cpu/register --extra-arg=-I/gadgetron/toolboxes/registration/optical_flow/cpu/solver --extra-arg=-I/gadgetron/toolboxes/registration/optical_flow/cpu/transformation --extra-arg=-I/gadgetron/toolboxes/registration/optical_flow/cpu/warper --extra-arg=-I/gadgetron/toolboxes/registration/optical_flow/gpu --extra-arg=-I/gadgetron/toolboxes/solvers --extra-arg=-I/gadgetron/toolboxes/solvers/cpu --extra-arg=-I/gadgetron/toolboxes/solvers/gpu --extra-arg=-I/ismrmrd/include --extra-arg=-I/usr/include --extra-arg=-I/usr/include/hdf5/serial --extra-arg=-I/usr/include/x86_64-linux-gnu --extra-arg=-I/usr/local/cuda/include --extra-arg=-I/volume/cuda.build/include --extra-arg=-I/volume/cuda.build/toolboxes/core  \
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
    ${SRC_ROOT}/toolboxes/nfft/gpu/cuNFFT.cu \
    ${SRC_ROOT}/toolboxes/nfft/gpu/cuGriddingConvolution.cu