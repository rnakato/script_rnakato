#!/bin/bash
function usage()
{
    echo "macs.sh [-s fraglen/2] <IP bam> <Input bam> <output> [sharp|broad|nomodel|broad-nomodel]" 1>&2
}

flen=100
while getopts s: option
do
    case ${option} in
	s)
	    flen=${OPTARG}
	    ;;
	*)
	    usage
	    exit 1
	    ;;
    esac
done

if test $# -ne 4; then
    exit 0
fi

mdir=macs
if test ! -e $mdir; then mkdir $mdir; fi

IP=$1
Input=$2
peak=$3
mode=$4

macs="macs2 callpeak -t $IP -c $Input -g hs -f BAM"
if test -e $IP && test -s $IP ; then
    if test -e $Input && test -s $Inpput ; then
	if test $mode = "nomodel"; then
	    if test ! -e $mdir/${peak}-nomodel_summits.bed; then $macs -n $mdir/$peak-nomodel --nomodel --shift $flen; fi
	elif test $mode = "broad"; then
	    if test ! -e $mdir/${peak}_summits.bed; then         $macs -n $mdir/$peak --broad; fi
	elif test $mode = "broad-nomodel"; then
	    if test ! -e $mdir/${peak}-nomodel_summits.bed; then $macs -n $mdir/$peak-nomodel --nomodel --shift $flen --broad; fi
	else 
	    if test ! -e $mdir/${peak}_summits.bed; then         $macs -n $mdir/$peak; fi
	fi
    else
	echo "$Input does not exist."
    fi
else
    echo "$IP does not exist."
fi
