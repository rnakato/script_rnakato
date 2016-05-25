#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [-s] [-e] [-a] <exec|stats> <fastq> <prefix> <bowtie param> <build>" 1>&2
}

pppar=""
pens=""
pa=""
while getopts se: option
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
    bam=bam/$head.sort.bam
    bowtie.sh $pens -t fastq $fastq $prefix $build "$bowtieparam"
    parse2wig.sh $pa $pens $bam $head $build
    pp.sh $pppar $bam $head
elif test $type = "stats"; then
    a=`parsebowtielog.pl log/bowtie-$head | grep -v Sample`
    b=`cat log/parsestats-$head | grep -v Sample | cut -f6,7,8,9,10,11,12`
    c=`cut -f2,3,4 ppout/$head.SN`
    echo -e "$a\t$b\t$c"
fi
