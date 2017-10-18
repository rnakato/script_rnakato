# -*- coding: utf-8 -*-
import os
import argparse
from pytadbit import Chromosome
from pytadbit import load_chromosome
from pytadbit.modelling.structuralmodels import load_structuralmodels
#from pytadbit.imp.impoptimizer import IMPoptimizer

if not os.path.exists('TADbit'):
    os.makedirs("TADbit")

pwd=os.path.dirname(os.path.abspath(__file__))

def main():
    args = getArgs()
    samples = args.i
    tdbfile = args.t
    output = args.o
    ncpu = args.p

    my_chrom = loadData(tdbfile, samples)

    for exp in my_chrom.experiments:
        models = getModels(exp, ncpu)
        #    print models
        #   models.experiment

        getModelStats(models, output, exp.name)
#        clusterModels(models, output, exp.name)
        
        models.align_models(in_place=True)
#        models.deconvolve(fact=0.6, dcutoff=1000, represent_models='best', n_best_clusters=5)

        getModelContactMap(models, output, exp.name)

        # Calculating average distance between particles particle 13 and 30 in all lept models
        models.median_3d_dist(13, 20, plot=True,
                              savefig="TADbit/" + output + "." + exp.name + ".3Dmodel.distance-13-20.png") 

        visualizeModels(models, output, exp.name)
        
        models.save_models("TADbit/" + output + "." + exp.name + ".models") # save data
        

def visualizeModels(models, output, label):
    models.view_models(stress='centroid', tool='plot', figsize=(10,10), azimuth=-60, elevation=100,
                       savefig="TADbit/" + output + "." + label + ".3Dmodel.type1.png")
    # TADなし
    models.view_models(highlight='centroid', show='highlighted', tool='plot',
                       figsize=(10,10), azimuth=-60, elevation=100,
                       savefig="TADbit/" + output + "." + label + ".3Dmodel.type2.png")
    # TADあり
    #    models.view_models(highlight='centroid', show='highlighted', tool='plot', figsize=(10,10), azimuth=-60, elevation=100, color='tad')
    #    models.view_models(highlight='centroid', show='highlighted', tool='plot', figsize=(10,10), azimuth=-60, elevation=100, color='border')

    # Generate the image using Chimera in batch mode. That takes some time, wait a bit before running next command.
    # You can check in your home directory whether this has finished.
    #models.view_models(models=[0], tool='chimera_nogui', savefig='/tmp/image_model_1.png')

    models.view_models(models=[0], tool = '/home/rnakato/.local/UCSF-Chimera64-1.11.2/bin/chimera',
                       savefig = pwd + '/TADbit/' + output + "." + label + ".3Dmodel.model0.chimera.png")
    models.view_models(models=[0], tool='/home/rnakato/.local/UCSF-Chimera64-1.11.2/bin/chimera',
                       savefig = pwd + "/TADbit/" + output + "." + label + ".3Dmodel.model0.chimera.webm")

        
def getModelContactMap(models, output, label):
    models.contact_map(models=range(5,10), cutoff=1200, savedata="contact.txt")
    # Correlate the contact map with the original input HiC matrix for cluster 1, 2 and 3
    models.correlate_with_real_data(cluster=1, plot=True, cutoff=1500, savefig="TADbit/" + output + "." + label + ".3Dmodel.Map.cl1.png")
    if len(models.clusters) >= 2:
        models.correlate_with_real_data(cluster=2, plot=True, cutoff=1500, savefig="TADbit/" + output + "." + label + ".3Dmodel.Map.cl2.png")
    if len(models.clusters) >= 3:
        models.correlate_with_real_data(cluster=3, plot=True, cutoff=1500, savefig="TADbit/" + output + "." + label + ".3Dmodel.Map.cl3.png")
        
def loadData(tdbfile, samples):
    my_chrom = load_chromosome(tdbfile)
    for i,exp in enumerate(my_chrom.experiments):
        try:
            label, path = samples[i].split(",")
            print(i)
            print(path)
            print(exp.name)
            exp.load_hic_data(path)
            exp.normalize_hic(factor=1)
            exp.filter_columns()
        except IOError:
            print 'file not found for experiment: ' + exp.name
            continue
    return my_chrom

def getModels(exp, ncpu):
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
    models = exp.model_region(100, 200, n_models=500, n_keep=100, n_cpus=ncpu, keep_all=True, config=optpar)
    return models

def getModelStats(models, output, label):
    # Select top 10 models
    #  models.define_best_models(10)
    #  print "Lowest 10 IMP OF models:"
    #  print models

    #   print model[0]  # Get the data for the lowest IMP OF model (number 0) in the set of models
    models[0].objective_function(log=True, smooth=False, savefig="TADbit/" + output + "." + label + ".3Dmodel.IMP_OF.png")
    models.define_best_models(100)
    # Calculate the correlation coefficient between a set of kept models and the original HiC matrix
    models.correlate_with_real_data(plot=True, cutoff=1000, savefig="TADbit/" + output + "." + label + ".3Dmodel.ccHeatmap.png")
    models.zscore_plot(savefig="TADbit/" + output + ".3Dmodel.zscore.png")

def clusterModels(models, output, label):
    models.cluster_models(fact=0.95, dcutoff=2000)
    print models.clusters
    cl = models.cluster_analysis_dendrogram(
        color=True,
        # n_best_clusters=5,
        savefig="TADbit/" + output + "." + label + ".clusterModels.dendrogram.png"
    ) 
    models.model_consistency(
        cluster=1, cutoffs=(1000,2000),
        savefig="TADbit/" + output + "." + label + ".clusterModels.cl1consistency.png"
    )
    models.density_plot(savefig="TADbit/" + output + "." + label + ".clusterModels.DNAdensity.png")
    models.density_plot(cluster=1,error=True, steps=(5),
                        savefig="TADbit/" + output + "." + label + ".clusterModels.DNAdensitySD.png")# Get a similar plot for only the top cluster and show the standar deviation for a specific(s) running window (steps)
    #    models.walking_angle(steps=(3, 5, 7), signed=False)
    #models.interactions(cutoff=2000)

def getArgs():
    parser = argparse.ArgumentParser(description = "Generate 3D model")
    parser.add_argument("-i", type=str, help = "<label>,<PathToHiCData>", nargs='+')
    parser.add_argument("-t", type=str, help = ".tdb file", required=True)
    parser.add_argument("-o", type=str, help = "Output name", required=True)
    parser.add_argument("-p", type=int, help = "num of cpus (default: 1)", required=False, default=1)
    args = parser.parse_args()
    return args

if __name__ == "__main__":
    exit(main())
