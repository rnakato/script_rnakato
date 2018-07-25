#! /usr/bin/env python
# -*- coding: utf-8 -*- 

import numpy as np
import matplotlib
matplotlib.use('Agg')
import pylab
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from HiCmodule import *

normalizetype="RPM"

obsfile = sys.argv[1]
#oefile = sys.argv[2]
chr = sys.argv[2]
resolution = int(sys.argv[3])
output = sys.argv[4]

Ct1 = JuicerMatrix(normalizetype, obsfile, obsfile, chr, resolution)

MIS = Ct1.getMultiInsulationScore()
fig, ax = plt.subplots(1, 1, figsize=(30, 2))
plt.imshow(MIS, clim=(-1, 1), cmap=generate_cmap(['#d10a3f', '#FFFFFF', '#1310cc']), aspect="auto")
plt.colorbar()
plt.savefig(output + ".multiscale.png")

IS = Ct1.getInsulationScore()
fig, ax = plt.subplots(1, 1, figsize=(15, 2))
plt.plot(IS.values)

boundary = Ct1.getTADboundary()
for x in boundary:
    plt.axvline(x, color="orange")
    
ax.set_ylim([-2, 2])
#ax.set_xlim([100,500])

plt.savefig(output + ".InsulationScore.png")

start = IS.index[boundary]
end = start + resolution

path = 'data/src/test.txt'

with open(output + ".boundary.bed", "w", encoding="utf-8") as f:
    for s, e in zip(start,end):
        f.write(chr + "\t" + str(s) + "\t" + str(e) + "\n")
#        f.write(chr, s, e, sep="\t")
