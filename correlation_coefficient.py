#! /usr/bin/env python
# -*- coding: utf-8 -*-
import sys 
from scipy.stats.stats import pearsonr
from scipy.stats.stats import spearmanr
from optparse import OptionParser

usage = "usage: %prog [options] line1 line2"
parser = OptionParser(usage=usage)
parser.add_option("-f", "--file", dest="filename",
                  help="input filename", metavar="FILE")
parser.add_option("-l", "--line", action="append",
                  help="two line numbers", type="int", metavar="<int>")
parser.add_option("-s", "--spearman",
                  action="store_true", dest="spearman", default=False,
                  help="use spearman correlation coefficient")
parser.add_option("-b", "--both", action="store_true", default=False,
                  help="show cc and p-value")

(options, args) = parser.parse_args()

array1 = []
array2 = []

file=open(options.filename, 'r')
for line in file:
    clm = line[:-1].split('\t')
    a1 = float(clm[options.line[0]])
    a2 = float(clm[options.line[1]])
    array1.append(a1)
    array2.append(a2)

file.close()

if(options.spearman):
    cc = spearmanr(array1,array2)
    if(options.both):
        print cc
    else:
        print cc[0]
else:
    cc = pearsonr(array1,array2)
    if(options.both):
        print cc
    else:
        print cc[0]

    
