#!/bin/bash

beds=$@
nbed=$#
tmpfile1=$(mktemp)

s=""
n=0
for bed in $beds
do
  cat $bed | grep -v \# | grep -v chromosome | sort -k1,1 -k2,2n > $tmpfile1.$n
  s="$s $tmpfile1.$n"
  n=$((n+1))
done

bedtools multiinter -i $s |  awk -v var=$nbed 'BEGIN{OFS = "\t"}{ if ($4==var) print}' | cut -f1,2,3

rm $tmpfile1*