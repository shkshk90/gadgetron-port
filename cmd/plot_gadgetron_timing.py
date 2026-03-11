#!/usr/bin/env python3
"""
Plot horizontal bar comparison of CUDA vs SYCL gadgetron run timings.

Usage:
    python3 cmd/plot_gadgetron_timing.py <directory>

Expects timing.cuda.txt and timing.sycl.txt in the given directory.
"""

import sys
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np


def load_timings(path: Path) -> dict[str, float]:
    timings = {}
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            parts = line.rsplit(maxsplit=1)
            name = parts[0].removesuffix(".xml")
            timings[name] = float(parts[1])
    return timings


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <directory>", file=sys.stderr)
        sys.exit(1)

    directory = Path(sys.argv[1])
    cuda_path = directory / "timing.cuda.txt"
    sycl_path = directory / "timing.sycl.txt"

    if not cuda_path.exists():
        print(f"Error: {cuda_path} not found", file=sys.stderr)
        sys.exit(1)
    if not sycl_path.exists():
        print(f"Error: {sycl_path} not found", file=sys.stderr)
        sys.exit(1)

    cuda = load_timings(cuda_path)
    sycl = load_timings(sycl_path)

    configs = sorted(
        c for c in set(cuda) | set(sycl)
        if cuda.get(c, 0.0) >= 10.0 or sycl.get(c, 0.0) >= 10.0
    )

    cuda_times = [cuda.get(c, 0.0) for c in configs]
    sycl_times = [sycl.get(c, 0.0) for c in configs]

    # Replace zeros with small value for log scale
    cuda_times_plot = [max(t, 1e-4) for t in cuda_times]
    sycl_times_plot = [max(t, 1e-4) for t in sycl_times]

    n = len(configs)
    y = np.arange(n)
    height = 0.38

    fig, ax = plt.subplots(figsize=(14, max(8, n * 0.55)), dpi=300)

    bars_sycl = ax.barh(y + height / 2, sycl_times_plot, height,
                        label="SYCL", color="#FF9800", zorder=3)
    bars_cuda = ax.barh(y - height / 2, cuda_times_plot, height,
                        label="CUDA", color="#2196F3", zorder=3)

    # Labels on bars
    for bar, t in zip(bars_cuda, cuda_times):
        w = bar.get_width()
        label = f"{t:.3f}s" if t >= 1 else f"{t * 1000:.1f}ms"
        ax.text(w * 1.15, bar.get_y() + bar.get_height() / 2, label,
                va="center", ha="left", fontsize=8)

    for bar, t in zip(bars_sycl, sycl_times):
        w = bar.get_width()
        label = f"{t:.3f}s" if t >= 1 else f"{t * 1000:.1f}ms"
        ax.text(w * 1.15, bar.get_y() + bar.get_height() / 2, label,
                va="center", ha="left", fontsize=8)

    ax.set_xscale("log")
    ax.set_xlabel("Time (seconds, log scale)", fontsize=12)
    ax.set_yticks(y)
    ax.set_yticklabels(configs, fontsize=9)
    ax.set_title("CUDA vs SYCL Gadgetron Config Timing Comparison", fontsize=14)
    ax.legend(fontsize=11, loc="lower right")
    ax.grid(axis="x", alpha=0.3, zorder=0)
    ax.invert_yaxis()

    plt.tight_layout()
    out_path = directory / "gadgetron_timing_comparison.png"
    fig.savefig(out_path, dpi=300)
    plt.close(fig)
    print(f"Saved: {out_path}")


if __name__ == "__main__":
    main()
