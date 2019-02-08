import numpy as np
import scipy.stats as sp
import pandas as pd
import matplotlib.pyplot as plt
from sklearn import linear_model
from InsulationScore import *
from loadData import loadJuicerMatrix

#自分で定義したカラーマップを返す
# https://qiita.com/kenmatsu4/items/fe8a2f1c34c8d5676df8
def generate_cmap(colors):
    from matplotlib.colors import LinearSegmentedColormap
    values = range(len(colors))

    vmax = np.ceil(np.max(values))
    color_list = []
    for v, c in zip(values, colors):
        color_list.append( ( v/ vmax, c) )
    return LinearSegmentedColormap.from_list('custom_cmap', color_list)

def getNonZeroMatrix(A, lim_pzero):
    A = A.fillna(0)
    pzero_row = A[A>0].count(axis=0)/A.shape[0]
    index = pzero_row[pzero_row > lim_pzero].index
    pzero_col = A[A>0].count(axis=1)/A.shape[1]
    columns = pzero_col[pzero_col > lim_pzero].index

    A = A[index]
    A = A.loc[columns]

    return A

def loadEigen(filename, refFlat, chr, res):
    print(filename)
    if filename == "": return
    
    eigen = np.loadtxt(filename)
    gene = pd.read_csv(refFlat, delimiter='\t', header=None, index_col=0)
    gene = gene[gene.iloc[:,1] == chr]
    gene = gene.iloc[:,5].values

    genenum = np.zeros(len(eigen), int)
    for row in gene:
        if int(row/res)>= len(eigen): continue
        genenum[int(row/res)] += 1

    from scipy.stats import pearsonr
    if pearsonr(genenum[~np.isnan(eigen)], eigen[~np.isnan(eigen)])[0] < 0:
        eigen = -eigen
        
    return eigen

class JuicerMatrix:
    def __init__(self, norm, rawmatrix, oematrix, eigenfile, refFlat, chr, res):
        self.res = res
        self.raw = loadJuicerMatrix(rawmatrix)
        self.oe  = loadJuicerMatrix(oematrix)
        self.eigen = loadEigen(eigenfile, refFlat, chr, res)
        if norm == "RPM":
            self.raw = self.raw * 10000000 / np.nansum(self.raw)
            self.oe  = self.oe  * 10000000 / np.nansum(self.oe)
        self.InsulationScore = MultiInsulationScore(self.getmatrix().values, 1000000, 100000, self.res)

    def getmatrix(self, *, isOE=False, isNonZero=False):
        if isOE == False:
            if isNonZero == True:
                return getNonZeroMatrix(self.raw, 0)
            else:
                return self.raw
        else:
            if isNonZero == True:
                return getNonZeroMatrix(self.oe, 0)
            else:
                return self.oe
        
    def getlog(self, *, isOE=False, isNonZero=False):
        mat = self.getmatrix(isOE=isOE, isNonZero=isNonZero)
        logmat = mat.apply(np.log1p)
        return logmat

    def getZscore(self, *, isOE=False):
        logmat = self.getlog(isOE=isOE)
        zmat = pd.DataFrame(sp.stats.zscore(logmat, axis=1), index=logmat.index, columns=logmat.index)
        return zmat

    def getPearson(self, *, isOE=False):
        oe = self.getlog(isOE=isOE)
#        oe = self.getmatrix(isOE=isOE)
#        cov = logmat.cov()
 #       ccmat = np.corrcoef(cov)
        ccmat = np.corrcoef(oe)
        ccmat[np.isnan(ccmat)] = 0
        ccmat = pd.DataFrame(ccmat, index=oe.index, columns=oe.index)
        return ccmat
    
    def getEigen(self):
        from sklearn.decomposition import PCA
        pca = PCA()
        ccmat = self.getPearson()
#        index = np.isnan(ccmat).all(axis=1)
        transformed = pca.fit_transform(ccmat)
        pc1 = transformed[:, 0]
#        pc1[index] = np.nan
        return transformed[:, 0]

    def getInsulationScore(self, *, distance=500000):
        return MI.getInsulationScore(distance=distance)
        i = np.where(self.InsulationScore.index == distance)[0][0]
        return self.InsulationScore.iloc[i:i+1].T

    def getMultiInsulationScore(self):
        return self.InsulationScore

    def getTADboundary(self):
        distance = int(100000 / self.res)
        array = self.getInsulationScore().values
        slop = np.zeros(array.shape[0])
        for i in range(distance, array.shape[0] - distance):
            slop[i] = array[i - distance] - array[i + distance]

        boundary = []
        for i in range(1, len(slop)):
            if(slop[i-1] > 0 and slop[i] < 0 and array[i] <= -0.1):
                boundary.append(i)
        return boundary
    
def ExtractMatrix(mat,s,e):
    if e==-1:
        return mat.values[s:,s:]
    else:
        return mat.values[s:e,s:e]
    
def ExtractMatrixIndex(mat,index1,index2):
    mat = mat[index1,:]
    mat = mat[:,index2]
    return mat

def ExtractTopOfPC1(mat, pc1, nbin):
    sortedindex = np.argsort(pc1)
    sortmat = mat[sortedindex,:]
    sortmat = sortmat[:,sortedindex]
    sortmat = np.concatenate((sortmat[:nbin,:] , sortmat[-nbin:,:]), axis=0)
    sortmat = np.concatenate((sortmat[:,:nbin] , sortmat[:,-nbin:]), axis=1)
    return sortmat

def drawMatrices(matrices):
    fig = plt.figure(figsize=(20, 20))
    ax1 = fig.add_subplot(3,3,1)
    ax2 = fig.add_subplot(3,3,2)
    ax3 = fig.add_subplot(3,3,3)
    ax4 = fig.add_subplot(3,3,4)
    ax5 = fig.add_subplot(3,3,5)
    ax6 = fig.add_subplot(3,3,6)
    ax7 = fig.add_subplot(3,3,7)
    ax8 = fig.add_subplot(3,3,8)
    ax1.imshow(matrices[0])
    ax2.imshow(matrices[1])
    ax3.imshow(matrices[2])
    ax4.imshow(matrices[3])
    ax5.imshow(matrices[4])
    ax6.imshow(matrices[5])
    ax7.imshow(matrices[6])
    ax8.imshow(matrices[7])
    ax1.set_title("Ct1")
    ax2.set_title("Ct2")
    ax3.set_title("Rad21")
    ax4.set_title("NIPBL")
    ax5.set_title("CTCF") 
    ax6.set_title("ESCO1")
    ax7.set_title("ESCO2")
    ax8.set_title("ESCO12")

def drawMatrices_line(matrices):
    fig = plt.figure(figsize=(20, 10))
    ax1 = fig.add_subplot(1,7,1)
    ax2 = fig.add_subplot(1,7,2)
    ax3 = fig.add_subplot(1,7,3)
    ax4 = fig.add_subplot(1,7,4)
    ax5 = fig.add_subplot(1,7,5)
    ax6 = fig.add_subplot(1,7,6)
    ax7 = fig.add_subplot(1,7,7)
    ax1.imshow(matrices[0])
    ax2.imshow(matrices[1])
    ax3.imshow(matrices[2])
    ax4.imshow(matrices[3])
    ax5.imshow(matrices[4])
    ax6.imshow(matrices[5])
    ax7.imshow(matrices[6])

def drawMatricesComp(matrices):    
    cm = generate_cmap(['#1310cc', '#FFFFFF', '#d10a3f'])
    fig = plt.figure(figsize=(20, 20))
    ax1 = fig.add_subplot(3,3,1)
    ax2 = fig.add_subplot(3,3,2)
    ax3 = fig.add_subplot(3,3,3)
    ax4 = fig.add_subplot(3,3,4)
    ax5 = fig.add_subplot(3,3,5)
    ax6 = fig.add_subplot(3,3,6)
    ax7 = fig.add_subplot(3,3,7)
    ax1.imshow(matrices[2] - matrices[0], clim=(-3, 3), cmap=cm)
    ax2.imshow(matrices[3] - matrices[0], clim=(-3, 3), cmap=cm)
    ax3.imshow(matrices[4] - matrices[0], clim=(-3, 3), cmap=cm)
    ax4.imshow(matrices[5] - matrices[1], clim=(-3, 3), cmap=cm)
    ax5.imshow(matrices[6] - matrices[1], clim=(-3, 3), cmap=cm)
    ax6.imshow(matrices[7] - matrices[1], clim=(-3, 3), cmap=cm)
    ax7.imshow(matrices[1] - matrices[0], clim=(-3, 3), cmap=cm)
    ax1.set_title("Rad21")
    ax2.set_title("NIPBL")
    ax3.set_title("CTCF") 
    ax4.set_title("ESCO1")
    ax5.set_title("ESCO2")
    ax6.set_title("ESCO12")
    ax7.set_title("Ct")

def drawMatricesComp_line(matrices):
    cm = generate_cmap(['#1310cc', '#FFFFFF', '#d10a3f'])
    fig = plt.figure(figsize=(20, 10))
    ax1 = fig.add_subplot(1,6,1)
    ax2 = fig.add_subplot(1,6,2)
    ax3 = fig.add_subplot(1,6,3)
    ax4 = fig.add_subplot(1,6,4)
    ax5 = fig.add_subplot(1,6,5)
    ax6 = fig.add_subplot(1,6,6)
    ax1.imshow(matrices[2] - matrices[0], clim=(-3, 3), cmap=cm)
    ax2.imshow(matrices[3] - matrices[0], clim=(-3, 3), cmap=cm)
    ax3.imshow(matrices[4] - matrices[0], clim=(-3, 3), cmap=cm)
    ax4.imshow(matrices[5] - matrices[1], clim=(-3, 3), cmap=cm)
    ax5.imshow(matrices[6] - matrices[1], clim=(-3, 3), cmap=cm)
    ax6.imshow(matrices[7] - matrices[1], clim=(-3, 3), cmap=cm)
    
def drawHeatmap_RawandComp(mat1, mat2):
    cm = generate_cmap(['#1310cc', '#FFFFFF', '#d10a3f'])
    fig = plt.figure(figsize=(20, 60))
    ax1 = fig.add_subplot(1,3,1)
    ax2 = fig.add_subplot(1,3,2)
    ax3 = fig.add_subplot(1,3,3)
    ax1.imshow(mat1)
    ax2.imshow(mat2)
    ax3.imshow(mat2 - mat1, clim=(-4, 4), cmap=cm)

def getCompartment(mat, pc1):
    indexA = pc1 > 1
    indexB = pc1 < -1
    A = mat[indexA]
    A = A[:,indexA]
    B = mat[indexB]
    B = B[:,indexB]
    return A, B

def getCompartment_inter(mat, pc1_odd, pc1_even, nbin):
    sortedindex_odd = np.argsort(pc1_odd)
    sortedindex_even = np.argsort(pc1_even)
    sortmat = mat[sortedindex_odd,:]
    sortmat = sortmat[:,sortedindex_even]
    A = sortmat[:nbin,:nbin]
    B = sortmat[-nbin:,-nbin:]
#    indexA_odd = pc1_odd > 1
#    indexB_odd = pc1_odd < -1
 #   indexA_even = pc1_even > 1
  #  indexB_even = pc1_even < -1
  #  A = mat[indexA_odd]
  #  A = A[:,indexA_even]
  #  B = mat[indexB_odd]
   # B = B[:,indexB_even]
    return A, B
