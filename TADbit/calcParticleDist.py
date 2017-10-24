# -*- coding: utf-8 -*-
import argparse
from pytadbit import Chromosome
from pytadbit import load_chromosome
from pytadbit.modelling.structuralmodels import load_structuralmodels

def main():
    args = getArgs()
    sample = args.i
    output = args.o
    s = args.s
    e = args.e
    
    models=load_structuralmodels(sample)
    models.median_3d_dist(s, e, plot=True, savefig = output + ".distance-" + str(s) + "-" + str(e) + ".png") 

def getArgs():
    parser = argparse.ArgumentParser(description = "Calculate distances between two particles")
    parser.add_argument("-i", type=str, help = "Modelfile", required=True)
    parser.add_argument("-s", type=int, help = "First particle", required=True)
    parser.add_argument("-e", type=int, help = "Second particle", required=True)
    parser.add_argument("-o", type=str, help = "Output name", required=True)
    args = parser.parse_args()
    return args

if __name__ == "__main__":
    exit(main())
