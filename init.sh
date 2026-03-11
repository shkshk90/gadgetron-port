#!/usr/bin/env bash

set -euo pipefail

REPO_URL="git@github.com:shkshk90/gadgetron.git"

step() {
    echo ""
    echo "============================================"
    echo "  $1"
    echo "============================================"
    read -rp "Press Enter to continue (Ctrl+C to abort)..."
    echo ""
}

run() {
    echo "+ $*"
    "$@"
}

# ── Step 1: Clone CUDA branch ──────────────────────────────────────────
step "Clone gadgetron (branch 4/0.cuda) → ./gadgetron"

if [ -d "gadgetron" ]; then
    echo "Directory 'gadgetron' already exists, skipping clone."
else
    run git clone -b 4/0.cuda "$REPO_URL" gadgetron
fi

# ── Step 2: Clone SYCL/migrated branch ─────────────────────────────────
step "Clone gadgetron (branch 4/1.migrated) → ./gadgetron2"

if [ -d "gadgetron2" ]; then
    echo "Directory 'gadgetron2' already exists, skipping clone."
else
    run git clone -b 4/1.migrated "$REPO_URL" gadgetron2
fi

# ── Step 3: Docker build & start ────────────────────────────────────────
step "Build and start Docker container"

run docker compose build
run docker compose up -d

# ── Step 4: Install oneMath/MKL inside container ───────────────────────
step "Install oneMath (MKL with cuBLAS backend)"

run docker compose exec gadgetron2 /cmd/install_mkl.sh

# ── Step 5: Configure CUDA build ───────────────────────────────────────
step "Configure CUDA build"

run docker compose exec gadgetron2 /cmd/cuda.config.sh

# ── Step 6: Build CUDA ─────────────────────────────────────────────────
step "Build CUDA"

run docker compose exec gadgetron2 /cmd/cuda.build.sh

# ── Step 7: Configure SYCL build ───────────────────────────────────────
step "Configure SYCL build"

run docker compose exec gadgetron2 /cmd/sycl.config.sh

# ── Step 8: Build SYCL ─────────────────────────────────────────────────
step "Build SYCL"

run docker compose exec gadgetron2 /cmd/sycl.build.sh

# ── Step 9: Run tests (CUDA + SYCL) ────────────────────────────────────
step "Run unit tests (CUDA and SYCL)"

run docker compose exec gadgetron2 /cmd/run_tests.sh

# ── Step 10: Plot comparison ────────────────────────────────────────────
step "Plot test timing comparison"

# Find the latest test output directory
LATEST_DIR=$(ls -dt volume/unit_tests/*/ 2>/dev/null | head -1)

if [ -z "$LATEST_DIR" ]; then
    echo "Error: No test output found under volume/unit_tests/"
    exit 1
fi

echo "Using test results from: $LATEST_DIR"
run python3 cmd/plot_test_comparison.py "$LATEST_DIR"

# ── Done ────────────────────────────────────────────────────────────────
echo ""
echo "============================================"
echo "  Done!"
echo "============================================"
echo ""
echo "Results are in: $LATEST_DIR"
echo "  - cuda.json              CUDA test results"
echo "  - sycl.json              SYCL test results"
echo "  - comparison_linear.png  Linear scale plot"
echo "  - comparison_log.png     Log scale plot"
