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

cut -f1,2,3 $1 > $tmpfile1

for file in ${@:1}
do
    cut -f5 $file | paste $tmpfile1 - > $tmpfile2
    mv $tmpfile2 $tmpfile1
done

echo -en "target_id\tlength\teff_length"
for file in ${@:1}
do
  echo -en "\t`echo  $file | sed -e 's/kallisto\///g' -e 's/\/abundance.tsv//g'`"
done

echo ""
tail -n +2 $tmpfile1 | sed -e 's/\.[0-9]\t/\t/g'
