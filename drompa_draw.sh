#!/bin/bash
if test $# -ne 5; then
    echo "drompa_draw.sh <type> <samples> <options> <output> <build>"
    exit 0
fi

mdir=pdf
if test ! -e $mdir; then mkdir $mdir; fi

type=$1
s=$2
param=$3
output=$4
build=$5

Ddir=`database.sh`/UCSC/$build
gene=$Ddir/refFlat.dupremoved.txt
gt=$Ddir/genome_table
GC=$Ddir/GCcontents
genedensity=$Ddir/genedensity

if test $type = "GV"; then
    drompa_draw GV -gt $gt $s $param -p $mdir/drompa3.GV.$output -GC $GC -gcsize 500000 -GD $genedensity -gdsize 500000 
else
    drompa_draw PC_SHARP -gene $gene $s $param -p $mdir/drompa3.PC.$output -gt $gt
fi

