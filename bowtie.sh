#!/bin/bash

if test $# -ne 3; then
    echo "bowtie.sh <prefix> <build> <type>"
    exit 0
fi

prefix=$1
build=$2
type=$3

bamdir=bam
if test ! -e $bamdir; then mkdir $bamdir; fi
if test ! -e log; then mkdir log; fi

Ddir=/home/Database/UCSC/$build

ex_hiseq(){
    index=/home/Database/bowtie-indexes/UCSC-$build
    command="bowtie -S $index fastq/$prefix.fastq -n2 -m1 --chunkmbs 2048 -p12 | samtools view -bS - | samtools sort - $bamdir/$prefix-n2-m1-$build.sort"    
    echo $command
    eval $command
}

ex_solid(){
    index=/home/Database/bowtie-indexes/UCSC-$build-cs
    command="bowtie -S -C $index -f csfasta/$prefix.csfasta -Q csfasta/$prefix.qual -n2 -m1 --chunkmbs 2048 -p12 | samtools view -bS - | samtools sort - $bamdir/$prefix-n2-m1-$build.sort"
    echo $command
    eval $command
}

if test $type = "solid"; then  ex_solid >& log/bowtie-$prefix-$build; 
else ex_hiseq >& log/bowtie-$prefix-$build
fi
echo "bamfile: $bamdir/$prefix-n2-m1-$build.sort.bam"

