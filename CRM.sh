#!/bin/bash

function usage()
{
    echo "CRM.sh [-g genome_table] [-t threshold] <bed> <bed> ..." 1>&2
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

if test $# -lt 2 -o -z "${gt+x}"; then
    usage
    exit 0
fi

BEDs=$@
overlap_morethan.sh -g $gt -t 0 $BEDs > CRM.temp
bedtools multiinter -i CRM.temp $BEDs -sorted | awk '{ if ($6 == 1.) print }' 
rm CRM.temp
