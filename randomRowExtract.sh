#!/bin/bash

cmdname=`basename $0`
function usage()
{
    echo "$cmdname <bed> <row number>" 1>&2
}

if test $# -lt 2; then
    usage
    exit 0
fi

bed=$1
nrow=$2
tmpfile=$(mktemp)
head -n1 $bed
tail -n +2 $bed > $tmpfile
perl -MList::Util=shuffle -e 'print shuffle(<>)' < $tmpfile | tail -n $nrow
