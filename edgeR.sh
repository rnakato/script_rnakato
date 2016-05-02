#!/bin/bash

if test $# -ne 4; then
    echo "edgeR.sh <Matrix> <build> <num of reps> <FDR>"
    exit 0
fi

outname=$1
build=$2
n=$3
p=$4

Rdir=$(cd $(dirname $0) && pwd)
R="Rscript $Rdir/edgeR.R"

ex(){
    echo $1
    eval $1
}

ex "$R -i=$outname.genes.$build.txt    -n=$n -o=$outname.genes.$build    -p=$p"
ex "$R -i=$outname.isoforms.$build.txt -n=$n -o=$outname.isoforms.$build -p=$p -nrowname=2 -color=orange"
