#!/bin/bash

cmdname=`basename $0`
function usage()
{
    echo "$cmdname [-b bed] <bam> ..." 1>&2
}

while getopts b: option
do
    case ${option} in
        b)
            bed=${OPTARG}
            ;;
	*)
	    usage
	    exit 1
	    ;;
    esac
done
shift $((OPTIND - 1))

if test $# -lt 1; then
    usage
    exit 0
fi

tmpfile=$(mktemp)

BAMs=$@
cut -f1,2,3 $bed | bedtools multicov -bams $BAMs -bed - > $tmpfile
addranking4multiBamCov.pl $tmpfile
rm $tmpfile
