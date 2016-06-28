#!/bin/bash
function usage()
{
    echo "pp.sh [-s] [-n] <IPbam> <Inputbam> <prefix>" 1>&2
}

pmulti="-p=12"
nodup=0
while getopts sn option
do
    case ${option} in
	s)
	    pmulti=""
	    ;;
	n)
	    nodup=1
	    ;;
	*)
	    usage
	    exit 1
	    ;;
    esac
done
shift $((OPTIND - 1))

# check arguments
if [ $# -ne 3 ]; then
  usage
  exit 1
fi

# If you have removed duplicates from your sample use run_spp_nodups.R instead of run_spp.R otherwise you will get errors
if test nodup = 0; then
    R=$(cd $(dirname $0) && pwd)/../phantompeakqualtools/run_spp.R
else
    R=$(cd $(dirname $0) && pwd)/../phantompeakqualtools/run_spp_nodups.R
fi

mdir=ppout
if test ! -e $mdir; then mkdir $mdir; fi

IPbam=$1
Inputbam=$2
prefix=$3
if test -e $IPbam && test -s $IPbam ; then
    if test ! -e $mdir/$prefix.SN ; then Rscript $R $pmulti -c=$IPbam -i=$Inputbam -rf -savn=$mdir/$prefix.narrowPeak -savr=$mdir/$prefix.regionPeak -out=$mdir/$prefix.resultfile -savp=$mdir/$prefix.pdf; fi
    echo -en "$prefix\t" > $mdir/$prefix.SN
    cut -f9,10,11 $mdir/$prefix.resultfile >> $mdir/$prefix.SN
else
    echo "$IPbam does not exist."
fi
