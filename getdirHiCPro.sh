#!/bin/bash

scriptname=${0##*/}
if test $# -ne 4; then
    echo "$scriptname <icedir|rawdir|icematrix|rawmatrix|absbed|validpair> <HiCProdir> <expname> <resolution>"
    exit 0
fi

HiCdir=$2
expname=$3
resolution=$4

icedir=$HiCdir/hic_results/matrix/$expname/iced/$resolution
rawdir=$HiCdir/hic_results/matrix/$expname/raw/$resolution
icematrix=$icedir/${expname}_${resolution}_iced.matrix
rawmatrix=$rawdir/${expname}_${resolution}.matrix
absbed=$rawdir/${expname}_${resolution}_abs.bed
validpair=$HiCdir/hic_results/data/$expname/${expname}_allValidPairs

if test $1 = "icedir"; then
    echo $icedir
elif test $1 = "rawdir"; then
    echo $rawdir
elif test $1 = "icematrix"; then
    echo $icematrix
elif test $1 = "rawmatrix"; then
    echo $rawmatrix
elif test $1 = "absbed"; then
    echo $absbed
elif test $1 = "validpair"; then
    echo $validpair
else
    echo "Error: specify <icedir|rawdir|icematrix|rawmatrix|absbed|validpair>"
fi
