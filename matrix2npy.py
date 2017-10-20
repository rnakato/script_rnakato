#! /usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import numpy as np
inputfile = sys.argv[1]
outputfile = sys.argv[2]

matrix = np.loadtxt(inputfile,delimiter="\t")
np.save(outputfile, matrix)
