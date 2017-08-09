#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [-s] [-e] [-a] [-n] [-f of] [-t <hiseq|csfasta|csfastq>] [-p <bowtie|bowtie2>] [-d bamdir] <exec|stats> <fastq> <prefix> <bowtie param> <build>" 1>&2
}

pppar=""
pens=""
btype="hiseq"
pa=""
nopp=0
bamdir=bam
program="bowtie"
of=0
while getopts ased:nt:p:f: option
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
        p)
            program=${OPTARG}
            ;;
        f)
            of=${OPTARG}
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

if test $program = "bowtie2";then
    post="-bowtie2"
else
    post=`echo $bowtieparam | tr -d ' '`
fi
head=$prefix$post-$build

if test $build = "scer"; then
    Ddir=`database.sh`/others/S_cerevisiae
elif test $build = "pombe"; then
    Ddir=`database.sh`/others/S_pombe
else
    Ddir=`database.sh`/$db/$build
fi
gt=$Ddir/genome_table
mptable=../SSP/data/mptable/mptable.UCSC.$build.50mer.flen150.txt

if test $type = "exec";then
    bam=$bamdir/$head.sort.bam

    if test $program = "bowtie2";then
    	bowtie2.sh $pens -d $bamdir "$fastq" $prefix $build
    else
	bowtie.sh $pens -d $bamdir -t $btype "$fastq" $prefix $build "$bowtieparam"
    fi

    if test ! -e $bam.bai; then samtools index $bam; fi
    parse2wig.sh $pa $pens -f $of $bam $head $build

    #if test $nopp != 1; then pp.sh $pppar $bam $bam $head; fi
    ssp.sh $bam $head $build
    
elif test $type = "stats"; then
    if test $program = "bowtie2";then
	a=`parsebowtielog2.pl log/bowtie2-$head | grep -v Sample`
    else
	a=`parsebowtielog.pl log/bowtie-$head | grep -v Sample`
    fi
    b=`cat log/parsestats-$head.GC.100000 | grep -v Sample | cut -f6,7,8,9`
    gcov=`cat log/parsestats-$head.100 | grep -v Sample | cut -f10`
    b2=`cat log/parsestats-$head.GC.100000 | grep -v Sample | cut -f11,12`
#    c=`cut -f2,3,4,5 ppout/$head.SN`
    echo -e "$a\t$b\t$gcov\t$b2\t$c"
fi
