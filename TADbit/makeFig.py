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
    sample = args.i
    output = args.o

    models=load_structuralmodels(sample)
            
    #        models.align_models(in_place=True)
    #        models.deconvolve(fact=0.6, dcutoff=1000, represent_models='best', n_best_clusters=5)

#    getHeatMap(models, output)
#    clusterModels(models, output)
    viewModels(models, output)

def getHeatMap(models, output):
    if not os.path.exists('TADbit/Heatmap'):
        os.makedirs("TADbit/Heatmap")
    models.zscore_plot(savefig="TADbit/Heatmap/" + output + ".zscore.png")
    for i in range(len(models.clusters)):
        num=i+1
        models.correlate_with_real_data(cluster=num, plot=True, cutoff=1500, savefig="TADbit/Heatmap/" + output + + ".cl" + str(num) + ".png")

def clusterModels(models, output):
    if not os.path.exists('TADbit/Cluster'):
        os.makedirs("TADbit/Cluster")
    models.cluster_models(fact=0.95, dcutoff=2000)
#    print models.clusters
    models.cluster_analysis_dendrogram(color=True, selfavefig="TADbit/Cluster/" + output + ".dendrogram.png") 

    models.density_plot(savefig="TADbit/Cluster/" + output + ".DNAdensity.png")
    for i in range(len(models.clusters)):
        num=i+1
        models.model_consistency(cluster=num, cutoffs=(1000,2000),
                             savefig="TADbit/Cluster/" + output + ".consistency.cl" + str(num) + ".png")
        models.density_plot(cluster=num, error=True, steps=(5),
                            savefig="TADbit/Cluster/" + output + ".DNAdensitySD.cl" + str(num) + ".png")
    # Get a similar plot for only the top cluster and show the standar deviation for a specific(s) running window (steps)
    #    models.walking_angle(steps=(3, 5, 7), signed=False)
    #models.interactions(cutoff=2000)

def viewModels(models, output):
    if not os.path.exists('TADbit/3Dmodels'):
        os.makedirs("TADbit/3Dmodels")
    pwd=os.getcwd()
    prefix="TADbit/3Dmodels/" + output
    models.view_models(stress='centroid', tool='plot', figsize=(10,10), azimuth=-60, elevation=100,
                       savefig=prefix + ".full.png")
    # TADなし
    models.view_models(highlight='centroid', show='highlighted', tool='plot',
                       figsize=(10,10), azimuth=-60, elevation=100,
                       savefig=prefix + ".highlighted.png")
    # TADあり
#    models.view_models(highlight='centroid', show='highlighted', tool='plot', figsize=(10,10), azimuth=-60, elevation=100, color='tad',
 #                      savefig=prefix + ".highlighted.TAD.png")
  #  models.view_models(highlight='centroid', show='highlighted', tool='plot', figsize=(10,10), azimuth=-60, elevation=100, color='border',
   #                    savefig=prefix + ".highlighted.border.png")

    models.view_models(models=[0], tool = '/home/rnakato/.local/UCSF-Chimera64-1.11.2/bin/chimera',
                       savefig = pwd + '/' + prefix + ".chimera.png")
    models.view_models(models=[0], tool='/home/rnakato/.local/UCSF-Chimera64-1.11.2/bin/chimera',
                       savefig = pwd + '/' + prefix + ".chimera.webm")

def getArgs():
    parser = argparse.ArgumentParser(description = "Generate 3D model")
    parser.add_argument("-i", type=str, help = "<ModelFile>", required=True)
    parser.add_argument("-o", type=str, help = "Output name", required=True)
    args = parser.parse_args()
    return args

if __name__ == "__main__":
    exit(main())
