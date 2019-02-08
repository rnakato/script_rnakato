#! /usr/bin/env python
# -*- coding: utf-8 -*- 

import argparse
from InsulationScore import *

if(__name__ == '__main__'):
    parser = argparse.ArgumentParser()
    parser.add_argument("matrix", help="Input matrix", type=str)
    parser.add_argument("output", help="Output prefix", type=str)
    parser.add_argument("resolution", help="Resolution of the input matrix", type=int)
    parser.add_argument("--num4norm", help="Read number after normalization (default: 10000000)", type=int, default=10000000)
    parser.add_argument("--sizex", help="Size of x axis (default: 30)", type=int, default=30)
    parser.add_argument("--sizey", help="Size of y axis (default: 2)", type=int, default=2)

    args = parser.parse_args()
    print(args)
    
    matrix = loadJuicerMatrix(args.matrix)
    matrix = matrix * args.num4norm / np.nansum(matrix)

    MI = MultiInsulationScore(matrix.values, 1000000, 100000, args.resolution)

    # generate MI .png
    fig, ax = plt.subplots(1, 1, figsize=(args.sizex, args.sizey))
    plt.imshow(MI.MI, clim=(-1, 1), cmap=generate_cmap(['#d10a3f', '#FFFFFF', '#1310cc']), aspect="auto")
    plt.colorbar()
    plt.savefig(args.output + ".multiscale.png")
