#! /usr/bin/env python
# -*- coding: utf-8 -*- 
import numpy as np
import sys

def parse_argv():
    usage = 'Usage: \n    python {} <matrixdir> <outputfilename> <resolution> <observed/oe> <lim_pzero> [--help] [--includeintra] [--evenodd]'.format(__file__)
    arguments = sys.argv
    if len(arguments) == 1:
        print(usage)
        exit()
    # ファイル自身を指す最初の引数を除去
    arguments.pop(0)
    # - で始まるoption
    options = [option for option in arguments if option.startswith('-')]

    if '-h' in options or '--help' in options:
        print(usage)

    return arguments

def getfilename(i, j):
    return dir + "/" + str(res) + "/chr" + str(i) + "-chr" + str(j) + "/" + ntype + ".txt"

def getchrlen():
    chrlen = []
    for i in range(1,23):
        d = np.genfromtxt(getfilename(1, i), delimiter="\t", filling_values=(0, 0, 0))
        d = np.delete(d, -1, 1)
        chrlen.append(d.shape[1])
    
    #print(chrlen)
    #print(np.sum(chrlen))

    return chrlen

def getmatrix(i, j, chrlen, include_intra_read):
    if j < i:
        d = np.genfromtxt(getfilename(j, i), delimiter="\t", filling_values=(0, 0, 0))
        d = np.delete(d, -1, 1)
        return d.T
#        return np.zeros((chrlen[i-1], chrlen[j-1]))
    elif i==j and include_intra_read==False:
        return np.zeros((chrlen[i-1], chrlen[j-1]))
    else:
        d = np.genfromtxt(getfilename(i, j), delimiter="\t", filling_values=(0, 0, 0))
        d = np.delete(d, -1, 1)
        return d


if __name__ == '__main__':
    arguments = parse_argv()
    dir = arguments[0]
    outputfile = arguments[1]
    res = int(arguments[2])
    ntype = arguments[3]
    lim_pzero = float(arguments[4])

    include_intra_read = False
    if '--includeintra' in arguments:
        include_intra_read = True

    chrlen = getchrlen()
    
    if '--evenodd' in arguments:
        for i in range(1,23,2):
            print('i={0} j=2'.format(i))
            matrix = getmatrix(i, 2, chrlen, include_intra_read)
            for j in range(4,23,2):
                print('i={0} j={1}'.format(i,j))
                mat = getmatrix(i, j, chrlen, include_intra_read) 
                matrix = np.c_[matrix, mat]
            if i==1:
                A = matrix
            else:
                A = np.r_[A, matrix]
                
        print("before trim: ")
        print(A.shape)

        index1 = np.sum(A>0, axis=1)/A.shape[1] > lim_pzero
        index2 = np.sum(A>0, axis=0)/A.shape[0] > lim_pzero
        A = A[index1]
        A = A[:, index2]

        print("after trim: ")
        print(A.shape)
                
    else:
        for i in range(1,23):
            matrix = getmatrix(i, 1, chrlen, include_intra_read)
            for j in range(2,23):
                mat = getmatrix(i, j, chrlen, include_intra_read) 
                matrix = np.c_[matrix, mat]
            if i==1:
                A = matrix
            else:
                A = np.r_[A, matrix]

        print("matrix size: ")
        print(A.shape)

    np.save(outputfile, A)
