#!/bin/bash

if test $# -ne 6; then
    echo "rsem-star.sh <single|paired> <output prefix> <fastq> <Ensembl|UCSC> <build> <--forward-prob [0-1]>"
    exit 0
fi

readtype=$1
prefix=$2
fastq=$3
db=$4
build=$5
prob=$6

if test ! -e log; then mkdir log; fi
if test ! -e rsem; then mkdir rsem; fi

index=/home/Database/rsem-star-indexes/$db-$build/$db-$build

if test $readtype = "paired"; then pair="--paired-end"; fi

if [ "`echo $fastq | grep '.gz'`" ] ; then
    pzip="--star-gzipped-read-file"
fi

rsem-calculate-expression --star $pzip $pair -p 12 --forward-prob $prob --calc-ci --star-output-genome-bam $fastq $index rsem/$prefix-$build  # --estimate-rspd

log=log/rsem-$prefix-$build
echo -en "$prefix\t" > $log
parse_rsem_cnt.pl rsem/$prefix-$build.stat/$prefix-$build.cnt | grep -v Sequenced >> $log
