# -*- coding: utf-8 -*-
import os
import argparse
from pytadbit import Chromosome

def main():
    args = getArgs()
    samples = args.i
    output = args.o
    chr = args.c
    ncpu = args.p
    resolution=args.r
    species=args.s
    gbuild=args.b

    # initiate a chromosome object that will store all Hi-C data and analysis
    my_chrom = Chromosome(
        name=chr,   # 染色体名
        centromere_search=True, # centromereを検出するか
        species=species,
        assembly=gbuild # genome build
    )
    for sample in samples:
        label, path = sample.split(",")
        print(label)
        print(path)
        getHiCData(my_chrom, output, label, path, resolution, ncpu)
        
    if not os.path.exists('tdb'):
        os.makedirs("tdb")

    my_chrom.save_chromosome(output + ".tdb", force=True)
    
def getArgs():
    parser = argparse.ArgumentParser(description = "Generate and store TADbit chromosome object")
    parser.add_argument("-i", type=str, help = "<label>,<PathToHiCData>", nargs='+')
    parser.add_argument("-o", type=str, help = "Output name", required=True)
    parser.add_argument("-c", type=str, help = "Chromosome", required=True)
    parser.add_argument("-r", type=int, help = "resolution (default: 100000)", required=False, default=100000)
    parser.add_argument("-s", type=str, help = "Species (default: Homo sapiens)", required=False, default="Homo sapiens")
    parser.add_argument("-b", type=str, help = "Genome build (default: GRCh38)", required=False, default="GRCh38")
    parser.add_argument("-p", type=int, help = "num of cpus (default: 1)", required=False, default=1)
    args = parser.parse_args()
    return args

def getHiCData(Chr, output, label, HiCpath, resolution, ncpu):
    Chr.add_experiment(
        label,
        cell_type='wild type',
        exp_type='Hi-C',
        identifier=label,
        project='TADbit',
        hic_data=HiCpath,
        resolution=resolution
    )
    Chr.find_tad(label, n_cpus=ncpu)
    exp = Chr.experiments[label]
    exp.filter_columns(draw_hist=True, savefig=output + "." + label + ".histgram.png")
    exp.normalize_hic(iterations=30, max_dev=0.1)
#    exp.tads
    #exp.view()
    Chr.visualize(exp.name, paint_tads=True, savefig=output + "." + label + ".Map.png", show=False)
    Chr.tad_density_plot(label, savefig=output + "." + label + ".TAD.png")

if __name__ == "__main__":
    exit(main())

