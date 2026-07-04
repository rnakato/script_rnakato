#!/usr/bin/env python
"""
roadmap_chromstate_matrix_v3.py

Draw a Roadmap-style chromatin-state matrix:
rows = samples, columns = genomic position, colors = chromatin states.

Key defaults in v3:
- The order in samples.tsv is preserved.
- Earlier samples in samples.tsv are drawn at the top.
- Later samples in samples.tsv are drawn at the bottom.
- No horizontal separator lines are drawn unless --group-separators is used.
- --row-height is available and controls the vertical space per sample.
- Long sample labels are handled by automatic left margins and optional wrapping/truncation.

Input samples.tsv:
    sample  group   bed
    E003    ESC     /path/E003_15_coreMarks_dense.bed.gz
    E004    ESC     /path/E004_15_coreMarks_dense.bed.gz

The group column is optional. The BED file must have at least four columns:
chrom, start, end, state. Roadmap/ChromHMM labels such as 1_TssA, E1_TssA,
E1, or 1 are accepted.
"""

from __future__ import annotations

import argparse
import gzip
import json
import os
import re
import shutil
import subprocess
import sys
import textwrap
from collections import defaultdict
from dataclasses import dataclass
from typing import Dict, Iterator, List, Optional, Sequence, Tuple

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
from matplotlib.collections import PatchCollection
from matplotlib.patches import FancyArrowPatch, Patch, Rectangle
import pandas as pd

ROADMAP15 = {
    "1_TssA": ("Active TSS", "#ff0000"),
    "2_TssAFlnk": ("Flanking active TSS", "#ff4500"),
    "3_TxFlnk": ("Transcription at gene 5'/3'", "#32cd32"),
    "4_Tx": ("Strong transcription", "#008000"),
    "5_TxWk": ("Weak transcription", "#006400"),
    "6_EnhG": ("Genic enhancer", "#c2e105"),
    "7_Enh": ("Enhancer", "#ffff00"),
    "8_ZNF/Rpts": ("ZNF genes & repeats", "#66cdaa"),
    "9_Het": ("Heterochromatin", "#8a91d0"),
    "10_TssBiv": ("Bivalent TSS", "#cd5c5c"),
    "11_BivFlnk": ("Flanking bivalent TSS/enh", "#e9967a"),
    "12_EnhBiv": ("Bivalent enhancer", "#bdb76b"),
    "13_ReprPC": ("Repressed Polycomb", "#808080"),
    "14_ReprPCWk": ("Weak repressed Polycomb", "#c0c0c0"),
    "15_Quies": ("Quiescent/low", "#ffffff"),
}

ROADMAP18 = {
    **ROADMAP15,
    "16_Quies": ("Quiescent/low", "#ffffff"),
    "17_ReprPCWk": ("Weak repressed Polycomb", "#c0c0c0"),
    "18_EnhA": ("Active enhancer", "#faca00"),
}


@dataclass
class Sample:
    sample: str
    group: str
    bed: str


@dataclass
class Region:
    chrom: str
    start: int
    end: int
    name: str


def open_text(path: str):
    return gzip.open(path, "rt") if path.endswith(".gz") else open(path, "rt")


def state_number(x: str) -> Optional[int]:
    m = re.match(r"^[A-Za-z]?(\d+)", str(x).strip())
    return int(m.group(1)) if m else None


def norm_state(x: str) -> str:
    s = str(x).strip().replace(" ", "_")
    n = state_number(s)
    if n is None:
        return s
    for key in ROADMAP18:
        if key.startswith(f"{n}_"):
            return key
    return str(n)


def load_colors(path: Optional[str], model: str) -> Tuple[Dict[str, str], Dict[str, str]]:
    base = ROADMAP18 if model == "roadmap18" else ROADMAP15
    colors: Dict[str, str] = {}
    labels: Dict[str, str] = {}

    for key, (label, color) in base.items():
        n = state_number(key)
        keys = {key, norm_state(key)}
        if n is not None:
            keys.update({str(n), f"E{n}", f"E{n}_{key.split('_', 1)[1]}"})
        for k in keys:
            colors[norm_state(k)] = color
            labels[norm_state(k)] = key

    if path is None:
        return colors, labels

    if path.endswith(".json"):
        with open(path) as f:
            user = json.load(f)
        for state, value in user.items():
            if isinstance(value, dict):
                color = value.get("color", "#000000")
                label = value.get("label", state)
            else:
                color = str(value)
                label = state
            colors[norm_state(state)] = color
            labels[norm_state(state)] = label
    else:
        with open_text(path) as f:
            for line in f:
                if not line.strip() or line.startswith("#"):
                    continue
                fields = line.rstrip("\n").split("\t")
                if len(fields) < 2:
                    continue
                state, color = fields[0], fields[1]
                label = fields[2] if len(fields) >= 3 else state
                colors[norm_state(state)] = color
                labels[norm_state(state)] = label

    return colors, labels


def parse_region(s: str) -> Region:
    m = re.match(r"^(\S+):(\d[\d,]*)-(\d[\d,]*)$", s)
    if not m:
        raise ValueError(f"Invalid region: {s}. Use chr:start-end, e.g. chr7:27000000-28500000")
    chrom = m.group(1)
    start = int(m.group(2).replace(",", ""))
    end = int(m.group(3).replace(",", ""))
    if end <= start:
        raise ValueError(f"Region end must be larger than start: {s}")
    return Region(chrom, start, end, s)


def read_regions_bed(path: str, max_regions: Optional[int]) -> List[Region]:
    regions: List[Region] = []
    with open_text(path) as f:
        for line in f:
            if not line.strip() or line.startswith("#"):
                continue
            fields = line.rstrip("\n").split("\t")
            chrom, start, end = fields[0], int(fields[1]), int(fields[2])
            name = fields[3] if len(fields) >= 4 else f"{chrom}:{start}-{end}"
            regions.append(Region(chrom, start, end, name))
            if max_regions is not None and len(regions) >= max_regions:
                break
    return regions


def read_chrom_sizes(path: str, chroms: Optional[Sequence[str]]) -> Dict[str, int]:
    allow = set(chroms) if chroms else None
    out: Dict[str, int] = {}
    with open_text(path) as f:
        for line in f:
            if not line.strip() or line.startswith("#"):
                continue
            chrom, size = line.split()[:2]
            if allow is None or chrom in allow:
                out[chrom] = int(size)
    return out


def tile_regions(chrom_sizes: Dict[str, int], tile_size: int, step_size: Optional[int], max_regions: Optional[int]) -> List[Region]:
    step = step_size or tile_size
    regions: List[Region] = []
    for chrom, size in chrom_sizes.items():
        start = 0
        while start < size:
            end = min(start + tile_size, size)
            regions.append(Region(chrom, start, end, f"{chrom}:{start}-{end}"))
            if max_regions is not None and len(regions) >= max_regions:
                return regions
            start += step
    return regions


def load_samples(path: str, sort_samples: bool) -> List[Sample]:
    df = pd.read_csv(path, sep="\t", comment="#")
    if "sample" not in df.columns or "bed" not in df.columns:
        raise ValueError("samples.tsv must contain at least columns: sample and bed")
    if "group" not in df.columns:
        df["group"] = ""
    if sort_samples:
        df = df.sort_values(["group", "sample"], kind="stable")
    samples: List[Sample] = []
    for _, row in df.iterrows():
        samples.append(Sample(str(row["sample"]), str(row.get("group", "")), str(row["bed"])))
    return samples


def has_tabix(path: str) -> bool:
    return (path.endswith(".gz") or path.endswith(".bgz")) and (
        os.path.exists(path + ".tbi") or os.path.exists(path + ".csi")
    )


def iter_tabix(path: str, chrom: str, start: int, end: int) -> Optional[Iterator[str]]:
    try:
        import pysam  # type: ignore
        tbx = pysam.TabixFile(path)
        return tbx.fetch(chrom, start, end)
    except Exception:
        pass

    tabix = shutil.which("tabix")
    if tabix is None:
        return None
    region = f"{chrom}:{start + 1}-{end}"
    try:
        p = subprocess.run([tabix, path, region], text=True, capture_output=True, check=False)
    except Exception:
        return None
    if p.returncode not in (0, 1):
        return None
    return iter(p.stdout.splitlines())


def iter_bed_region(path: str, chrom: str, start: int, end: int) -> Iterator[Tuple[int, int, str]]:
    lines: Optional[Iterator[str]] = iter_tabix(path, chrom, start, end) if has_tabix(path) else None

    if lines is None:
        def scan() -> Iterator[str]:
            seen_target_chrom = False
            with open_text(path) as f:
                for line in f:
                    if not line.strip() or line.startswith("#") or line.startswith("track") or line.startswith("browser"):
                        continue
                    fields = line.rstrip("\n").split("\t")
                    if len(fields) < 3:
                        continue
                    c = fields[0]
                    if c != chrom:
                        if seen_target_chrom:
                            break
                        continue
                    seen_target_chrom = True
                    yield line.rstrip("\n")
        lines = scan()

    for line in lines:
        if not line.strip() or line.startswith("#") or line.startswith("track") or line.startswith("browser"):
            continue
        fields = line.rstrip("\n").split("\t")
        if len(fields) < 4 or fields[0] != chrom:
            continue
        try:
            s, e = int(fields[1]), int(fields[2])
        except ValueError:
            continue
        if e <= start or s >= end:
            continue
        yield max(s, start), min(e, end), fields[3]


def parse_gtf_attrs(attr: str) -> Dict[str, str]:
    out: Dict[str, str] = {}
    for item in attr.rstrip(";").split(";"):
        item = item.strip()
        if not item:
            continue
        if "=" in item:
            key, value = item.split("=", 1)
        else:
            parts = item.split(None, 1)
            if len(parts) != 2:
                continue
            key, value = parts
        out[key.strip()] = value.strip().strip('"')
    return out


def read_genes_gtf(path: str, chrom: str, start: int, end: int, gene_type: Optional[str]) -> List[Tuple[int, int, str, str]]:
    genes: List[Tuple[int, int, str, str]] = []
    with open_text(path) as f:
        for line in f:
            if not line.strip() or line.startswith("#"):
                continue
            fields = line.rstrip("\n").split("\t")
            if len(fields) < 9:
                continue
            c, _, feature, s, e, _, strand, _, attrs = fields[:9]
            if c != chrom or feature.lower() != "gene":
                continue
            s0, e0 = int(s) - 1, int(e)
            if e0 <= start or s0 >= end:
                continue
            a = parse_gtf_attrs(attrs)
            if gene_type is not None:
                observed = a.get("gene_type") or a.get("gene_biotype") or a.get("biotype") or ""
                if observed != gene_type:
                    continue
            name = a.get("gene_name") or a.get("Name") or a.get("gene_id") or "gene"
            genes.append((max(s0, start), min(e0, end), name, strand))
    return genes


def read_genes_bed(path: str, chrom: str, start: int, end: int) -> List[Tuple[int, int, str, str]]:
    genes: List[Tuple[int, int, str, str]] = []
    for s, e, name in iter_bed_region(path, chrom, start, end):
        genes.append((s, e, name, "."))
    return genes


def assign_gene_levels(genes: List[Tuple[int, int, str, str]]) -> List[Tuple[int, int, str, str, int]]:
    genes = sorted(genes, key=lambda x: (x[0], x[1]))
    level_ends: List[int] = []
    out: List[Tuple[int, int, str, str, int]] = []
    for s, e, name, strand in genes:
        for level, last_end in enumerate(level_ends):
            if s > last_end:
                level_ends[level] = e
                out.append((s, e, name, strand, level))
                break
        else:
            level_ends.append(e)
            out.append((s, e, name, strand, len(level_ends) - 1))
    return out


def format_bp(x: float) -> str:
    if abs(x) >= 1_000_000:
        return f"{x / 1_000_000:.2f} Mb"
    if abs(x) >= 1_000:
        return f"{x / 1_000:.1f} kb"
    return f"{int(x)} bp"


def format_label(label: str, max_chars: int = 0, wrap_width: int = 0) -> str:
    """Format a long y-axis label without changing the underlying sample order."""
    label = str(label)
    if wrap_width and wrap_width > 0:
        wrapped = textwrap.wrap(label, width=wrap_width, break_long_words=False, break_on_hyphens=False)
        label = "\n".join(wrapped) if wrapped else label
    if max_chars and max_chars > 0:
        lines = []
        for line in label.split("\n"):
            if len(line) > max_chars:
                suffix = "..."
                keep = max(1, max_chars - len(suffix))
                line = line[:keep] + suffix
            lines.append(line)
        label = "\n".join(lines)
    return label


def max_line_length(labels: Sequence[str]) -> int:
    longest = 0
    for label in labels:
        for line in str(label).split("\n"):
            longest = max(longest, len(line))
    return longest


def auto_left_margin(args: argparse.Namespace, sample_labels: Sequence[str], group_labels: Sequence[str]) -> float:
    """Estimate a safe left margin fraction for long sample/group labels."""
    if args.left_margin >= 0:
        return args.left_margin

    show_samples = args.show_sample_labels or len(sample_labels) <= args.max_sample_labels
    sample_chars = max_line_length(sample_labels) if show_samples else 0
    group_chars = max_line_length(group_labels) if args.show_group_labels else 0
    longest = max(sample_chars, group_chars)
    if longest == 0:
        return 0.06

    # A simple text-width approximation: one character is about half the font size in points.
    fontsize = max(args.sample_fontsize if sample_chars >= group_chars else args.group_fontsize, 1.0)
    label_inches = longest * fontsize * args.label_char_width / 72.0
    needed = (label_inches + args.left_margin_padding) / max(args.width, 1.0)
    needed = max(args.min_left_margin, needed)
    needed = min(args.max_left_margin, needed)
    return needed


def draw_gene_track(ax, genes: List[Tuple[int, int, str, str]], start: int, end: int, fontsize: float) -> None:
    genes_l = assign_gene_levels(genes)
    max_level = max((x[4] for x in genes_l), default=0)
    ax.set_ylim(max_level + 0.8, -0.8)
    ax.set_yticks([])
    ax.spines[["top", "right", "left"]].set_visible(False)
    ax.set_facecolor("white")

    for s, e, name, strand, level in genes_l:
        y = level
        ax.hlines(y, s, e, color="black", linewidth=0.8)
        ax.add_patch(Rectangle((s, y - 0.08), max(1, e - s), 0.16, facecolor="black", edgecolor="none"))
        if e - s > (end - start) * 0.02:
            if strand == "-":
                a0, a1 = e - (e - s) * 0.15, s + (e - s) * 0.15
            else:
                a0, a1 = s + (e - s) * 0.15, e - (e - s) * 0.15
            ax.add_patch(FancyArrowPatch((a0, y + 0.18), (a1, y + 0.18), arrowstyle="-|>",
                                         mutation_scale=7, linewidth=0.5, color="black"))
        ax.text((s + e) / 2, y - 0.18, name, ha="center", va="top", fontsize=fontsize, clip_on=True)


def plot_region(samples: Sequence[Sample], region: Region, colors: Dict[str, str], labels: Dict[str, str], pdf: PdfPages, args: argparse.Namespace) -> None:
    n = len(samples)
    sample_labels = [format_label(s.sample, args.sample_label_max_chars, args.sample_label_wrap) for s in samples]
    group_labels = [format_label(s.group, args.group_label_max_chars, args.group_label_wrap) for s in samples]
    left_margin = auto_left_margin(args, sample_labels, group_labels)

    has_genes = bool(args.gtf or args.gene_bed)
    gene_height = args.gene_track_height if has_genes else 0.0
    legend_height = 0.8 if args.legend else 0.0
    base_height = 1.1
    fig_height = base_height + args.row_height * n + gene_height + legend_height
    if args.max_height > 0:
        fig_height = min(fig_height, args.max_height)
    fig_height = max(fig_height, 3.0)

    if has_genes:
        fig = plt.figure(figsize=(args.width, fig_height))
        matrix_height = max(args.row_height * n, 1.5)
        gs = fig.add_gridspec(2, 1, height_ratios=[matrix_height, gene_height], hspace=0.04)
        ax = fig.add_subplot(gs[0])
        gax = fig.add_subplot(gs[1], sharex=ax)
    else:
        fig, ax = plt.subplots(figsize=(args.width, fig_height))
        gax = None

    chrom, start, end = region.chrom, region.start, region.end
    ax.set_xlim(start, end)
    ax.set_ylim(n, 0)
    ax.set_facecolor(args.background)

    unknown_states = set()
    for row, sample in enumerate(samples):
        y = row + 0.08
        patches_by_color: Dict[str, List[Rectangle]] = defaultdict(list)
        for s, e, raw_state in iter_bed_region(sample.bed, chrom, start, end):
            state = norm_state(raw_state)
            color = colors.get(state)
            if color is None:
                num = state_number(raw_state)
                color = colors.get(norm_state(str(num)), args.unknown_color) if num is not None else args.unknown_color
                unknown_states.add(raw_state)
            patches_by_color[color].append(Rectangle((s, y), e - s, 0.84))
        for color, patches in patches_by_color.items():
            ax.add_collection(PatchCollection(patches, facecolor=color, edgecolor="none", linewidth=0))

    if args.group_separators:
        groups = [s.group for s in samples]
        for i in range(1, n):
            if groups[i] != groups[i - 1]:
                ax.axhline(i, color="black", linewidth=0.4, alpha=0.45)

    if args.show_group_labels and any(s.group for s in samples):
        x_text = start - (end - start) * 0.012
        i = 0
        while i < n:
            j = i + 1
            while j < n and samples[j].group == samples[i].group:
                j += 1
#            if samples[i].group:
#                ax.text(x_text, (i + j) / 2, group_labels[i], va="center", ha="right",
#                        fontsize=args.group_fontsize, clip_on=False)
            i = j

    if args.show_sample_labels or n <= args.max_sample_labels:
        ax.set_yticks([i + 0.5 for i in range(n)])
        ax.set_yticklabels(sample_labels, fontsize=args.sample_fontsize)
    else:
        ax.set_yticks([])
    ax.tick_params(axis="y", length=0, pad=args.sample_label_pad)

    ax.spines[["top", "right"]].set_visible(False)
    title = args.title if args.title else "Chromatin states"
    ax.set_title(f"{title} | {region.name}", fontsize=args.title_fontsize, pad=6)
#    ax.set_ylabel("Samples")

    if has_genes and gax is not None:
        ax.tick_params(axis="x", labelbottom=False)
        genes = read_genes_gtf(args.gtf, chrom, start, end, args.gene_type) if args.gtf else read_genes_bed(args.gene_bed, chrom, start, end)
        draw_gene_track(gax, genes, start, end, args.gene_fontsize)
        gax.set_xlabel(f"{chrom} position")
        gax.xaxis.set_major_formatter(lambda x, pos: format_bp(x))
        gax.set_ylabel("Genes", rotation=0, ha="right", va="center", labelpad=24)
    else:
        ax.set_xlabel(f"{chrom} position")
        ax.xaxis.set_major_formatter(lambda x, pos: format_bp(x))

    if args.legend:
        keys: List[str] = []
        seen = set()
        for key in sorted(labels, key=lambda k: (state_number(k) or 999, k)):
            nk = norm_state(key)
            if nk in colors and nk not in seen:
                seen.add(nk)
                keys.append(nk)
        handles = [Patch(facecolor=colors[k], edgecolor="black", linewidth=0.2, label=labels.get(k, k))
                   for k in keys[:args.legend_max]]
        if handles:
            fig.legend(handles=handles, loc="lower center", ncol=min(args.legend_cols, len(handles)),
                       fontsize=args.legend_fontsize, frameon=False, bbox_to_anchor=(0.5, 0.01))
            fig.subplots_adjust(bottom=0.10)

    bottom_margin = 0.08 if args.legend else 0.02
    fig.tight_layout(rect=(left_margin, bottom_margin, 0.995, 0.96))
    fig.subplots_adjust(left=left_margin, right=0.995, bottom=bottom_margin, top=0.96)
    pdf.savefig(fig)
    plt.close(fig)

    if unknown_states and args.verbose:
        sys.stderr.write(f"[warn] unknown states in {region.name}: {sorted(unknown_states)[:10]}\n")


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    p.add_argument("--samples", required=True, help="TSV with sample, bed, and optional group columns.")
    p.add_argument("--out", required=True, help="Output PDF path.")

    reg = p.add_mutually_exclusive_group(required=True)
    reg.add_argument("--region", help="Single region, e.g. chr7:27000000-28500000")
    reg.add_argument("--regions-bed", help="BED file of regions to plot. One region per PDF page.")
    reg.add_argument("--tile-genome", action="store_true", help="Tile the genome using --chrom-sizes.")
    p.add_argument("--chrom-sizes", help="chrom.sizes file. Required with --tile-genome.")
    p.add_argument("--chroms", nargs="+", help="Restrict --tile-genome to these chromosomes.")
    p.add_argument("--tile-size", type=int, default=2_000_000, help="Tile size for --tile-genome.")
    p.add_argument("--step-size", type=int, default=None, help="Step size for --tile-genome. Default equals --tile-size.")
    p.add_argument("--max-regions", type=int, default=None, help="Plot only the first N regions.")

    p.add_argument("--gtf", help="GTF/GFF file for gene track. Only feature == gene is used.")
    p.add_argument("--gene-bed", help="BED file for simple gene track. Column 4 is used as gene name.")
    p.add_argument("--gene-type", default=None, help="Filter GTF genes by gene_type/gene_biotype, e.g. protein_coding.")

    p.add_argument("--colors", help="Optional colors TSV/json. TSV columns: state, color, optional label.")
    p.add_argument("--model", choices=["roadmap15", "roadmap18"], default="roadmap15", help="Built-in state color model.")
    p.add_argument("--unknown-color", default="#000000", help="Color for states not found in the palette.")
    p.add_argument("--background", default="#eeeeee", help="Background color for missing segments.")

    p.add_argument("--sort-samples", action="store_true", help="Sort samples by group and sample. Default preserves samples.tsv order.")
    p.add_argument("--group-separators", action="store_true", help="Draw horizontal separators between groups. Default is no separators.")
    p.add_argument("--show-group-labels", action="store_true", default=True, help="Show group labels on the left if the group column exists.")
    p.add_argument("--hide-group-labels", action="store_false", dest="show_group_labels", help="Hide group labels.")

    p.add_argument("--width", type=float, default=16.0, help="Figure width in inches.")
    p.add_argument("--row-height", type=float, default=0.22, help="Vertical size in inches allocated per sample row.")
    p.add_argument("--max-height", type=float, default=0.0, help="Maximum figure height in inches. Use 0 for no maximum.")
    p.add_argument("--gene-track-height", type=float, default=1.35, help="Height in inches for the gene track.")
    p.add_argument("--show-sample-labels", action="store_true", help="Always show sample labels.")
    p.add_argument("--max-sample-labels", type=int, default=500, help="Automatically show sample labels up to this many samples.")
    p.add_argument("--sample-label-max-chars", type=int, default=0,
                   help="Truncate sample labels to this many characters per line. Use 0 to keep full labels.")
    p.add_argument("--sample-label-wrap", type=int, default=0,
                   help="Wrap sample labels at this many characters. Use 0 to disable wrapping.")
    p.add_argument("--group-label-max-chars", type=int, default=0,
                   help="Truncate group labels to this many characters per line. Use 0 to keep full labels.")
    p.add_argument("--group-label-wrap", type=int, default=0,
                   help="Wrap group labels at this many characters. Use 0 to disable wrapping.")
    p.add_argument("--sample-label-pad", type=float, default=2.0, help="Padding between y-axis and sample labels, in points.")
    p.add_argument("--left-margin", type=float, default=-1.0,
                   help="Left margin as a figure fraction. Use a negative value for automatic estimation.")
    p.add_argument("--min-left-margin", type=float, default=0.08, help="Minimum automatic left margin as a figure fraction.")
    p.add_argument("--max-left-margin", type=float, default=0.45, help="Maximum automatic left margin as a figure fraction.")
    p.add_argument("--left-margin-padding", type=float, default=0.35, help="Extra automatic left margin in inches.")
    p.add_argument("--label-char-width", type=float, default=0.52,
                   help="Approximate label character width relative to font size for automatic margin estimation.")
    p.add_argument("--sample-fontsize", type=float, default=5.5)
    p.add_argument("--group-fontsize", type=float, default=8.0)
    p.add_argument("--gene-fontsize", type=float, default=6.0)
    p.add_argument("--title-fontsize", type=float, default=10.0)
    p.add_argument("--title", default="", help="Title prefix.")

    p.add_argument("--legend", action="store_true", default=True, help="Show state legend.")
    p.add_argument("--no-legend", action="store_false", dest="legend", help="Hide state legend.")
    p.add_argument("--legend-cols", type=int, default=6)
    p.add_argument("--legend-max", type=int, default=18)
    p.add_argument("--legend-fontsize", type=float, default=6.5)
    p.add_argument("--verbose", action="store_true")
    return p


def main(argv: Optional[Sequence[str]] = None) -> int:
    args = build_parser().parse_args(argv)
    samples = load_samples(args.samples, sort_samples=args.sort_samples)
    colors, labels = load_colors(args.colors, args.model)

    if args.region:
        regions = [parse_region(args.region)]
    elif args.regions_bed:
        regions = read_regions_bed(args.regions_bed, args.max_regions)
    else:
        if not args.chrom_sizes:
            raise ValueError("--chrom-sizes is required with --tile-genome")
        sizes = read_chrom_sizes(args.chrom_sizes, args.chroms)
        regions = tile_regions(sizes, args.tile_size, args.step_size, args.max_regions)

    if not args.out.lower().endswith(".pdf"):
        args.out += ".pdf"

    if args.verbose:
        sys.stderr.write(f"[info] script: roadmap_chromstate_matrix_v3.py\n")
        sys.stderr.write(f"[info] samples: {len(samples)}\n")
        sys.stderr.write(f"[info] regions: {len(regions)}\n")
        sys.stderr.write(f"[info] row-height: {args.row_height}\n")
        sys.stderr.write(f"[info] sample-label-wrap: {args.sample_label_wrap}\n")
        sys.stderr.write(f"[info] sample-label-max-chars: {args.sample_label_max_chars}\n")
        sys.stderr.write(f"[info] sample order: {'sorted by group/sample' if args.sort_samples else 'samples.tsv top-to-bottom'}\n")
        sys.stderr.write(f"[info] group separators: {args.group_separators}\n")

    with PdfPages(args.out) as pdf:
        for i, region in enumerate(regions, 1):
            if args.verbose:
                sys.stderr.write(f"[info] plotting {i}/{len(regions)} {region.name}\n")
            plot_region(samples, region, colors, labels, pdf, args)

    if args.verbose:
        sys.stderr.write(f"[info] wrote {args.out}\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
