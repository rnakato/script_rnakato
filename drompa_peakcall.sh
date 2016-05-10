#!/bin/bash

if test $# -ne 5; then
    echo "drompa_peakcall.sh <IP prefix> <Input prefix> <binsize> <build> <k-mer>"
    exit 0
fi

mdir=drompa
if test ! -e $mdir; then mkdir $mdir; fi

pdir=parse2wigdir
IP=$pdir/$1
Input=$pdir/$2
binsize=$3
build=$4
k=$5

Ddir=/home/Database/UCSC/$build
gt=$Ddir/genome_table
map="$Ddir/mappability_Mosaics_${k}mer/map_fragL150"

if test -e $IP.binarray_dist.xls && test -s $IP.binarray_dist.xls ; then
    if test -e $Input.binarray_dist.xls && test -s $Input.binarray_dist.xls ; then
	drompa_peakcall PC_SHARP -i $IP,$Input -binsize $binsize -gt $gt -p $mdir/$1 -mp $map
    else
	echo "$Input.binarray_dist.xls does not exist."
    fi
else
    echo "$IP.binarray_dist.xls does not exist."
fi
