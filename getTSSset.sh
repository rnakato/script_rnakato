#!/bin/bash

refFlat=$1
output=$2
bams=${@:3}
nsample=`expr $# - 2`

pcgene=$(mktemp)
chrtemp=$(mktemp)

cat $refFlat | awk '{if($13=="protein_coding" && $3!="chrY" && $3!="chrM") print;}' > $pcgene

cat $pcgene | awk '{if($4=="+"){ start=$7-2000; end=$7+2000}else{ start=$8-2000; end=$8+2000}; print $3"\t"start"\t"end"\t"$1}' | sort -k1,1 -k2,2n > $chrtemp

#cut -f3,5,6 $pcgene > $chrtemp

temp=$(mktemp)
echo "bedtools multicov -bams $bams -bed $chrtemp > $temp.temp"
bedtools multicov -bams $bams -bed $chrtemp > $temp.temp
if test ! -s $temp.temp; then
    exit
fi

paste $pcgene $temp.temp > $temp

getMaxvalTSS.pl -n $nsample $temp > $output.all.csv
cut -f1,2,3,4,5,6,7,8,9,10,11,12,13 $output.all.csv > $output.refFlat

rm $pcgene $chrtemp $temp.temp $temp
