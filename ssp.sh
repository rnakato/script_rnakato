#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [-k kmer] [-o dir] <mapfile> <prefix> <build>" 1>&2
}

k=50
odir=sspout
while getopts k:o: option
do
    case ${option} in
	k)
	    k=${OPTARG}
	    ;;
	o)
	    odir=${OPTARG}
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
input=$1
prefix=$2
build=$3

if test ! -e log; then mkdir log; fi

if test $build = "scer"; then
    Ddir=`database.sh`/others/S_cerevisiae
elif test $build = "pombe"; then
    Ddir=`database.sh`/others/S_pombe
else
    Ddir=`database.sh`/UCSC/$build
fi

gt=$Ddir/genome_table

mptable=$(cd $(dirname $0) && pwd)/../SSP/data/mptable/mptable.UCSC.$build.${k}mer.flen150.txt

if test -e $input && test -s $input ; then
    if test ! -e $odir/$prefix.stats.txt ; then ssp -i $input -o $prefix --odir $odir --gt $gt --mptable $mptable -p 4 >& log/ssp-$prefix; fi
else
    echo "$input does not exist."
fi
