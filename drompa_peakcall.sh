#!/bin/bash

if test $# -ne 6; then
    echo "drompa_peakcall.sh <IP prefix> <Input prefix> <output prefix> <binsize> <build> <k-mer>"
    exit 0
fi

mdir=drompa
if test ! -e $mdir; then mkdir $mdir; fi

pdir=parse2wigdir
IP=$pdir/$1
Input=$pdir/$2
output=$3
binsize=$4
build=$5
k=$6

Ddir=`database.sh`/UCSC/$build
gt=$Ddir/genome_table
map="$Ddir/mappability_Mosaics_${k}mer/map_fragL150"

if test -e $IP.binarray_dist.xls && test -s $IP.binarray_dist.xls ; then
    if test -e $Input.binarray_dist.xls && test -s $Input.binarray_dist.xls ; then
	drompa_peakcall PC_SHARP -i $IP,$Input -binsize $binsize -gt $gt -p $mdir/$output -mp $map
    else
	echo "$Input.binarray_dist.xls does not exist."
    fi
else
    echo "$IP.binarray_dist.xls does not exist."
fi
