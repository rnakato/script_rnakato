#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "pp.sh [-s] <bam> <prefix>" 1>&2
}

pmulti="-p=12"
while getopts s option
do
    case ${option} in
	s)
	    pmulti=""
	    ;;
	*)
	    usage
	    exit 1
	    ;;
    esac
done
shift $((OPTIND - 1))

# check arguments
if [ $# -ne 2 ]; then
  usage
  exit 1
fi

R=$(cd $(dirname $0) && pwd)/../binaries/phantompeakqualtools/run_spp.R
mdir=ppout
if test ! -e $mdir; then mkdir $mdir; fi

IPbam=$1
prefix=$2
if test -e $IPbam && test -s $IPbam ; then
    if test ! -e $mdir/$prefix.SN ; then Rscript $R $pmulti -c=$IPbam -i=$IPbam -rf -savn=$mdir/$prefix.narrowPeak -savr=$mdir/$prefix.regionPeak -out=$mdir/$prefix.resultfile -savp=$mdir/$prefix.pdf; fi
    echo -en "$prefix\t" > $mdir/$prefix.SN
    cut -f9,10,11 $mdir/$prefix.resultfile >> $mdir/$prefix.SN
else
    echo "$IPbam does not exist."
fi
