#!/usr/bin/env python3
"""
Plot timing comparison between CUDA and SYCL gtest JSON outputs.

Usage:
    python3 cmd/plot_test_comparison.py <directory>

Expects cuda.json and sycl.json in the given directory.
Outputs linear and logarithmic PNG plots in the same directory.
"""

import json
import sys
import re
from pathlib import Path
from collections import defaultdict

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np


def parse_time(s: str) -> float:
    """Parse gtest time string like '0.332s' or '1.2e-05s' to seconds."""
    return float(s.rstrip("s"))


def strip_type_suffix(name: str) -> str:
    """Strip /0, /1, etc. suffix to get the test family name."""
    return re.sub(r"/\d+$", "", name)


def load_family_times(path: Path) -> dict[str, float]:
    """Load JSON and aggregate suite times by family (stripping /N suffix)."""
    with open(path) as f:
        data = json.load(f)

    families: dict[str, float] = defaultdict(float)
    for suite in data["testsuites"]:
        family = strip_type_suffix(suite["name"])
        families[family] += parse_time(suite["time"])
    return dict(families)


def format_time(t: float) -> str:
    """Format time value for bar labels, number and unit on separate lines."""
    if t >= 1.0:
        return f"{t:.2f}\ns"
    if t >= 0.001:
        return f"{t * 1000:.1f}\nms"
    if t >= 0.000001:
        return f"{t * 1e6:.1f}\nus"
    return f"{t:.2e}\ns"


def wrap_family_name(name: str) -> str:
    """Replace underscores with newlines so labels fit without rotation."""
    return name.replace("_", "\n")


def plot(families: list[str], cuda_times: list[float], sycl_times: list[float],
         output_path: Path, log_scale: bool):
    n = len(families)
    x = np.arange(n)
    width = 0.38

    fig, ax = plt.subplots(figsize=(max(16, n * 1.2), 10), dpi=300)

    bars_cuda = ax.bar(x - width / 2, cuda_times, width, label="CUDA", color="#2196F3", zorder=3)
    bars_sycl = ax.bar(x + width / 2, sycl_times, width, label="SYCL", color="#FF9800", zorder=3)

    # Labels above bars
    for bar, t in zip(bars_cuda, cuda_times):
        y = bar.get_height()
        if y > 0:
            ax.text(bar.get_x() + bar.get_width() / 2, y, format_time(t),
                    ha="center", va="bottom", fontsize=9, rotation=0)

    for bar, t in zip(bars_sycl, sycl_times):
        y = bar.get_height()
        if y > 0:
            ax.text(bar.get_x() + bar.get_width() / 2, y, format_time(t),
                    ha="center", va="bottom", fontsize=9, rotation=0)

    ax.set_xlabel("Test Family", fontsize=12)
    ax.set_ylabel("Time (seconds)", fontsize=12)
    scale_label = "Logarithmic" if log_scale else "Linear"
    ax.set_title(f"CUDA vs SYCL Test Timing Comparison ({scale_label} Scale)", fontsize=14)
    wrapped = [wrap_family_name(f) for f in families]
    ax.set_xticks(x)
    ax.set_xticklabels(wrapped, rotation=0, ha="center", fontsize=12)
    ax.legend(fontsize=11)
    ax.grid(axis="y", alpha=0.3, zorder=0)

    if log_scale:
        ax.set_yscale("log")
        # Set a small floor so zero-time bars are still visible
        ax.set_ylim(bottom=1e-3, top=1e3)

    plt.tight_layout()
    fig.savefig(output_path, dpi=300)
    plt.close(fig)
    print(f"Saved: {output_path}")


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <directory>", file=sys.stderr)
        sys.exit(1)

    directory = Path(sys.argv[1])
    cuda_path = directory / "cuda.json"
    sycl_path = directory / "sycl.json"

    if not cuda_path.exists():
        print(f"Error: {cuda_path} not found", file=sys.stderr)
        sys.exit(1)
    if not sycl_path.exists():
        print(f"Error: {sycl_path} not found", file=sys.stderr)
        sys.exit(1)

    cuda_families = load_family_times(cuda_path)
    sycl_families = load_family_times(sycl_path)

    # Union of all families, sorted by name.
    # Only include families where at least one side took >= 2ms.
    MIN_TIME = 0.010  # 10ms
    all_families = sorted(
        f for f in set(cuda_families) | set(sycl_families)
        if cuda_families.get(f, 0.0) >= MIN_TIME and sycl_families.get(f, 0.0) >= MIN_TIME
    )

    cuda_times = [cuda_families.get(f, 0.0) for f in all_families]
    sycl_times = [sycl_families.get(f, 0.0) for f in all_families]

    # Replace exact zeros with a tiny value for log scale
    cuda_times_log = [max(t, 1e-5) for t in cuda_times]
    sycl_times_log = [max(t, 1e-5) for t in sycl_times]

    plot(all_families, cuda_times, sycl_times,
         directory / "comparison_linear.png", log_scale=False)
    plot(all_families, cuda_times_log, sycl_times_log,
         directory / "comparison_log.png", log_scale=True)


if __name__ == "__main__":
    main()
