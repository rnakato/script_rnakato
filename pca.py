#! /usr/bin/env python
# -*- coding: utf-8 -*- 

import sys
import numpy
import sklearn.decomposition
 
d=2
data=numpy.loadtxt(sys.argv[1], delimiter="\t")
pca=sklearn.decomposition.PCA(d)
 
result=pca.fit_transform(data);
numpy.savetxt(sys.argv[2], result, delimiter="\t")
