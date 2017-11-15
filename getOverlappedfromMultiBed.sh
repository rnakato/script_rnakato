#!/bin/bash

beds=$@
nbed=$#
tmpfile1=$(mktemp)
tmpfile2=$(mktemp)

cat $1 | grep -v \# | grep -v chromosome | sort -k1,1 -k2,2n > $tmpfile1
for bed in $beds
do
  cat $bed | grep -v \# | grep -v chromosome | sort -k1,1 -k2,2n | bedtools intersect -a $tmpfile1 -b - > $tmpfile2
  cp $tmpfile2 $tmpfile1
done
cat $tmpfile2
