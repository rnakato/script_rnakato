#!/bin/bash

Rdir=$(cd $(dirname $0) && pwd)
R="Rscript $Rdir/edgeR.R"

if test $# -ne 7; then
    echo "rsem_merge_edgeR.sh <files> <output> <strings for sed> <num of reps> <gtf> <build> <FDR>"
    exit 0
fi

array=$1
outname=$2
str_sed=$3
n=$4
gtf=$5
build=$6
p=$7

for str in genes isoforms; do
    s=""
    for prefix in $array
      do
      s="$s rsem/$prefix-$build.$str.results"
    done
    rsem-generate-data-matrix $s > $outname.$str.$build.txt
    
    cat $outname.$str.$build.txt | sed -e 's/-'$build'.'$str'.results//g' > temp
    mv temp $outname.$str.$build.txt
    for rem in $str_sed \" "rsem\/"
      do
      cat $outname.$str.$build.txt | sed -e 's/'$rem'//g' > temp
      mv temp $outname.$str.$build.txt
    done
done
add_genename_fromgtf.pl $outname.isoforms.$build.txt $gtf > $outname.isoforms.$build.addname.txt
mv $outname.isoforms.$build.addname.txt $outname.isoforms.$build.txt

$R -i=$outname.genes.$build.txt    -n=$n -o=$outname.genes.$build    -p=$p
$R -i=$outname.isoforms.$build.txt -n=$n -o=$outname.isoforms.$build -p=$p -nrowname=2 -color=orange
