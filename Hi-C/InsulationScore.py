#! /usr/bin/env python
# -*- coding: utf-8 -*- 

import numpy as np
import pandas as pd
import sys
import os
from loadData import loadJuicerMatrix
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


if(__name__ == '__main__'):
    obsfile = sys.argv[1]
    chr = sys.argv[2]
    resolution = int(sys.argv[3])
    output = sys.argv[4]

    matrix = loadJuicerMatrix(obsfile)
    matrix = matrix * 10000000 / np.nansum(matrix)

    MI = MultiInsulationScore(matrix.values, 1000000, 100000, resolution)

    df = MI.getInsulationScore(distance=500000)
    df = df.replace([np.inf, -np.inf], 0)
    df.columns = ["Insulation Score"]
    df["chr"] = chr
    df["start"] = df.index
    df["end"] = df["start"] + resolution
    df = df.loc[:,["chr","start","end","Insulation Score"]]
    df.to_csv(output, sep="\t", header=False, index=False)
