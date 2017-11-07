# -*- coding: utf-8 -*-
import os
import argparse
from pytadbit import Chromosome
from pytadbit import load_chromosome

def main():
    args = getArgs()
    samples = args.i
    tdbfile = args.t
    output = args.o
    ncpu = args.p
    
    #Ct="Control,RPE_Ct/chr19_R_Ct_100000_iced_dense.matrix"
    #CTCF="CTCFKD,RPE_CTCFKD/chr19_R_si628_100000_iced_dense.matrix"
    #Rad21="Rad21KD,RPE_Rad21KD/chr19_R_si621_100000_iced_dense.matrix"
    #NIPBL="NIPBLKD,RPE_NIPBLKD/chr19_R_si7_100000_iced_dense.matrix"

    #    tdbfile="RPE.tdb"
    #samples=[Ct,CTCF,Rad21,NIPBL]
    my_chrom, labels = loadData(tdbfile, samples)
    #ncpu=24

    ### 全サンプルを合わせてTAD抽出
    my_chrom.find_tad(labels, batch_mode=True, n_cpus=ncpu)
    print my_chrom.experiments

    # Aligning TAD boundaries
    my_chrom.align_experiments(names=labels)
    # Check alignment consistency through randomization
    ali = my_chrom.alignment[labels]
    print ali
    ali.draw(savefig=output + "." + '-'.join(labels) + ".TADs.png")
    #ali.draw(focus=(1, 250))
    score, pval = my_chrom.align_experiments(names=labels, randomize=True, rnd_method="interpolate", rnd_num=100)
    print 'score:', score
    print 'p-value:', pval

def getArgs():
    parser = argparse.ArgumentParser(description = "Generate 3D model")
    parser.add_argument("-i", type=str, help = "<label>,<PathToHiCData>", nargs='+')
    parser.add_argument("-t", type=str, help = ".tdb file", required=True)
    parser.add_argument("-o", type=str, help = "Output name", required=True)
    parser.add_argument("-p", type=int, help = "num of cpus (default: 1)", required=False, default=1)
    args = parser.parse_args()
    return args

def loadData(tdbfile, samples):
    my_chrom = load_chromosome(tdbfile)
    labels = []
    for i,exp in enumerate(my_chrom.experiments):
        try:
            label, path = samples[i].split(",")
            print(i)
            print(path)
            print(exp.name)
            exp.load_hic_data(path)
            exp.normalize_hic(factor=1)
            exp.filter_columns()
            labels.append(label)
        except IOError:
            print 'file not found for experiment: ' + exp.name
            continue
    return my_chrom, labels

# Compare two TADs in one sample
def compareTwoTADs():
    from pytadbit.tad_clustering.tad_cmo import optimal_cmo
    tad1 = list(my_chrom.iter_tads('Control'))[31]
    tad2 = list(my_chrom.iter_tads('Control'))[35]
    align1, align2, score = optimal_cmo(tad1[1], tad2[1],
                                        max_num_v=8, long_nw=True, long_dist=True,
                                        method='frobenius')
    # clustering.py

if __name__ == "__main__":
    exit(main())
