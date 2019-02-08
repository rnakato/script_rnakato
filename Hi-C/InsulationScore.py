#! /usr/bin/env python
# -*- coding: utf-8 -*- 

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import sys
import os
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
    obsfile = sys.argv[1]
    chr = sys.argv[2]
    resolution = int(sys.argv[3])
    output = sys.argv[4]

    matrix = loadJuicerMatrix(obsfile)
    matrix = matrix * 10000000 / np.nansum(matrix)

    MI = MultiInsulationScore(matrix.values, 1000000, 100000, resolution)

    # output InsulationScore to BedGraph
    df = MI.getInsulationScore(distance=500000)
    df = df.replace([np.inf, -np.inf], 0)
    df.columns = ["Insulation Score"]
    df["chr"] = chr
    df["start"] = df.index
    df["end"] = df["start"] + resolution
    df = df.loc[:,["chr","start","end","Insulation Score"]]
    df.to_csv(output + ".bedGraph", sep="\t", header=False, index=False)

    # generate MI .png
    fig, ax = plt.subplots(1, 1, figsize=(30, 2))
    plt.imshow(MI.MI, clim=(-1, 1), cmap=generate_cmap(['#d10a3f', '#FFFFFF', '#1310cc']), aspect="auto")
    plt.colorbar()
    plt.savefig(output + ".multiscale.png")

    # generate InsulationScore .png
    fig, ax = plt.subplots(1, 1, figsize=(15, 2))
    plt.plot(df["Insulation Score"].values)

    boundary = getTADboundary(df["Insulation Score"].values, resolution)
    for x in boundary:
        plt.axvline(x, color="orange")
    
    ax.set_ylim([-2, 2])
    plt.savefig(output + ".InsulationScore.png")
