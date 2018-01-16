#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "Usage: $cmdname <tsv> <tsv> ..." 1>&2
}

# check arguments
if [ $# -eq 0 ]; then
  usage
  exit 1
fi

tmpfile1=$(mktemp)
tmpfile2=$(mktemp)

cut -f1,2,3 $1 

for file in ${@:1}
do
    cut -f5 $file
done
