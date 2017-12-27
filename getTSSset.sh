#!/bin/bash

refFlat=$1
output=$2
bams=${@:3}
nsample=`expr $# - 2`

pcgene=$(mktemp)
chrtemp=$(mktemp)

cat $refFlat | awk '{if($13=="protein_coding" && $3!="chrY" && $3!="chrM") print;}' > $pcgene

cat $pcgene | awk -v up=2000 -v down=2000 '{if($4=="+"){ start=$7-up; end=$7+down}else{ start=$8-down; end=$8+up}; print $3"\t"start"\t"end"\t"$1}' > $chrtemp

temp=$(mktemp)
echo "bedtools multicov -bams $bams -bed $chrtemp > $temp.temp"
bedtools multicov -bams $bams -bed $chrtemp > $temp.temp
if test ! -s $temp.temp; then
    exit
fi

paste $pcgene $temp.temp > $temp

getMaxvalTSS.pl -n $nsample $temp > $output.all.csv
cut -f1,2,3,4,5,6,7,8,9,10,11,12,13 $output.all.csv > $output.refFlat
cat $output.refFlat | awk -v up=2000 -v down=2000 '{if($4=="+"){ start=$7-up; end=$7+down}else{ start=$8-down; end=$8+up}; print $3"\t"start"\t"end"\t"$1}' > $output.bed
combine_lines_from2files.pl $output.refFlat $output.bed 0 3 | cut -f1,2,3,4,5,6,7,8,9,10,11,12,13 > $output.sorted.refFlat 


rm $pcgene $chrtemp $temp.temp $temp
