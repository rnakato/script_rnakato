#! /usr/bin/env python
# -*- coding: utf-8 -*- 

import sys
import matplotlib
#matplotlib.use('Agg')
#import pylab
import matplotlib.pyplot as plt
import notebook
import seaborn as sns
import pandas as pd
import numpy as np
import math

status = []
num = 0
hash = {}

file=open("/home/rnakato/temp/2015_017A_KT55_D-n2-m1-hg38-raw-mpbl-sm0.comp1.bed", 'r')
file=open(sys.argv[1], 'r')
for line in file:
    if '#' in line or 'chromosome' in line:
        continue
#    print line
    clm = line[:-1].split('\t')
    if clm[3] == 'intergenic':
        continue
    status.append(clm[3])
    if not hash.has_key(clm[3]):
        hash.update({clm[3] :num})
        num += 1

file.close()

#print hash
#print len(hash)
#print len(status)

window = 100
lendata = len(status)/window +1
data = [[0 for i in range(len(hash))] for j in range(lendata)]
for i in range(0, len(status)):
#    print status[i]
 #   print hash[status[i]]
    data[i/window][hash[status[i]]] += 1.0/window

label = []
for st in hash:
#    print hash[st], st
    label.insert(hash[st], st)
    
#upstream	downstream	genic	intergenic
#4.41	3.62	38.93	53.04

all = 4.41 + 3.62 + 38.93
p = [38.93/all, 4.41/all, 3.62/all]

for i in range(0, len(data)):
    for j in range(len(hash)):
        data[i][j] = math.log(data[i][j]/p[j], 2) # log2x

#fig = matplotlib.pyplot.figure()
#ax = fig.add_subplot(1,1,1)
ax = sns.heatmap(data, cmap='Blues')
labels = ax.set_xticklabels(label,fontsize ="small")
sns.plt.axis()
sns.plt.show()
fig.savefig(sys.argv[1] + ".heatmap.png")

#fig.savefig("heatmap.png")
