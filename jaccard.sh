#!/bin/bash

cmdname=`basename $0`
function usage()
{
    echo "$cmdname <bed> <bed> [...]" 1>&2
}


if [ $# -lt 2 ]; then
  usage
  exit 1
fi

tmpfile=$(mktemp)

n=0
for file in $@; do
    sort -k1,1 -k2,2n $file > $tmpfile.$n
    n=$((n+1))
done

n=0
for file in $@; do
    echo -en "\t$file"
done
echo ""

i=0
for file1 in $@; do
    j=0
    echo -en "$file"
    for file2 in $@; do
	echo -en "\t`bedtools jaccard -a $tmpfile.$i -b $tmpfile.$j | grep -v jaccard | cut -f3`"
	j=$((j+1))
    done
    echo ""
    i=$((i+1))
done

rm $tmpfile.*
