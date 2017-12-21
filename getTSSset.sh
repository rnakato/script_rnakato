#!/bin/bash

refFlat=$1
output=$2
bams=${@:3}
nsample=`expr $# - 2`

pcgene=$(mktemp)
chrtemp=$(mktemp)
cat $refFlat | awk '{if($13=="protein_coding") print;}' > $pcgene
cut -f3,5,6 $pcgene | addchr.pl - > $chrtemp

temp=$(mktemp)
bedtools multicov -bams $bams -bed $chrtemp | paste $pcgene - > $temp
getMaxvalTSS.pl -n $nsample $temp > $output.all.csv
cut -f1,2,3,4,5,6,7,8,9,10,11,12,13 $output.all.csv > $output.refFlat

rm $pcgene $chrtemp $temp
