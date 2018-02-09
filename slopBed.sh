#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname <bed> <extend length> <build>" 1>&2
}

# check arguments
if [ $# -ne 3 ]; then
  usage
  exit 1
fi

bed=$1
len=$2
build=$3

Ddir=`database.sh`

grep -v chromosome $bed | cut -f1,2,3 | tr -d ' ' | slopBed -i - -g $Ddir/UCSC/$build/genome_table -b $len | sort -k1,1 -k2,2n | mergeBed -i -
