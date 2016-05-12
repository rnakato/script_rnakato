#!/bin/bash

if test $# -ne 4; then
    echo "bowtie.sh <fastq> <prefix> <build> <type>"
    exit 0
fi

fastq=$1
prefix=$2
build=$3
type=$4

bamdir=bam
if test ! -e $bamdir; then mkdir $bamdir; fi
if test ! -e log; then mkdir log; fi

Ddir=/home/Database/UCSC/$build


ex_hiseq(){
    index=/home/Database/bowtie-indexes/UCSC-$build
    command="bowtie -S $index $fastq -n2 -m1 --chunkmbs 2048 -p12 | samtools view -bS - | samtools sort - $bamdir/$prefix-n2-m1-$build.sort"    
    echo $command
    eval $command
}

ex_csfasta(){
    index=/home/Database/bowtie-indexes/UCSC-$build-cs
    command="bowtie -S -C $index -f $fastq.csfasta -Q $fastq.qual -n2 -m1 --chunkmbs 2048 -p12 | samtools view -bS - | samtools sort - $bamdir/$prefix-n2-m1-$build.sort"
    echo $command
    eval $command
}

ex_csfastq(){
    index=/home/Database/bowtie-indexes/UCSC-$build-cs
    command="bowtie -S -C $index $fastq -n2 -m1 --chunkmbs 2048 -p12 | samtools view -bS - | samtools sort - $bamdir/$prefix-n2-m1-$build.sort"
    echo $command
    eval $command
}

if test $type = "stats"; then parsebowtielog.pl log/bowtie-$prefix-$build | grep -v mapped | sed -e 's/'$bamdir'\///g' -e 's/-n2-m1-'$build'.sort//g';
elif test $type = "csfasta"; then  ex_csfasta >& log/bowtie-$prefix-$build; 
elif test $type = "csfastq"; then  ex_csfastq >& log/bowtie-$prefix-$build;
else ex_hiseq >& log/bowtie-$prefix-$build
fi
#echo "bamfile: $bamdir/$prefix-n2-m1-$build.sort.bam"

