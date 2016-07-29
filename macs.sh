#!/bin/bash
function usage()
{
    echo "macs.sh [-p species] [-s fraglen/2] [-q qvalue] <IP bam> <Input bam> <output> [sharp|broad|nomodel|broad-nomodel]" 1>&2
}

flen=100
qval=0.05
species="hs"
while getopts p:s:q: option
do
    case ${option} in
        p)
            species=${OPTARG}
            ;;
	s)
	    flen=${OPTARG}
	    ;;
	q)
	    qval=${OPTARG}
	    ;;
	*)
	    usage
	    exit 1
	    ;;
    esac
done
shift $((OPTIND - 1))

if test $# -ne 4; then
    usage
    exit 0
fi

mdir=macs
if test ! -e $mdir; then mkdir $mdir; fi

IP=$1
Input=$2
peak=$3
mode=$4

if test -e $IP && test -s $IP ; then
    n=1
else
    echo "$IP does not exist."
fi
if test $Input = "none"; then
    macs="macs2 callpeak -t $IP -g $species -f BAM"
else
    macs="macs2 callpeak -t $IP -c $Input -g $species -f BAM"
    if test -e $Input && test -s $Input; then
	n=1
    else
        echo "$Input does not exist."
    fi
fi

if test $mode = "nomodel"; then
    if test ! -e $mdir/${peak}-nomodel_summits.bed; then $macs -q $qval -n $mdir/$peak-nomodel --nomodel --shift $flen; fi
elif test $mode = "broad"; then
    if test ! -e $mdir/${peak}_summits.bed; then         $macs -q $qval -n $mdir/$peak --broad; fi
elif test $mode = "broad-nomodel"; then
    if test ! -e $mdir/${peak}-nomodel_summits.bed; then $macs -q $qval -n $mdir/$peak-nomodel --nomodel --shift $flen --broad; fi
else 
    if test ! -e $mdir/${peak}_summits.bed; then         $macs -q $qval -n $mdir/$peak; fi
fi
