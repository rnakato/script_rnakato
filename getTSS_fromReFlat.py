#! /usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import pandas as pd

def parserefFlat(filename):
    refFlat = pd.read_csv(filename, sep='\t', header=0)
    refFlat.index = refFlat['name']
    return refFlat

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input",  help="refFlat", type=str)
    parser.add_argument("output",  help="refFlat", type=str)
    parser.add_argument("-l", "--length", help="length from TSS (default: 100)", type=int, default=100)

    args = parser.parse_args()
#    print(args)
    length = args.length

    gene = parserefFlat(args.input)
    gene["TSSstart"] = 0
    gene["TSSend"] = 0  

    # loop over the rows in the DataFrame and calculate the TSS site
    for index, row in gene.iterrows():
        if row["strand"] == "+":
            gene.loc[index, "TSSstart"] = row["txStart"]
            gene.loc[index, "TSSend"] = row["txStart"] + length
        elif row["strand"] == "-":
            gene.loc[index, "TSSstart"] = row["txStart"] - length
            gene.loc[index, "TSSend"] = row["txStart"]

    gene[["chrom", "TSSstart", "TSSend", "strand"]].to_csv(args.output, sep='\t', index = False)

if(__name__ == '__main__'):
    main()