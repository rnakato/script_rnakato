#! /usr/bin/env python
# -*- coding: utf-8 -*- 

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import argparse
from loadData import loadJuicerMatrix
from generateCmap import generate_cmap
#import pdb; pdb.set_trace()

def calceach(mat, squaresize, resolution):
    matsize = int(squaresize / resolution)
    array = np.zeros(mat.shape[0])
    for i in range(mat.shape[0]):
        if(i - matsize < 0 or i + matsize >= mat.shape[0]): continue
        array[i] = mat[i-matsize: i-1, i+1: i+matsize].mean()
        
    array = np.log2(array/np.nanmean(array))
    return array

def calcInsulationScore(mat, max_sqsize, step, resolution):
    imax = int(max_sqsize/step)
    for i in range(imax, 0, -1):
        if i==imax: 
            InsulationScore = calceach(mat, i * step, resolution)
        else: 
            InsulationScore = np.c_[InsulationScore, calceach(mat, i * step, resolution)]
            
    InsulationScore = InsulationScore.T
    df = pd.DataFrame(InsulationScore)
    df.index = np.arange(imax, 0, -1) * step
    df.columns = df.columns * resolution
    return df

class MultiInsulationScore:
    def __init__(self, mat, max_sqsize, step, resolution):
        imax = int(max_sqsize/step)
        for i in range(imax, 0, -1):
            if i==imax: 
                InsulationScore = calceach(mat, i * step, resolution)
            else: 
                InsulationScore = np.c_[InsulationScore, calceach(mat, i * step, resolution)]
                
        InsulationScore = InsulationScore.T
        self.MI = pd.DataFrame(InsulationScore)
        self.MI.index = np.arange(imax, 0, -1) * step
        self.MI.columns = self.MI.columns * resolution
                
    def getInsulationScore(self, *, distance=500000):
        i = np.where(self.MI.index == distance)[0][0]
        return self.MI.iloc[i:i+1].T

def getTADboundary(array, resolution):
    distance = int(100000 / resolution)
    slop = np.zeros(array.shape[0])
    for i in range(distance, array.shape[0] - distance):
        slop[i] = array[i - distance] - array[i + distance]
        
    boundary = []
    for i in range(1, len(slop)):
        if(slop[i-1] > 0 and slop[i] < 0 and array[i] <= -0.1):
            boundary.append(i)
    return boundary

if(__name__ == '__main__'):
    parser = argparse.ArgumentParser()
    parser.add_argument("matrix", help="Input matrix", type=str)
    parser.add_argument("output", help="Output prefix", type=str)
    parser.add_argument("chr", help="Chromosome", type=str)
    parser.add_argument("resolution", help="Resolution of the input matrix", type=int)
    parser.add_argument("--num4norm", help="Read number after normalization (default: 10000000)", type=int, default=10000000)
    parser.add_argument("--distance", help="Distance of Insulation Score (default: 500000)", type=int, default=500000)

    args = parser.parse_args()
    print(args)

    matrix = loadJuicerMatrix(args.matrix)
    matrix = matrix * args.num4norm / np.nansum(matrix)

    MI = MultiInsulationScore(matrix.values, 1000000, 100000, args.resolution)

    # output InsulationScore to BedGraph
    df = MI.getInsulationScore(distance=args.distance)
    df = df.replace([np.inf, -np.inf], 0)
    df.columns = ["Insulation Score"]
    df["chr"] = args.chr
    df["start"] = df.index
    df["end"] = df["start"] + args.resolution
    df = df.loc[:,["chr","start","end","Insulation Score"]]
    df.to_csv(args.output + ".bedGraph", sep="\t", header=False, index=False)
