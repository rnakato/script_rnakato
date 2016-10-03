#!/bin/bash

function usage()
{
    echo "CRM.sh [-g genome_table] <bed> <bed> ..." 1>&2
}

while getopts g: option
do
    case ${option} in
        g)
            gt=${OPTARG}
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
overlap_morethan.sh -g $gt -t 0 $BEDs > $tmpfile
echo -en "chromosome\tstart\tend\tcount\tsample\tall\t"
`cat $BEDs | sed -e 's/\s+/\t/g'`
bedtools multiinter -i $tmpfile $BEDs -sorted | awk '{ if ($6 == 1.) print }' 
rm $tmpfile
