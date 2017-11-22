#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname <reference bed> <bam> [<bam>...]" 1>&2
}

# check arguments
if [ $# -lt 2 ]; then
  usage
  exit 1
fi

bed=$1
bams=${@:2}

tmpfile=$(mktemp)

cut -f1,2,3 $bed | grep -v \# | grep -v chromosome > $tmpfile

tmpfile2=$(mktemp)
cp $tmpfile $tmpfile2

tmpfile3=$(mktemp)
for bam in $bams; do
    bedtools coverage -a $tmpfile -b $bam -c | cut -f1,4 | join -t $'\t' $tmpfile2 - > $tmpfile3
    cp $tmpfile3 $tmpfile2
done


echo -en "\t\t" 
for bam in $bams; do
    name=`basename $bam`
    echo -en "\t$name" 
done
echo "" 
cat $tmpfile2
