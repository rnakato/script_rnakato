###! /usr/bin/env python
# -*- coding: utf-8 -*-

import numpy as np
import pandas as pd
import math
import sys
import time
from math import log
import matplotlib.pyplot as plt
from scipy.stats import binom
#from operator import itemgetter
import argparse
import multiprocessing as mp
from multiprocessing import Pool

def argwrapper(args):
    return args[0](*args[1:])

def calcCDI_eachrow(i, ProbArray, CountArray, ngene, ncell):
    array = np.zeros(ngene)
    for j in range(i + 1, ngene):
        x = CountArray[j]
        p = ProbArray[j]
        # 　生存関数 binom.sfを使う　xが入っていないのでx-1に気をつけること
        prob = binom.sf(x - 1, ncell, p)
        if prob <= 0:
            val = -10000000.0
        else:
            val = -(math.log10(prob))
        array[j] = val

    del ProbArray
    del CountArray
    return array

# 各遺伝子ペアで(gi,gj)=(0,1)となるサンプル数がCount_excl[j][i]回以上になるp値(3prob1)と排他性スコアの計算
# 各遺伝子ペアで(gi,gj)=(1,0)となるサンプル数がCount_excl[i][j]回以上になるp値(prob2)と排他性スコアの計算
# 便宜的に2つのp値の平均を計算する
def calcEEI_eachrow(i, ProbArray_i, CountArray_i, ProbArray_T_i, CountArray_T_i, ngene, ncell):
#def calcEEI_eachrow(i, ProbMatrix, Count_excl, ngene, ncell):
    array = np.zeros(ngene)
    for j in range(i + 1, ngene):
 #       x1 = Count_excl[j][i]
  #      p1 = ProbMatrix[i][j]
        x1 = CountArray_T_i[j]
        p1 = ProbArray_i[j]
        prob1 = binom.sf(x1 - 1, ncell, p1)
        #      x2 = Count_excl[i][j]
        #     p2 = ProbMatrix[j][i]
        x2 = CountArray_i[j]
        p2 = ProbArray_T_i[j]
        prob2 = binom.sf(x2 - 1, ncell, p2)
        if prob1 <= 0 or prob2 <= 0:
            val = -10000000.0
        else:
            val = ((-(math.log10(prob1))) + (-(math.log10(prob2)))) / 2
        array[j] = val
    return array

def genMatrix_MultiProcess(Prob_joint, Count_joint, MatType, ngene, ncell, *, ncore=4):
    context = mp.get_context('spawn')

    p = Pool(ncore)
    func_args = []

    print(MatType, ngene, ncell, ncore)

    for i in range(0, ngene):
        if MatType == "CDI":
            func_args.append((calcCDI_eachrow, i, Prob_joint[i], Count_joint[i], ngene, ncell))
        elif MatType == "EEI":
            #func_args.append((calcEEI_eachrow, i, Prob_joint, Count_joint, ngene, ncell))
            func_args.append((calcEEI_eachrow, i, Prob_joint[i], Count_joint[i], Prob_joint.T[i], Count_joint.T[i], ngene, ncell))
        else:
            print("Error: illegal MatType for genMatrix_MultiProcess.")
            sys.exit()

    results = p.map(argwrapper, func_args)
    p.close()

    Matrix = np.array(results)
    Matrix = Matrix + Matrix.T - np.diag(np.diag(Matrix))

    return Matrix

def generate_CDImatrix(A, args):
    ngene = A.shape[0]
    ncell = A.shape[1]
    # 各遺伝子ごとにnon-zero値を持つサンプル数をカウントと確率の計算
    is_nonzeroMat = A > 0
    p_nonzero = np.sum(is_nonzeroMat, axis=1) / ncell
    plt.plot(np.sort(p_nonzero))
    plt.xlabel("Cells")
    plt.ylabel("Proportion of nonzero genes")
    plt.savefig(args.output + "_p_nonzero.png")

    if(args.gpu):   # cupy
        print("using GPU for CDI calculation.")
        import cupy as cp
        p_nonzero = cp.asarray(p_nonzero)
        is_nonzeroMat = cp.asarray(is_nonzeroMat)
        Prob_joint = p_nonzero * p_nonzero[:, cp.newaxis]
        Count_joint = cp.zeros((ngene, ngene), dtype=cp.int64)
        for i in range(ngene):
            Count_joint[i] = cp.sum(is_nonzeroMat[i] * is_nonzeroMat, axis=1)

        Prob_joint = cp.asnumpy(Prob_joint)
        Count_joint = cp.asnumpy(Count_joint)
    else:      #numpy
        print("using CPU for CDI calculation.")
        Prob_joint = p_nonzero * p_nonzero[:, np.newaxis]
        Count_joint = []
        for row in is_nonzeroMat:
            Count_joint.extend(np.sum(row * is_nonzeroMat, axis=1))
        Count_joint = np.array(Count_joint).reshape(ngene, ngene)
        
    np.savetxt(args.output + "_number_joint_nonzero_gene_thre10.0.txt", Count_joint, delimiter="\t")

    print("Count_jointly expressed samples----------------------")
    CDI = genMatrix_MultiProcess(Prob_joint, Count_joint, "CDI", ngene, ncell, ncore=args.threads)

    return CDI

def generate_EEImatrix(A, args):
    ngene = A.shape[0]
    ncell = A.shape[1]
    is_nonzeroMat = A > 0
    p_nonzero = np.sum(is_nonzeroMat, axis=1) / ncell
    p_zero = np.sum(A == 0, axis=1) / ncell
    np.savetxt(args.output + "_prob_nonzero.txt", p_nonzero, delimiter="\t")
    np.savetxt(args.output + "_prob_zero.txt", p_zero, delimiter="\t")

    if(args.gpu):   # cupy
        print("using GPU for EEI calculation.")
        import cupy as cp
        p_nonzero = cp.asarray(p_nonzero)
        p_zero = cp.asarray(p_zero)
        is_nonzeroMat = cp.asarray(is_nonzeroMat)
        notA = cp.asarray(np.logical_not(A))

        Prob_joint = p_nonzero * p_zero[:, np.newaxis]
        Count_excl = cp.zeros((ngene, ngene), dtype=np.int64)
        for i in range(ngene):
            Count_excl[i] = cp.sum(cp.logical_and(is_nonzeroMat[i], notA), axis=1)

        Prob_joint = cp.asnumpy(Prob_joint)
        Count_excl = cp.asnumpy(Count_excl)
    else:      #numpy
        print("using CPU for EEI calculation.")
        # 各遺伝子ペアで排他的発現をする確率の初期化と確率計算
        Prob_joint = p_nonzero * p_zero[:, np.newaxis]
        # 1回の行列演算で排他的発現(g1,g2)=(1,0) と(g2,g1)=(1,0)=(g1,g2)=(0,1)を持つサンプル数をカウント
        notA = np.logical_not(A)
        Count_excl = []
        for row in is_nonzeroMat:
            # Aと(NOT　A)の転置行列をかけた行列の、各要素のサンプル数をカウント
            Count_excl.extend(np.sum(np.logical_and(row, notA), axis=1))
        Count_excl = np.array(Count_excl).reshape(ngene, ngene)

    np.savetxt(args.output + "_data_exclusive.txt", Count_excl, delimiter="\t")
    print("Count_the number of samples which two genes are expressed exclusively----")

    EEI = genMatrix_MultiProcess(Prob_joint, Count_excl, "EEI", ngene, ncell, ncore=args.threads)
    return EEI


def calc_degree(Matrix, thre, ngene, filename):
    df = pd.DataFrame(Matrix)
    degree = np.sum(df > thre).tolist()
    df = df[df > thre]
    df = df.stack().reset_index()
    df.columns = ["i", "j", "val"]
    df = df.sort_values(["i", "val"], ascending=[True, False])

    data_file2 = "PBMC_10cell_" + filename + ".txt"
    df.to_csv(data_file2, sep="\t", header=False, index=False)
    return degree


def calc_degree_dist(degree, filename, args):
    max_value = max(degree)
    min_value = min(degree)
    value_range = max_value - min_value
    print("max degree:%.3F min degree:%.3F value_width=%.3F" % (max_value, min_value, value_range))

    freq = []
    for a in range(min_value + 1, max_value + 1):
        fnum = degree.count(a)
        if fnum > 0:
            freq.append([fnum, a])

    df = pd.DataFrame(freq, columns=["The number of genes", "Degree"])

    log_df = np.log(df)
    log_df = log_df.rename(
        columns={
            "The number of genes": "Log_The number of genes",
            "Degree": "Log_Degree",
        }
    )
    merge = pd.concat([log_df, df], axis=1)
    merge.to_csv(args.output + "_" + filename + "_degree_distribution_thre10.0.csv", sep="\t")


## 全細胞で発現量0の遺伝子を除外
def get_nonzero_matrix(input_data, args):
    A = np.array(input_data)
    print("number of all genes: ", A.shape[0])

    zero = np.all(A == 0, axis=1)
    nonzero = np.logical_not(zero)
    A = A[nonzero]

    # 各行（各遺伝子）ごとに(axis=1)、発現量>0 となる細胞数をカウントして、それらをcount_expに格納
    # 遺伝子番号、遺伝子ID,　遺伝子名、発現している細胞数をファイルに書き出す
    input_data.nonzero = input_data[nonzero]
    df = pd.DataFrame(
        {
            "index": input_data.nonzero.index,
            "count_exp": np.sum(input_data.nonzero > 0, axis=1).values,
        }
    )
    df.to_csv(args.output + "_number_nonzero_exp_gene_thre10.0.txt", sep="\t", header=False)

    return A


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("matrix", help="Input matrix", type=str)
    parser.add_argument("output", help="Output prefix", type=str)
    parser.add_argument("--threCDI", help="threshold for CDI (default: 20.0)", type=float, default=20)
    parser.add_argument("--threEEI", help="threshold for EEI (default: 10.0)", type=float, default=10)
    parser.add_argument("--tab", help="Specify when the input file is tab-delimited (tsv)", action="store_true")
    parser.add_argument("--gpu", help="GPU mode", action="store_true")
    parser.add_argument("-p", "--threads", help="number of threads (default: 2)", type=int, default=2)

    args = parser.parse_args()
    print(args)

    startt = time.time()

    if (args.tab):
        input_data = pd.read_csv(args.matrix, index_col=0, sep="\t")
    else:
        input_data = pd.read_csv(args.matrix, index_col=0)
#        import dask.dataframe as dd
 #       input_data =  dd.read_csv(args.matrix).compute()

    A = get_nonzero_matrix(input_data, args)
    ngene = A.shape[0]
    ncell = A.shape[1]
    print("number of nonzero genes: ", ngene)
    print("number of cells: ", ncell)

    CDI = generate_CDImatrix(A, args)
    EEI = generate_EEImatrix(A, args)
    DEGREE   = calc_degree(CDI, args.threCDI, ngene, "cdi_network_sgscore_CDI_data_thre_20.0")
    DEGREE_E = calc_degree(EEI, args.threEEI, ngene, "eei_score_EEI_data_thre_10.0")

    print("Finish Co-dependency Network!")
    elapsed_time = time.time() - startt
    print("Elapsed_time:{0}".format(elapsed_time) + "[sec]")
    print("*************************************************************")

    # CDI, EEIの次数分布
    print("CDI,EEI次数分布")
    calc_degree_dist(DEGREE,   "CDI", args)
    calc_degree_dist(DEGREE_E, "EEI", args)

    print("Finish to write the CDI and EEI degreee distribution!")


if __name__ == "__main__":
    main()
