#! /usr/bin/env python
# -*- coding: utf-8 -*- 
import sys
import matplotlib
matplotlib.use('Agg')
import pylab

len = []
dif = []
rdif = []

file=open(sys.argv[1], 'r')
for line in file:
    clm = line[:-1].split('\t')
    mut = int(clm[1])
    strand = clm[3]
    start = int(clm[5])
    end = int(clm[6])
    l = end-start
    len.append(l)
    if(strand == "+"):
        d = end - mut
    else:
        d = mut - start

    rd = 1 - float(d)/l
    
    dif.append(d)
    rdif.append(rd)
        
file.close()

fig = matplotlib.pyplot.figure()
ax = fig.add_subplot(1,1,1)
#matplotlib.pyplot.xscale("log")
matplotlib.pyplot.xlim([0,1000])
ax.hist(dif, bins=2000)
fig.savefig(sys.argv[1] + ".dif.png")
fig2 = matplotlib.pyplot.figure()
ax = fig2.add_subplot(1,1,1)
ax.hist(rdif, bins=50)
fig2.savefig(sys.argv[1] + ".rdif.png")

