#!/bin/bash
prefix=$1

dir=fastqc
if test ! -e $dir; then mkdir $dir; fi
if test ! -e $dir/${prefix}_fastqc.html ; then
    fastqc fastq/$1.fastq -o $dir
fi
