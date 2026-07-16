#!/usr/bin/env python3
"""Build samplelist_labels.txt from a GEO series accession and a Run ID samplelist.

Reproduces the steps done manually for GSE136018:
  1. Read Run IDs (column 1) from the input samplelist.
  2. NCBI SRA esearch+efetch(runinfo) -> Run ID -> GSM accession.
  3. NCBI GEO  esearch+esummary(db=gds) -> GSM accession -> sample title.
  4. Write run_to_sample_label.tsv (Run ID -> sample title).
  5. Call merge_fastq_by_label.py to produce the final merged samplelist.

Usage:
  python build_samplelist_labels.py GSE136018 samplelist.txt \
      [-o samplelist_labels.txt] [--mapping-out run_to_sample_label.tsv]
"""

from __future__ import annotations

import argparse
import csv
import io
import json
import subprocess
import sys
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
from pathlib import Path

EUTILS = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils"
MERGE_SCRIPT = Path("/home/rnakato/.claude/skills/gensamp/scripts/merge_fastq_by_label.py")


def eutils_get(endpoint: str, params: dict) -> bytes:
    url = f"{EUTILS}/{endpoint}?{urllib.parse.urlencode(params)}"
    with urllib.request.urlopen(url) as resp:
        return resp.read()


def read_run_ids(samplelist: Path) -> list[str]:
    run_ids = []
    with samplelist.open() as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            run_ids.append(line.split("\t")[0].split()[0])
    return run_ids


def run_to_gsm(run_ids: list[str]) -> dict[str, str]:
    term = " OR ".join(f"{rid}[Accession]" for rid in run_ids)
    xml_bytes = eutils_get("esearch.fcgi", {"db": "sra", "term": term, "retmax": len(run_ids)})
    uids = [e.text for e in ET.fromstring(xml_bytes).find("IdList")]

    runinfo = eutils_get(
        "efetch.fcgi",
        {"db": "sra", "id": ",".join(uids), "rettype": "runinfo", "retmode": "text"},
    ).decode()
    mapping = {}
    for row in csv.DictReader(io.StringIO(runinfo)):
        mapping[row["Run"]] = row["SampleName"]  # SampleName holds the GSM accession
    return mapping


def gsm_to_title(gse_accession: str) -> dict[str, str]:
    xml_bytes = eutils_get(
        "esearch.fcgi",
        {"db": "gds", "term": f"{gse_accession}[Accession] AND gsm[Entry Type]", "retmax": 1000},
    )
    uids = [e.text for e in ET.fromstring(xml_bytes).find("IdList")]

    summary = json.loads(
        eutils_get("esummary.fcgi", {"db": "gds", "id": ",".join(uids), "retmode": "json"})
    )
    result = summary["result"]
    return {result[uid]["accession"]: result[uid]["title"] for uid in result["uids"]}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("gse_accession", help="GEO series accession, e.g. GSE136018")
    parser.add_argument("samplelist", type=Path, help="Input samplelist with Run IDs in column 1")
    parser.add_argument("-o", "--output", default="samplelist_labels.txt", help="Final merged output path")
    parser.add_argument("--mapping-out", default="run_to_sample_label.tsv", help="Run ID -> label TSV to write")
    args = parser.parse_args()

    run_ids = read_run_ids(args.samplelist)
    run_gsm = run_to_gsm(run_ids)
    gsm_title = gsm_to_title(args.gse_accession)

    unresolved = [rid for rid in run_ids if run_gsm.get(rid) not in gsm_title]
    if unresolved:
        print(f"Warning: {len(unresolved)} unresolved Run ID(s): {', '.join(unresolved)}", file=sys.stderr)

    mapping_path = Path(args.mapping_out)
    with mapping_path.open("w") as fh:
        for rid in run_ids:
            gsm = run_gsm.get(rid)
            label = gsm_title.get(gsm)
            if label:
                fh.write(f"{rid}\t{label}\n")

    subprocess.run(
        [sys.executable, str(MERGE_SCRIPT), str(args.samplelist),
         "--mapping", str(mapping_path), "-o", args.output, "--verbose"],
        check=True,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
