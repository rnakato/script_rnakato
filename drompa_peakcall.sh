#!/bin/bash

if test $# -ne 7; then
    echo "drompa_peakcall.sh <IP prefix> <Input prefix> <output prefix> <binsize> <build> <k-mer> <option>"
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
opt=$7

Ddir=`database.sh`/UCSC/$build
gt=$Ddir/genome_table
map="$Ddir/mappability_Mosaics_${k}mer/map_fragL150"

IPfile=$IP.$binsize.binarray_dist.xls
Inputfile=$Input.$binsize.binarray_dist.xls
if test -e $IPfile && test -s $IPfile ; then
    if test $IP == $Input; then
	drompa_peakcall PC_SHARP -i $IP -binsize $binsize -gt $gt -p $mdir/$output -mp $map $opt
    elif test -e $Inputfile && test -s $Inputfile ; then
	drompa_peakcall PC_SHARP -i $IP,$Input -binsize $binsize -gt $gt -p $mdir/$output -mp $map $opt
    else
	echo "$Inputfile does not exist."
    fi
else
    echo "$IPfile does not exist."
fi
