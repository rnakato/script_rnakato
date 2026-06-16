#!/usr/bin/env python3

import argparse
import gzip
import os
from pathlib import Path
import re

import numpy as np
import pandas as pd
import pyBigWig
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle
import requests


UCSC_REFGENE_COLUMNS = [
    "bin", "name", "chrom", "strand",
    "txStart", "txEnd", "cdsStart", "cdsEnd",
    "exonCount", "exonStarts", "exonEnds",
    "score", "name2", "cdsStartStat", "cdsEndStat", "exonFrames"
]


def parse_args():
    p = argparse.ArgumentParser(
        description="Plot multiple bigWig tracks around a gene."
    )
    p.add_argument("--bigwigs", nargs="+", required=True,
                   help="Input bigWig files.")
    p.add_argument("--labels", nargs="+", default=None,
                   help="Labels for bigWig tracks. Must match --bigwigs.")
    p.add_argument("--gene", required=True,
                   help="Gene symbol, e.g. MYC, Sox2.")
    p.add_argument("--build", default=None,
                   help="Genome build, e.g. hg38, hg19, mm10, mm39. Used for UCSC refGene lookup.")
    p.add_argument("--gtf", default=None,
                   help="Optional local GTF/GTF.gz file. If given, this is used instead of UCSC refGene.")
    p.add_argument("--transcript", default=None,
                   help="Optional transcript_id to draw from GTF. "
                   "If not specified, the transcript with the largest genomic span is used.")
    p.add_argument("--flank", type=int, default=50000,
                   help="Flanking size around gene body in bp. Default: 50000.")
    p.add_argument("--bins", type=int, default=1000,
                   help="Number of bins for bigWig summarization. Default: 1000.")
    p.add_argument("--colors", nargs="+", default=None,
                   help="Colors for bigWig tracks. Must match --bigwigs. "
                   "Examples: black red blue or '#333333' '#d62728'.")
    p.add_argument("--out", default=None,
                   help="Output file, e.g. gene.pdf or gene.png.")
    p.add_argument("--same-y", action="store_true",
                   help="Use the same y-axis range for all bigWig tracks.")
    p.add_argument("--ylim", nargs=2, type=float, default=None,
                   help="Manual y-axis limits, e.g. --ylim 0 20.")
    p.add_argument("--shade-exons", action="store_true",
                   help="Shade exon regions in bigWig tracks.")
    p.add_argument("--show-intron-arrows", action="store_true",
                   help="Show small arrows on introns to indicate transcription direction.")
    p.add_argument("--cache-dir", default="~/.cache/bw_gene_plot",
                   help="Cache directory for UCSC refGene tables.")
    return p.parse_args()


def download_refgene(build, cache_dir):
    if build is None:
        raise ValueError("Please provide --build, e.g. hg38, hg19, mm10, mm39, or provide --gtf.")

    cache_dir = Path(os.path.expanduser(cache_dir))
    cache_dir.mkdir(parents=True, exist_ok=True)

    out_path = cache_dir / f"{build}.refGene.txt.gz"
    if out_path.exists() and out_path.stat().st_size > 0:
        return out_path

    url = f"https://hgdownload.soe.ucsc.edu/goldenPath/{build}/database/refGene.txt.gz"
    print(f"[INFO] Downloading UCSC refGene: {url}")

    r = requests.get(url, timeout=60)
    if r.status_code != 200:
        raise RuntimeError(
            f"Could not download refGene for build={build} from UCSC.\n"
            f"URL: {url}\n"
            f"Use --gtf if this build is unavailable or the server has no internet access."
        )

    with open(out_path, "wb") as f:
        f.write(r.content)

    return out_path


def parse_exon_list(exon_starts, exon_ends):
    starts = [int(x) for x in str(exon_starts).rstrip(",").split(",") if x != ""]
    ends = [int(x) for x in str(exon_ends).rstrip(",").split(",") if x != ""]
    return list(zip(starts, ends))


def find_gene_from_ucsc_refgene(gene, build, cache_dir):
    refgene_path = download_refgene(build, cache_dir)

    df = pd.read_csv(
        refgene_path,
        sep="\t",
        header=None,
        names=UCSC_REFGENE_COLUMNS,
        compression="gzip",
        dtype={
            "chrom": str,
            "strand": str,
            "name": str,
            "name2": str,
        },
    )

    hit = df[df["name2"].str.lower() == gene.lower()].copy()

    if hit.empty:
        raise ValueError(f"Gene symbol '{gene}' was not found in UCSC refGene for build={build}.")

    hit["tx_len"] = hit["txEnd"] - hit["txStart"]
    row = hit.sort_values("tx_len", ascending=False).iloc[0]

    exons = parse_exon_list(row["exonStarts"], row["exonEnds"])

    return {
        "gene": row["name2"],
        "transcript": row["name"],
        "chrom": row["chrom"],
        "strand": row["strand"],
        "tx_start": int(row["txStart"]),
        "tx_end": int(row["txEnd"]),
        "exons": exons,
        "source": f"UCSC refGene {build}",
    }


def parse_gtf_attrs(attr):
    d = {}
    for item in attr.strip().rstrip(";").split(";"):
        item = item.strip()
        if not item:
            continue
        m = re.match(r'(\S+)\s+"?([^"]+)"?', item)
        if m:
            d[m.group(1)] = m.group(2)
    return d


def open_text_maybe_gzip(path):
    if str(path).endswith(".gz"):
        return gzip.open(path, "rt")
    return open(path, "rt")


def find_gene_from_gtf(gene, gtf, transcript_id=None):
    tx_info = {}
    exons_by_tx = {}

    with open_text_maybe_gzip(gtf) as f:
        for line in f:
            if line.startswith("#"):
                continue

            fields = line.rstrip("\n").split("\t")
            if len(fields) < 9:
                continue

            chrom, source, feature, start, end, score, strand, frame, attrs = fields
            start = int(start) - 1
            end = int(end)

            a = parse_gtf_attrs(attrs)

            gene_name = a.get("gene_name", None)
            gene_id = a.get("gene_id", None)
            tx_id = a.get("transcript_id", None)
            tx_name = a.get("transcript_name", tx_id)

            names = {x.lower() for x in [gene_name, gene_id] if x is not None}
            if gene.lower() not in names:
                continue

            # exon/intron を描くには transcript_id が必要
            if feature != "exon":
                continue

            if tx_id is None:
                continue

            if transcript_id is not None and tx_id != transcript_id and tx_name != transcript_id:
                continue

            exons_by_tx.setdefault(tx_id, []).append((start, end))

            if tx_id not in tx_info:
                tx_info[tx_id] = {
                    "chrom": chrom,
                    "strand": strand,
                    "start": start,
                    "end": end,
                    "gene_name": gene_name if gene_name is not None else gene_id,
                    "transcript_name": tx_name,
                }
            else:
                tx_info[tx_id]["start"] = min(tx_info[tx_id]["start"], start)
                tx_info[tx_id]["end"] = max(tx_info[tx_id]["end"], end)

    if not exons_by_tx:
        if transcript_id is None:
            raise ValueError(
                f"Gene '{gene}' was found neither as exon-containing transcripts in GTF: {gtf}. "
                f"Check whether the GTF has exon features and gene_name/transcript_id attributes."
            )
        else:
            raise ValueError(
                f"Transcript '{transcript_id}' for gene '{gene}' was not found as exon features in GTF: {gtf}."
            )

    # transcript 指定がない場合は、exon から見た genomic span が最大の transcript を選ぶ
    best_tx = max(
        exons_by_tx.keys(),
        key=lambda tx: max(e for _, e in exons_by_tx[tx]) - min(s for s, _ in exons_by_tx[tx])
    )

    exons = sorted(exons_by_tx[best_tx])
    tx = tx_info[best_tx]

    tx_start = min(s for s, _ in exons)
    tx_end = max(e for _, e in exons)

    return {
        "gene": tx["gene_name"],
        "transcript": tx["transcript_name"] if tx["transcript_name"] is not None else best_tx,
        "transcript_id": best_tx,
        "chrom": tx["chrom"],
        "strand": tx["strand"],
        "tx_start": int(tx_start),
        "tx_end": int(tx_end),
        "exons": exons,
        "source": f"GTF {gtf}",
    }


def match_chrom_name(bw, chrom):
    chroms = bw.chroms()

    if chrom in chroms:
        return chrom

    if chrom.startswith("chr"):
        alt = chrom.replace("chr", "", 1)
    else:
        alt = "chr" + chrom

    if alt in chroms:
        return alt

    if chrom == "chrM" and "MT" in chroms:
        return "MT"
    if chrom == "MT" and "chrM" in chroms:
        return "chrM"

    raise ValueError(
        f"Chromosome '{chrom}' was not found in bigWig. "
        f"Available examples: {list(chroms.keys())[:10]}"
    )


def get_bigwig_signal(path, chrom, start, end, bins):
    bw = pyBigWig.open(path)
    bw_chrom = match_chrom_name(bw, chrom)

    chrom_len = bw.chroms()[bw_chrom]
    start = max(0, start)
    end = min(end, chrom_len)

    values = bw.stats(bw_chrom, start, end, nBins=bins, type="mean")
    bw.close()

    y = np.array([np.nan if v is None else float(v) for v in values])
    x = np.linspace(start, end, bins, endpoint=False) + (end - start) / bins / 2

    return x, y


def get_introns_from_exons(exons):
    exons = sorted(exons)
    introns = []

    for i in range(len(exons) - 1):
        intron_start = exons[i][1]
        intron_end = exons[i + 1][0]

        if intron_start < intron_end:
            introns.append((intron_start, intron_end))

    return introns


def shade_exons_on_track(ax, exons, plot_start, plot_end):
    for s, e in exons:
        s2 = max(s, plot_start)
        e2 = min(e, plot_end)

        if s2 < e2:
            ax.axvspan(s2, e2, alpha=0.08, linewidth=0)

def plot_gene_model(ax, gene_info, plot_start, plot_end, show_intron_arrows=False):
    tx_start = gene_info["tx_start"]
    tx_end = gene_info["tx_end"]
    strand = gene_info["strand"]
    exons = sorted(gene_info["exons"])
    introns = get_introns_from_exons(exons)

    # Transcript body
    ax.hlines(
        0,
        max(tx_start, plot_start),
        min(tx_end, plot_end),
        linewidth=1.0,
        color="black",
        alpha=0.6,
    )

    # Introns as thin lines
    for s, e in introns:
        s2 = max(s, plot_start)
        e2 = min(e, plot_end)

        if s2 < e2:
            ax.hlines(
                0,
                s2,
                e2,
                linewidth=1.0,
                color="black",
                alpha=0.8,
            )

            if show_intron_arrows:
                intron_len = e2 - s2
                if intron_len > 0:
                    n_arrows = max(1, int(intron_len / ((plot_end - plot_start) * 0.08)))
                    arrow_positions = np.linspace(s2, e2, n_arrows + 2)[1:-1]

                    for x0 in arrow_positions:
                        dx = (plot_end - plot_start) * 0.01
                        if strand == "-":
                            dx = -dx

                        ax.annotate(
                            "",
                            xy=(x0 + dx, 0),
                            xytext=(x0, 0),
                            arrowprops=dict(
                                arrowstyle="->",
                                lw=0.8,
                                color="black",
                                alpha=0.7,
                            ),
                        )

    # Exons as thick boxes
    for s, e in exons:
        s2 = max(s, plot_start)
        e2 = min(e, plot_end)

        if s2 < e2:
            ax.add_patch(
                Rectangle(
                    (s2, -0.18),
                    e2 - s2,
                    0.36,
                    facecolor="black",
                    edgecolor="black",
                    linewidth=0.8,
                )
            )

    # TSS/TES direction marker
    if strand == "+":
        arrow_from = max(tx_start, plot_start)
        arrow_to = min(tx_start + (plot_end - plot_start) * 0.03, plot_end)
    else:
        arrow_from = min(tx_end, plot_end)
        arrow_to = max(tx_end - (plot_end - plot_start) * 0.03, plot_start)

    ax.annotate(
        "",
        xy=(arrow_to, 0.38),
        xytext=(arrow_from, 0.38),
        arrowprops=dict(arrowstyle="->", lw=1.2, color="black"),
    )

    ax.text(
        plot_start,
        0.42,
        "TSS" if strand == "+" else "TES",
        ha="left",
        va="bottom",
        fontsize=8,
    )

    ax.set_ylim(-0.7, 0.7)
    ax.set_yticks([])
    ax.set_ylabel(
        f"{gene_info['gene']}\n{strand}",
        rotation=0,
        ha="right",
        va="center",
    )
    ax.spines[["top", "right", "left"]].set_visible(False)


def main():
    args = parse_args()

    if args.labels is not None and len(args.labels) != len(args.bigwigs):
        raise ValueError("--labels must have the same length as --bigwigs.")

    labels = args.labels if args.labels is not None else [
        Path(x).stem for x in args.bigwigs
    ]

    if args.gtf:
        gene_info = find_gene_from_gtf(
            args.gene,
            args.gtf,
            transcript_id=args.transcript,
        )
    else:
        gene_info = find_gene_from_ucsc_refgene(args.gene, args.build, args.cache_dir)

    if args.colors is not None and len(args.colors) != len(args.bigwigs):
        raise ValueError("--colors must have the same length as --bigwigs.")

    colors = args.colors

    chrom = gene_info["chrom"]
    plot_start = max(0, gene_info["tx_start"] - args.flank)
    plot_end = gene_info["tx_end"] + args.flank

    print("[INFO] Gene model")
    print(f"  gene       : {gene_info['gene']}")
    print(f"  transcript : {gene_info['transcript']}")
    print(f"  source     : {gene_info['source']}")
    print(f"  locus      : {chrom}:{plot_start:,}-{plot_end:,}")
    print(f"  strand     : {gene_info['strand']}")

    signals = []
    for bw_path in args.bigwigs:
        x, y = get_bigwig_signal(
            bw_path,
            chrom=chrom,
            start=plot_start,
            end=plot_end,
            bins=args.bins,
        )
        signals.append((x, y))

    n_tracks = len(args.bigwigs)
    fig_height = max(2.5, 1.2 * n_tracks + 1.0)

    fig, axes = plt.subplots(
        n_tracks + 1,
        1,
        figsize=(10, fig_height),
        sharex=True,
        gridspec_kw={"height_ratios": [1] * n_tracks + [0.45]},
        constrained_layout=True,
    )

    if n_tracks == 1:
        track_axes = [axes[0]]
        gene_ax = axes[1]
    else:
        track_axes = axes[:-1]
        gene_ax = axes[-1]

    if args.ylim is not None:
        global_ylim = tuple(args.ylim)
    elif args.same_y:
        ymax = np.nanmax([np.nanmax(y) for _, y in signals])
        ymin = np.nanmin([np.nanmin(y) for _, y in signals])
        if ymin >= 0:
            ymin = 0
        global_ylim = (ymin, ymax * 1.05 if ymax > 0 else 1)
    else:
        global_ylim = None


    for i, (ax, label, bw_path, (x, y)) in enumerate(
            zip(track_axes, labels, args.bigwigs, signals)
    ):
        y_plot = np.nan_to_num(y, nan=0.0)

        color = colors[i] if colors is not None else None

        if args.shade_exons:
            shade_exons_on_track(ax, gene_info["exons"], plot_start, plot_end)

        ax.plot(x, y_plot, linewidth=1.0, color=color)
        if np.nanmin(y_plot) >= 0:
            ax.fill_between(x, y_plot, 0, alpha=0.35, color=color)

        ax.set_ylabel(label, rotation=0, ha="right", va="center")
        ax.spines[["top", "right"]].set_visible(False)

        if global_ylim is not None:
            ax.set_ylim(global_ylim)
        else:
            ymax = np.nanmax(y_plot)
            ymin = np.nanmin(y_plot)
            if ymin >= 0:
                ymin = 0
            ax.set_ylim(ymin, ymax * 1.05 if ymax > 0 else 1)

        # TSS and TES
        tss = gene_info["tx_start"] if gene_info["strand"] == "+" else gene_info["tx_end"]
        tes = gene_info["tx_end"] if gene_info["strand"] == "+" else gene_info["tx_start"]
        ax.axvline(tss, linestyle="--", linewidth=0.8)
        ax.axvline(tes, linestyle=":", linewidth=0.8)

    plot_gene_model(
        gene_ax,
        gene_info,
        plot_start,
        plot_end,
        show_intron_arrows=args.show_intron_arrows,
    )

    gene_ax.set_xlim(plot_start, plot_end)
    gene_ax.set_xlabel(f"Genomic coordinate on {chrom}")

    title = (
        f"{gene_info['gene']} "
        f"({gene_info['transcript']}, {gene_info['strand']}) "
        f"{chrom}:{plot_start:,}-{plot_end:,}"
    )
    fig.suptitle(title, y=1.02)

    if args.out is None:
        suffix = args.build if args.build else "custom"
        args.out = f"{gene_info['gene']}_{suffix}_bigwig.pdf"

    fig.savefig(args.out, dpi=300, bbox_inches="tight")
    print(f"[INFO] Saved: {args.out}")


if __name__ == "__main__":
    main()
