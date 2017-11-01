#!/bin/bash

scriptname=${0##*/}
if test $# -ne 3; then
    echo "$scriptname <HiCProdir> <expname> <resolution>"
    exit 0
fi

HiCdir=$1
expname=$2
resolution=$3

icedir=$HiCdir/hic_results/matrix/$expname/iced/$resolution
rawdir=$HiCdir/hic_results/matrix/$expname/raw/$resolution
matrix=$icedir/${expname}_${resolution}_iced.matrix
absbed=$rawdir/${expname}_${resolution}_abs.bed

echo $matrix
echo $absbed
