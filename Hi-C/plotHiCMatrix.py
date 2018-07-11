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
cm = generate_cmap(['#FFFFFF', '#d10a3f'])

filename = sys.argv[1]
output = sys.argv[2]
start = int(sys.argv[3])
end = int(sys.argv[4])
label = sys.argv[5]

data = pd.read_csv(filename, delimiter='\t', index_col=0)
resolution = data.index[1] - data.index[0] 

s = int(start / resolution)
e = int(end / resolution)

# Total read normalization
data = data * 10 * data.shape[0] * data.shape[1] / np.nansum(data)

# log2
#logmat = data.apply(np.log2)

fig = plt.figure(figsize=(8, 8))
#plt.imshow(ExtractMatrix(logmat,s,e), clim=(0, 500), cmap=cm)
plt.imshow(ExtractMatrix(data,s,e), clim=(0, 100), cmap=cm)
plt.title(label)
plt.savefig(output)
