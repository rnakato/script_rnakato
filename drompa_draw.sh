#!/bin/bash
if test $# -ne 4; then
    echo "drompa_draw.sh <samples> <options> <output> <build>"
    exit 0
fi

mdir=pdf
if test ! -e $mdir; then mkdir $mdir; fi

s=$1
param=$2
output=$3
build=$4

Ddir=/home/Database/UCSC/$build
gene=$Ddir/refFlat.dupremoved.txt
gt=$Ddir/genome_table
GC=$Ddir/GCcontents
genedensity=$Ddir/gene_density

drompa_draw PC_SHARP $s $param -p $mdir/$output -scale_tag 20 -gt $gt
