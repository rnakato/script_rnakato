#!/bin/bash

if test $# -ne 6; then
    echo "rsem_merge.sh <files> <output> <gtf> <build> <strings for sed> <type>"
    exit 0
fi

array=$1
outname=$2
gtf=$3
build=$4
str_sed=$5
type=$6


if test $type = "TPM"; then rsem="rsem-generate-data-matrix-TPM";
elif test $type = "FPKM"; then rsem="rsem-generate-data-matrix-FPKM";
else rsem="rsem-generate-data-matrix"

for str in genes isoforms; do
    s=""
    for prefix in $array; do s="$s rsem/$prefix-$build.$str.results"; done
    $rsem $s > $outname.$str.$build.txt
    
    cat $outname.$str.$build.txt | sed -e 's/-'$build'.'$str'.results//g' > $outname.temp
    mv $outname.temp $outname.$str.$build.txt
    for rem in $str_sed \" "rsem\/"
      do
      cat $outname.$str.$build.txt | sed -e 's/'$rem'//g' > $outname.temp
      mv $outname.temp $outname.$str.$build.txt
    done
done
add_genename_fromgtf.pl $outname.isoforms.$build.txt $gtf > $outname.isoforms.$build.addname.txt
mv $outname.isoforms.$build.addname.txt $outname.isoforms.$build.txt
