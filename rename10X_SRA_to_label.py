#! /usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys

if len(sys.argv) < 2:
    print(f"Usage: {sys.argv[0]} id_label.tsv")
    sys.exit(1)

mapping_file = sys.argv[1]
dry_run = "--dry" in sys.argv  # dryモードが有効かどうか

id_to_label = {}
id_to_dir = {}
id_to_lane = {}
id_to_suffix_map = {}

with open(mapping_file, "r", encoding="utf-8") as f:
    header = f.readline().strip().split("\t")
    for line in f:
        parts = line.strip().split("\t")
        if len(parts) < 6:
            print(f"Skipping invalid line: {line}")
            continue

        id_, label, directory, lane, r1, r2, *optional = parts
        r3 = optional[0] if len(optional) > 0 else None
        r4 = optional[1] if len(optional) > 1 else None

        id_to_label[id_] = label
        id_to_dir[id_] = directory
        id_to_lane[id_] = f"L00{lane}"
        id_to_suffix_map[id_] = {
            f"_1.fastq.gz": f"_{r1}_001.fastq.gz",
            f"_2.fastq.gz": f"_{r2}_001.fastq.gz",
        }
        if r3:
            id_to_suffix_map[id_][f"_3.fastq.gz"] = f"_{r3}_001.fastq.gz"
        if r4:
            id_to_suffix_map[id_][f"_4.fastq.gz"] = f"_{r4}_001.fastq.gz"

for id_ in id_to_label.keys():
    label = id_to_label[id_]
    directory = id_to_dir[id_]
    lane = id_to_lane[id_]
    suffix_map = id_to_suffix_map[id_]

    for original_suffix, new_suffix in suffix_map.items():
        original_filename = f"{id_}{original_suffix}"

        new_filename = f"{label}/{directory}/{label}_S1_{lane}{new_suffix}"

        if dry_run:
            # --dry の場合は実際のリネームを行わず、存在チェックもしない
            print(f"[DRY RUN] Renamed: {original_filename} -> {new_filename}")
            continue

        if not os.path.exists(original_filename):
            print(f"Skipping: {original_filename} (file not found)")
            continue

        os.makedirs(f"{label}/{directory}", exist_ok=True)
        os.rename(original_filename, new_filename)
        print(f"Renamed: {original_filename} -> {new_filename}")
