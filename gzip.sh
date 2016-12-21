#!/bin/bash
for fastq in `ls *.fastq`
do
    echo $fastq
    gzip $fastq
done
