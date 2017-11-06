#! /usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import numpy as np
inputfile = sys.argv[1]
outputfile = sys.argv[2]

matrix = np.loadtxt(inputfile,delimiter="\t")

if len(sys.argv) > 6:
    s1 = int(sys.argv[3])
    e1 = int(sys.argv[4])
    s2 = int(sys.argv[5])
    e2 = int(sys.argv[6])
    matrix = matrix[s1:e1,s2:e2]
elif len(sys.argv) > 4:
    s = int(sys.argv[3])
    e = int(sys.argv[4])
    matrix = matrix[s:e,s:e]

np.savetxt(outputfile, matrix)
