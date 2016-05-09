#!/bin/bash

if test $# -ne 4; then
    echo "parse2wig.sh <prefix> <build> <kmer> <binsize>"
    exit 0
fi

prefix=$1
build=$2
k=$3
binsize=$4

if test ! -e log; then mkdir log; fi

Ddir=/home/Database/UCSC/$build
gt=$Ddir/genome_table
chrpath=$Ddir/chromosomes
mpbl=$Ddir/mappability_Mosaics_${k}mer/map_fragL150
mpbin=$Ddir/mappability_Mosaics_${k}mer/map

bam=bam/$prefix.sort.bam
pdir=parse2wigdir

func(){
    if test ! -e $pdir/$prefix-raw-mpbl.$binsize.xls;          then parse2wig -gt $gt -f BAM -i $bam -mp $mpbl -o $prefix-raw-mpbl          -binsize $binsize; fi
    for b in $binsize 100000; do
	if test ! -e $pdir/$prefix-raw-mpbl-GR.$binsize.xls;       then parse2wig -gt $gt -f BAM -i $bam -mp $mpbl -o $prefix-raw-mpbl-GR         -n GR -binsize $b; fi
    done
    if test ! -e $pdir/$prefix-GC-depthoff-mpbl-GR.100000.xls; then parse2wig -gt $gt -f BAM -i $bam -mp $mpbl -o $prefix-GC-depthoff-mpbl-GR -n GR -GC $chrpath -mpbin $mpbin -binsize 100000 -gcdepthoff; fi
}

func >& log/parse2wig-$prefix
parsestats4DROMPA3.pl $pdir/$prefix-GC-depthoff-mpbl-GR.100000.xls > log/parsestats-$prefix

