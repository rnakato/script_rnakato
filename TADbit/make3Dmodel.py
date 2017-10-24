# -*- coding: utf-8 -*-
import os
import argparse
from pytadbit import Chromosome
from pytadbit import load_chromosome
from pytadbit.modelling.structuralmodels import load_structuralmodels
#from pytadbit.imp.impoptimizer import IMPoptimizer

if not os.path.exists('TADbit'):
    os.makedirs("TADbit")

pwd=os.getcwd()

def main():
    args = getArgs()
    samples = args.i
    tdbfile = args.t
    output = args.o
    ncpu = args.p
    ps = args.start # start particle
    pe = args.end   # end particle

    my_chrom = loadData(tdbfile, samples)

    for exp in my_chrom.experiments:
        models = getModels(exp, ps, pe, ncpu)
        #    print models
        #   models.experiment

        print "Lowest 100 IMP OF models:"
        models.define_best_models(100)
        print models
        if not os.path.exists('TADbit/IMP_OF'):
            os.makedirs("TADbit/IMP_OF")
        for i in range(len(models.clusters)):
            models[i].objective_function(log=True, smooth=False, savefig="TADbit/IMP_OF/" + output + "." + exp.name + ".cl" + str(i) +".png")
      
        if not os.path.exists('TADbit/ContactMap'):
            os.makedirs("TADbit/ContactMap")
        models.contact_map(models=range(5,10), cutoff=1200, savedata="TADbit/ContactMap/" + output + "." + exp.name + ".ContactMap.txt")
        
        if not os.path.exists('TADbit/Modelfile'):
            os.makedirs("TADbit/Modelfile")
        models.save_models("TADbit/Modelfile/" + output + "." + exp.name + "." + str(ps) + "-" + str(pe) + ".models") # save data

def getModels(exp, ps, pe, ncpu):
    # Pre-defined parameters for modeling
#    from pytadbit.modelling.IMP_CONFIG import CONFIG
 #   CONFIG # See pre-defined sets of parameters
    # Set of optimal parameters from pervious tutorial #2
    optpar = {'kforce': 5,
              'lowfreq': 0.0,
              'lowrdist': 100,
              'upfreq': 0.8,
              'maxdist': 2750,
              'scale': 0.01,
              'reference': 'gm cell from Job Dekker 2009'}

    # Build 3D models by IMP based on the HiC data.
    if pe == -1:
        models = exp.model_region(ps, None, n_models=500, n_keep=100, n_cpus=ncpu, keep_all=True, config=optpar)
    else:
        models = exp.model_region(ps, pe, n_models=500, n_keep=100, n_cpus=ncpu, keep_all=True, config=optpar)
    return models

def loadData(tdbfile, samples):
    my_chrom = load_chromosome(tdbfile)
    for i,exp in enumerate(my_chrom.experiments):
        try:
            label, path = samples[i].split(",")
            print(path)
            print(exp.name)
            exp.load_hic_data(path)
            exp.normalize_hic(factor=1)
            exp.filter_columns()
        except IOError:
            print 'file not found for experiment: ' + exp.name
            continue
    return my_chrom

def getArgs():
    parser = argparse.ArgumentParser(description = "Generate 3D model")
    parser.add_argument("-i", type=str, help = "<label>,<PathToHiCData>", nargs='+')
    parser.add_argument("-t", type=str, help = ".tdb file", required=True)
    parser.add_argument("--start", type=int, help = "start particle to model", required=True)
    parser.add_argument("--end",   type=int, help = "end particle to model", required=True)
    parser.add_argument("-o", type=str, help = "Output name", required=True)
    parser.add_argument("-p", type=int, help = "num of cpus (default: 1)", required=False, default=1)
    args = parser.parse_args()
    return args

if __name__ == "__main__":
    exit(main())
