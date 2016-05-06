#!/bin/bash
prefix=$1
build=$2

if test $# -ne 2; then
    echo "bowtie.sh <prefix> <build>"
    exit 0
fi

dir=fastq
bamdir=bam
if test ! -e $bamdir; then mkdir $bamdir; fi
if test ! -e log; then mkdir log; fi

Ddir=/home/Database/UCSC/$build
index=/home/Database/bowtie-indexes/UCSC-$build

ex(){
    echo $command
    eval $command
}
command="bowtie -S $index $dir/$prefix.fastq -n2 -m1 --chunkmbs 2048 -p12 | samtools view -bS - | samtools sort - $bamdir/$prefix-n2-m1-$build.sort"
ex $command >& log/bowtie-$prefix-$build
