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

if test $p = "density"; then
    ex "$R -i=$outname.genes.TPM.$build.txt    -n=$n -o=$outname.genes.TPM.$build    -density"
    ex "$R -i=$outname.isoforms.TPM.$build.txt -n=$n -o=$outname.isoforms.TPM.$build -density -nrowname=2"
else
    ex "$R -i=$outname.genes.count.$build.txt    -n=$n -o=$outname.genes.count.$build    -p=$p"
    ex "$R -i=$outname.isoforms.count.$build.txt -n=$n -o=$outname.isoforms.count.$build -p=$p -nrowname=2 -color=orange"
fi