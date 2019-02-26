#! /usr/bin/env python
# -*- coding: utf-8 -*- 

import argparse
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np


if(__name__ == '__main__'):
    parser = argparse.ArgumentParser()
    parser.add_argument("numerator", help="output of uniq (numerator)", type=str)
    parser.add_argument("denominator", help="output of uniq (denominator)", type=str)
    parser.add_argument("output", help="Output prefix", type=str)
    parser.add_argument("--threshold", help="Output rows whose values are more than this value (default: -1)", type=int, default=-1)
    parser.add_argument("--sizex", help="Size of x axis (default: 7)", type=int, default=7)
    parser.add_argument("--sizey", help="Size of y axis (default: 7)", type=int, default=7)
    parser.add_argument('--png', action='store_true', help='output .png (default: .pdf)')

    args = parser.parse_args()
    print(args)

    all = pd.read_table(args.denominator, header=None, skipinitialspace=True, sep=" ", index_col=1)
    deg = pd.read_table(args.numerator, header=None, skipinitialspace=True, sep=" ", index_col=1)

    df = pd.concat([all, deg], axis=1, sort=True).dropna()
    df.columns = ["All", "DEG"]
    df = df[df['All'] > args.threshold]
    df["Ratio"] = df["DEG"] / df["All"]
    df = df.sort_values('Ratio')

    y_pos = np.arange(df.shape[0])
    fig, ax = plt.subplots(1, 1, figsize=(args.sizex, args.sizey))
    plt.barh(y_pos, df["DEG"] / df["All"], align='center', alpha=0.5)
    plt.yticks(y_pos, df.index)
    plt.title('Ratio')
    
    if args.png:
        plt.savefig(args.output + ".png", bbox_inches='tight')
    else:
        plt.savefig(args.output + ".pdf", bbox_inches='tight')
        
