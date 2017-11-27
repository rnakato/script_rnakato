#!/bin/bash

cmdname=`basename $0`
function usage()
{
    echo "$cmdname [-g genome_table] [-t <int>] <bed> <bed> ..." 1>&2
}

t=0
while getopts g:t: option
do
    case ${option} in
        g)
            gt=${OPTARG}
            ;;
	t)
            t=${OPTARG}
            ;;
	*)
	    usage
	    exit 1
	    ;;
    esac
done
shift $((OPTIND - 1))

if test $# -lt 2 -o -z "${gt+x}"; then
    usage
    exit 0
fi

tmpfile=$(mktemp)

BEDs=$@
overlap_morethan.sh -g $gt -t $t $BEDs > $tmpfile
echo -en "chromosome\tstart\tend\tcount\tsample\tall\t"
echo "`ls $BEDs | tr '\n' '\t'`"

bedtools multiinter -i $tmpfile $BEDs -sorted | awk '{ if ($6 == 1.) print }' 
rm $tmpfile
