#! /usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import pandas as pd

def parseRPKMMatrix(filename):
    df = pd.read_csv(filename, sep='\t', index_col=False, header=0)
    df.index = df.iloc[:,0]
    df = df.iloc[:,1:]
    
    return df

def parserefFlat(filename):
    refFlat = pd.read_csv(filename, sep='\t', header=0)
#    refFlat.columns = ['genename', 'name', 'chrom', 'strand', 'txStart', 'txEnd', 'cdsStart', 'cdsEnd', 'exonCount',
#                       'exonStarts', 'exonEnds', 'gene type', 'transcript type', 'reference transcript name', 'reference transcript id']
    refFlat['exonStarts'] = refFlat['exonStarts'].apply(lambda x: [int(i) for i in x.split(',')[:-1]])
    refFlat['exonEnds'] = refFlat['exonEnds'].apply(lambda x: [int(i) for i in x.split(',')[:-1]])
    refFlat.index = refFlat['name']
    return refFlat

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input",  help="RPKM matrix", type=str)
    parser.add_argument("cellid", help="Cell type ID (e.g., E050)", type=str)
    parser.add_argument("gene",  help="refFlat", type=str)
    parser.add_argument("--thre_expressed", help="RPKM threshold for expressed or not (default: > 0)", type=int, default=0)
    parser.add_argument("--thre_highlyexpressed", help="RPKM threshold for highly expressed or not (default: > 50)", type=int, default=50)

    args = parser.parse_args()
#    print(args)

    mat = parseRPKMMatrix(args.input)
#    mat = mat[args.cellid]
#    print (mat)

    gene = parserefFlat(args.gene)
#    print (gene)
    gene_expressed = mat[(mat[args.cellid] > args.thre_expressed) & (mat[args.cellid] <= args.thre_highlyexpressed)].index
    gene_expressed = gene_expressed.intersection(gene.index)
    gene.loc[gene_expressed].to_csv('gene_expressed.refFlat', sep='\t')
    gene_highlyexpressed = mat[mat[args.cellid] > args.thre_highlyexpressed].index
    gene_highlyexpressed = gene_highlyexpressed.intersection(gene.index)
    gene.loc[gene_highlyexpressed].to_csv('gene_highlyexpressed.refFlat', sep='\t')

if(__name__ == '__main__'):
    main()




    refFlat = pd.read_csv(filename, sep='\t', header=0)
    refFlat.columns = ['genename', 'name', 'chrom', 'strand', 'txStart', 'txEnd', 'cdsStart', 'cdsEnd', 'exonCount',


