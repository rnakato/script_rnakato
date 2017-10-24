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

        getModelStats(models, output, exp.name)
        clusterModels(models, output, exp.name)
        
        #        models.align_models(in_place=True)
        #        models.deconvolve(fact=0.6, dcutoff=1000, represent_models='best', n_best_clusters=5)

        if not os.path.exists('TADbit/Map'):
            os.makedirs("TADbit/Map")
        models.contact_map(models=range(5,10), cutoff=1200, savedata="TADbit/Map/" + output + "." + exp.name + ".ContactMap.txt")
        getHeatMap(models, output, exp.name)

        viewModels(models, output, exp.name)
        
        if not os.path.exists('TADbit/Modelfile'):
            os.makedirs("TADbit/Modelfile")
        models.save_models("TADbit/Modelfile/" + output + "." + exp.name + ".models") # save data

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
    models = exp.model_region(ps, pe, n_models=500, n_keep=100, n_cpus=ncpu, keep_all=True, config=optpar)
    return models

def getModelStats(models, output, label):
    print "Lowest 100 IMP OF models:"
    models.define_best_models(100)
    print models

    for i in range(len(models.clusters)):
        models[i].objective_function(log=True, smooth=False, savefig="TADbit/" + output + "." + label + ".3Dmodel.IMP_OF"+ ".cl" + str(i) +".png")
  
def getHeatMap(models, output, label):
    if not os.path.exists('TADbit/Heatmap'):
        os.makedirs("TADbit/Heatmap")
    models.zscore_plot(savefig="TADbit/Heatmap/" + output + "." + label + ".zscore.png")
    for i in range(len(models.clusters)):
        num=i+1
        models.correlate_with_real_data(cluster=num, plot=True, cutoff=1500, savefig="TADbit/Heatmap/" + output + "." + label + ".cl" + str(num) + ".png")

    # Calculating average distance between particles particle 13 and 30 in all lept models
#    models.median_3d_dist(13, 20, plot=True, savefig="TADbit/" + output + "." + exp.name + ".3Dmodel.distance-13-20.png") 

def clusterModels(models, output, label):
    if not os.path.exists('TADbit/Cluster'):
        os.makedirs("TADbit/Cluster")
    models.cluster_models(fact=0.95, dcutoff=2000)
#    print models.clusters
    cl = models.cluster_analysis_dendrogram(color=True, selfavefig="TADbit/Cluster/" + output + "." + label + ".dendrogram.png") 

    models.density_plot(savefig="TADbit/Cluster/" + output + "." + label + ".DNAdensity.png")
    for i in range(len(models.clusters)):
        num=i+1
        models.model_consistency(cluster=num, cutoffs=(1000,2000),
                             savefig="TADbit/Cluster/" + output + "." + label + ".consistency.cl" + str(num) + ".png")
        models.density_plot(cluster=num, error=True, steps=(5),
                            savefig="TADbit/Cluster/" + output + "." + label + ".DNAdensitySD.cl" + str(num) + ".png")
    # Get a similar plot for only the top cluster and show the standar deviation for a specific(s) running window (steps)
    #    models.walking_angle(steps=(3, 5, 7), signed=False)
    #models.interactions(cutoff=2000)


def viewModels(models, output, label):
    if not os.path.exists('TADbit/3Dmodels'):
        os.makedirs("TADbit/3Dmodels")
    pwd=os.getcwd()
    prefix="TADbit/3Dmodels/" + output + "." + label
    models.view_models(stress='centroid', tool='plot', figsize=(10,10), azimuth=-60, elevation=100,
                       savefig=prefix + ".full.png")
    # TADなし
    models.view_models(highlight='centroid', show='highlighted', tool='plot',
                       figsize=(10,10), azimuth=-60, elevation=100,
                       savefig=prefix + ".highlighted.png")
    # TADあり
    models.view_models(highlight='centroid', show='highlighted', tool='plot', figsize=(10,10), azimuth=-60, elevation=100, color='tad',
                       savefig=prefix + ".highlighted.TAD.png")
    models.view_models(highlight='centroid', show='highlighted', tool='plot', figsize=(10,10), azimuth=-60, elevation=100, color='border',
                       savefig=prefix + ".highlighted.border.png")

    models.view_models(models=[0], tool = '/home/rnakato/.local/UCSF-Chimera64-1.11.2/bin/chimera',
                       savefig = pwd + '/' + prefix + ".chimera.png")
    models.view_models(models=[0], tool='/home/rnakato/.local/UCSF-Chimera64-1.11.2/bin/chimera',
                       savefig = pwd + '/' + prefix + ".chimera.webm")

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
