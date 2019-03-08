import numpy as np
import scipy.stats as sp
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.decomposition import PCA
#from MulticoreTSNE import MulticoreTSNE as TSNE
from sklearn.cluster import MiniBatchKMeans

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

def KMeansPlot(data, title, ncluster):
    import matplotlib.cm
    model = MiniBatchKMeans(random_state=0, n_clusters=ncluster, max_iter=10000)
    pca = PCA()
    matrix = pca.fit_transform(data)
    kmeans = model.fit_predict(matrix)
    color = matplotlib.cm.brg(np.linspace(0,1, np.max(kmeans) - np.min(kmeans)+1))

    for i in range(np.min(kmeans), np.max(kmeans)+1):
        plt.plot(matrix[kmeans == i][:,0],    matrix[kmeans == i][:,1], ".", color=color[i])
        plt.text(matrix[kmeans == i][:,0][0], matrix[kmeans == i][:,1][0], str(i+1), color="black", size=16)
    plt.title(title, size=16)

    return kmeans

def SwarmPlotFromDataFrame(df):
    s = df.stack()
    s.name = 'values'
    df_tidy = s.reset_index()
    sns.stripplot(data=df_tidy, x='level_1', y='values')
    
def BoxPlotFromDataFrame(df):
    s = df.stack()
    s.name = 'values'
    df_tidy = s.reset_index()
    sns.boxplot(data=df_tidy, y='label', x='values', hue='level_1', palette="PRGn", fliersize=0)
    sns.despine(offset=10, trim=True)
    plt.savefig("Permutation/compareloop.sns.boxplot.pdf")
