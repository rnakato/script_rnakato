#!/bin/bash

function usage()
{
    echo "overlap_morethan.sh [-g genome_table] [-t threshold] <bed> <bed> ..." 1>&2
}

while getopts g:t: option
do
    case ${option} in
        g)
            gt=${OPTARG}
            ;;
	t)
	    thre=${OPTARG}
	    ;;
	*)
	    usage
	    exit 1
	    ;;
    esac
done
shift $((OPTIND - 1))

if test $# -lt 2 -o -z "${gt+x}" -o -z "${thre+x}"; then
    usage
    exit 0
fi

BEDs=$@
cat $BEDs | sort -k1,1 -k2,2n | bedtools genomecov -i - -g $gt -bg | awk '{if($4 > '$thre') print}' 
