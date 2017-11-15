#!/bin/bash

beds=$@
nbed=$#
tmpfile1=$(mktemp)
tmpfile2=$(mktemp)

cp $1 $tmpfile1
for bed in $beds
do
    bedtools intersect -a $tmpfile1 -b $bed > $tmpfile2
    cp $tmpfile2 $tmpfile1
done
cat $tmpfile2
