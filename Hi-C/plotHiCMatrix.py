#! /usr/bin/env python
# -*- coding: utf-8 -*- 

import sys
import numpy as np
import scipy.stats as sp
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
sys.path.append("/home/git/script_rnakato/Hi-C")
from HiCmodule import *
cm = generate_cmap(['#1310cc', '#FFFFFF', '#d10a3f'])

filename = sys.argv[1]
output = sys.argv[2]
start = int(sys.argv[3])
end = int(sys.argv[4])
label = sys.argv[5]

data = pd.read_csv(filename, delimiter='\t', index_col=0)
resolution = data.index[1] - data.index[0] 

s = int(start / resolution)
e = int(end / resolution)

logmat = data.apply(np.log2)

plt.imshow(ExtractMatrix(logmat,s,e), clim=(-3, 12), cmap=cm)
plt.title(label)
plt.savefig(output)
