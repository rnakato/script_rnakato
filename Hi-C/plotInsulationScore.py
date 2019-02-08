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
    parser.add_argument("--distance", help="Distance of Insulation Score (default: 500000)", type=int, default=500000)
    parser.add_argument("--sizex", help="Size of x axis (default: 15)", type=int, default=15)
    parser.add_argument("--sizey", help="Size of y axis (default: 2)", type=int, default=2)

    args = parser.parse_args()
    print(args)
    
    matrix = loadJuicerMatrix(args.matrix)
    matrix = matrix * args.num4norm / np.nansum(matrix)

    MI = MultiInsulationScore(matrix.values, 1000000, 100000, args.resolution)

    # generate InsulationScore .png
    df = MI.getInsulationScore(distance=args.distance)
    df = df.replace([np.inf, -np.inf], 0)
    fig, ax = plt.subplots(1, 1, figsize=(args.sizex, args.sizey))
    plt.plot(df.values)

    boundary = getTADboundary(df.values, args.resolution)
    for x in boundary:
        plt.axvline(x, color="orange")
    
    ax.set_ylim([-2, 2])
    plt.savefig(args.output + ".InsulationScore.png")
