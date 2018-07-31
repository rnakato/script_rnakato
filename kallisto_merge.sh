#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "Usage: $cmdname <output> <gtf> [tsv ...]" 1>&2
}

# check arguments
if [ $# -lt 3 ]; then
  usage
  exit 1
fi

output=$1
gtf=$2
files=${@:3}

pwd=`pwd.sh`
$pwd/mergekallistotsv.sh $files > $output.transcript.csv
$pwd/convert_genename_fromgtf.pl transcript all $output.transcript.csv $gtf 0 > $output.transcript.name.csv

Rscript $pwd/kallisto_tximport.R $output.gene $gtf $files

tmpfile=$(mktemp)
for file in $files
do
  echo -en "\t`echo  $file | sed -e 's/kallisto\///g' -e 's/\/abundance.tsv//g'`" >> $tmpfile
done
echo "" >> $tmpfile
cat $output.gene.csv >> $tmpfile
mv $tmpfile $output.gene.csv

$pwd/convert_genename_fromgtf.pl genes all $output.gene.csv $gtf 0 > $output.gene.name.all.csv
$pwd/convert_genename_fromgtf.pl genes pc $output.gene.csv $gtf 0 > $output.gene.name.pc.csv
$pwd/csv2xlsx.pl -i $output.gene.name.all.csv -n gene-TPM.all -i $output.gene.name.pc.csv -n gene-TPM.proteincoding -i $output.transcript.name.csv -n isoform-TPM -o $output.xlsx

rm *~ #$output.transcript.csv $output.gene.csv
