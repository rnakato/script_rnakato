import numpy as np
import scipy.stats as sp
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

def corrfunc(x, y, **kws):
    r, _ = sp.spearmanr(x, y)
    ax = plt.gca()
    ax.annotate("r = {:.2f}".format(r), xy=(.1, .9), xycoords=ax.transAxes)

def drawPairGridfromDataFrame(df, filename):
    g = sns.PairGrid(df, palette=["red"], size=2)
    g.map_lower(plt.scatter, s=10)
    g.map_diag(sns.distplot, kde=False)
    g.map_upper(sns.kdeplot, shade=True) #cmap="Blues_d", 
    g.map_upper(corrfunc)
    g.savefig(filename)
