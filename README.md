# Gadgetron CUDA → SYCL Migration

## Quick Start

Run `./init.sh` to execute all steps interactively, or follow them manually below.

### 1. Clone the repositories

```sh
# Original CUDA codebase
git clone -b 4/0.cuda git@github.com:shkshk90/gadgetron.git gadgetron

# SYCL-migrated codebase
git clone -b 4/1.migrated git@github.com:shkshk90/gadgetron.git gadgetron2
```

### 2. Build and start Docker

```sh
# Builds the image with CUDA 12.8, Intel DPC++, Boost, ISMRMRD, etc.
docker compose build
docker compose up -d
```

### 3. Install oneMath (MKL with cuBLAS backend)

```sh
# Builds oneMath v0.9 with cuBLAS/cuFFT/cuRAND/cuSOLVER/cuSPARSE backends
docker compose exec gadgetron2 /cmd/install_mkl.sh
```

### 4. Configure and build CUDA

```sh
docker compose exec gadgetron2 /cmd/cuda.config.sh   # CMake configure
docker compose exec gadgetron2 /cmd/cuda.build.sh     # Build + install
```

### 5. Configure and build SYCL

```sh
docker compose exec gadgetron2 /cmd/sycl.config.sh   # CMake configure
docker compose exec gadgetron2 /cmd/sycl.build.sh     # Build + install
```

### 6. Run unit tests

```sh
# Runs both CUDA and SYCL test suites, outputs JSON results to volume/unit_tests/<timestamp>/
docker compose exec gadgetron2 /cmd/run_tests.sh
```

### 7. Plot comparison

```sh
# Generate timing comparison plots (run from host)
python3 cmd/plot_test_comparison.py volume/unit_tests/<timestamp>/
```

Output is saved under `volume/unit_tests/<timestamp>/`:
- `cuda.json` — CUDA test results
- `sycl.json` — SYCL test results
- `comparison_linear.png` — Linear scale timing comparison
- `comparison_log.png` — Logarithmic scale timing comparison

---

## How to run Gadgetron

```sh
gadgetron -s -c config.xml < input.h5 > output.h5
```

## Analysis

1. **Server Mode** (default): The gadgetron binary runs as a TCP server on port 9002. Clients connect via gadgetron_ismrmrd_client.

2. **Streaming Mode** (embedded, no network): The same gadgetron binary supports a `-s` / `--from_stream` flag that bypasses networking entirely. This uses StreamConsumer to process data from stdin/stdout or files — no server, no sockets, no forking.

## Post-migration fixes

- `alignas(16)` issue with `axpy` and complex doubles
- dpct_holders and missing kernel names
- Some mis-translated stuff, like the clash with `spmv`
- Replacing `axpy` with a custom kernel
- `sycl::ext::oneapi::experimental::use_root_sync` issue, that caused `CUDA_ERROR_COOPERATIVE_LAUNCH_TOO_LARGE` issue at runtime
- Device pointer dereference segfault: Replaced `*mm_pair.first`/`*mm_pair.second` with explicit `queue.memcpy` to safely copy values from device to host
