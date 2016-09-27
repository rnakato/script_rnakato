#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [-s] [-e] [-a] [-n] [-t <hiseq|csfasta|csfastq>] [-d bamdir] <exec|stats> <fastq> <prefix> <bowtie param> <build>" 1>&2
}

pppar=""
pens=""
btype="hiseq"
pa=""
nopp=0
bamdir=bam
while getopts ased:nt: option
do
    case ${option} in
	a)
	    pa="-a"
	    ;;
	s)
	    pppar="-s"
	    ;;
	e)
	    pens="-e"
	    ;;
	d)
	    bamdir=${OPTARG}
	        ;;
        n)
            nopp=1
            ;;
        t)
            btype=${OPTARG}
            ;;
	*)
	    usage
	    exit 1
	    ;;
    esac
done
shift $((OPTIND - 1))

# check arguments
if [ $# -ne 5 ]; then
  usage
  exit 1
fi

type=$1
fastq=$2
prefix=$3
bowtieparam=$4
build=$5

post=`echo $bowtieparam | tr -d ' '`
head=$prefix$post-$build

if test $type = "exec";then
    bam=$bamdir/$head.sort.bam
    bowtie.sh $pens -d $bamdir -t $btype $fastq $prefix $build "$bowtieparam"
    if test ! -e $bam.bai; then samtools index $bam; fi
    parse2wig.sh $pa $pens $bam $head $build
    if test $nopp != 1; then pp.sh $pppar $bam $bam $head; fi
elif test $type = "stats"; then
    a=`parsebowtielog.pl log/bowtie-$head | grep -v Sample`
    b=`cat log/parsestats-$head | grep -v Sample | cut -f6,7,8,9,10,11,12`
    c=`cut -f2,3,4 ppout/$head.SN`
    echo -e "$a\t$b\t$c"
fi
