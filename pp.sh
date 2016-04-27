#!/bin/bash

mdir=ppout
R=/work/programs/phantompeakqualtools/run_spp.R

if test ! -e $mdir; then mkdir $mdir; fi

IPbam=$1
prefix=$2
if test -e $IPbam && test -s $IPbam ; then
    if test ! -e $mdir/$prefix.resultfile ; then Rscript $R -c=$IPbam -i=$IPbam -p=12 -rf -savn=$mdir/$prefix.narrowPeak -savr=$mdir/$prefix.regionPeak -out=$mdir/$prefix.resultfile -savp=$mdir/$prefix.pdf; fi
    echo -en "$prefix\t" > $mdir/$prefix.SN
    cut -f9,10,11 $mdir/$prefix.resultfile >> $mdir/$prefix.SN
else
    echo "$IPbam does not exist."
fi
