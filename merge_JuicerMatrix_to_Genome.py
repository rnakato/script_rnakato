#! /usr/bin/env python
# -*- coding: utf-8 -*- 
import numpy as np
import sys

def parse_argv():
    usage = 'Usage: \n    python {} <matrixdir> <outputfilename> <resolution> <observed/oe> [--help] [--includeintra]'.format(__file__)
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
    return "matrix/" + str(res) + "/chr" + str(i) + "-chr" + str(j) + "/" + ntype + ".txt"

def getchrlen():
    chrlen = []
    for i in range(1,23):
        d = np.genfromtxt(getfilename(1, i), delimiter="\t", filling_values=(0, 0, 0))
        d = np.delete(d, -1, 1)
        chrlen.append(d.shape[1])
    
    #print(chrlen)
    #print(np.sum(chrlen))

    return chrlen

def make_matrix_chr1(include_intra_read):
    def getinit(include_intra_read):
        if include_intra_read:
            matrix = np.genfromtxt(getfilename(1, 1), delimiter="\t", filling_values=(0, 0, 0))
            matrix = np.delete(matrix, -1, 1)
        else:
            matrix = np.zeros((chrlen[0], chrlen[0]))
        return matrix
        
    matrix = getinit(include_intra_read)
        
    for i in range(2,23):
        #    print(i)
        d = np.genfromtxt(getfilename(1, i), delimiter="\t", filling_values=(0, 0, 0))
        d = np.delete(d, -1, 1)
        matrix = np.c_[matrix, d]

    return matrix

def make_matrix_eachchr(i, chrlen):
    if include_intra_read:
        data = np.zeros((chrlen[i-1], sum(chrlen[0:i-1])))

        for j in range(i,23):
            #    print(j)
            d = np.genfromtxt(getfilename(i, j), delimiter="\t", filling_values=(0, 0, 0))
            d = np.delete(d, -1, 1)
            data = np.c_[data, d]
        return data
    else:
        data = np.zeros((chrlen[i-1], sum(chrlen[0:i])))
        
        for j in range(i+1,23):
            #    print(j)
            d = np.genfromtxt(getfilename(i, j), delimiter="\t", filling_values=(0, 0, 0))
            d = np.delete(d, -1, 1)
            data = np.c_[data, d]
        return data

if __name__ == '__main__':
    arguments = parse_argv()
    dir = arguments[0]
    outputfile = arguments[1]
    res = int(arguments[2])
    ntype = arguments[3]
    include_intra_read = False
    if '--includeintra' in arguments:
        include_intra_read = True
        
    chrlen = getchrlen()
    matrix = make_matrix_chr1(include_intra_read)

    for i in range(2,23):
        data = make_matrix_eachchr(i, chrlen)
        matrix = np.r_[matrix, data]

    triu = np.triu(matrix)
    matrix = triu + triu.T - np.diag(np.diag(triu))

    np.save(outputfile, matrix)
