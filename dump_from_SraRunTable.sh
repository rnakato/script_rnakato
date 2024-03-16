#!/bin/bash

function usage()
{
    echo "dump_from_SraRunTable.sh <SraRunTable.txt>" 1>&2
}

inputfile=$1

func(){
    id=$1
    echo $id
    if test ! -e ${id}_1.fastq && test ! -e ${id}.fastq; then
       singularity exec --bind /work2 /work3/SingularityImages/SRAtools.3.0.0.sif fastq-dump --split-files $id
    fi
}
export -f func

ncore=10
array=`cut -f1 -d , $inputfile | grep -v Run | tr '\n' ' '`
echo ${array[@]} | tr ' ' '\n' | xargs -I {} -P $ncore bash -c "func {}"
