#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname" '[-a] [-b binsize] [-n] [-f of] [-d outputdir] [-p "bowtie2 param"] <exec|stats|header> <fastq> <prefix> <build>' 1>&2
}

pa=""
bowtieparam=""
nopp=0
cramdir=cram
of=0
binsize=100
while getopts ab:d:nf:p: option
do
    case ${option} in
	a)
	    pa="-a"
	    ;;
	b)
	    binsize=${OPTARG}
                ;;
	d)
	    cramdir=${OPTARG}
	        ;;
        n)
            nopp=1
            ;;
        f)
            of=${OPTARG}
            ;;
        p)
            bowtieparam=${OPTARG}
            ;;
	*)
	    usage
	    exit 1
	    ;;
    esac
done
shift $((OPTIND - 1))

if [ $# -ne 4 ]; then
  usage
  exit 1
fi

type=$1
fastq=$2
prefix=$3
build=$4

post="-bowtie2"`echo $bowtieparam | tr -d ' '`
head=$prefix$post-$build

if test $build = "scer"; then
    Ddir=`database.sh`/others/S_cerevisiae
elif test $build = "pombe"; then
    Ddir=`database.sh`/others/S_pombe
else
    Ddir=`database.sh`/$db/$build
fi

pair=""
# for paired-end fastq
if [[ $fastq == *-1\ * ]]; then
    fastq=${fastq/-1/\\-1}
    fastq=${fastq/-2/\\-2}
    pair="-p"
fi

gt=$Ddir/genome_table
cram=$cramdir/$head.sort.cram

if test $type = "exec"; then
    bowtie2.sh -d $cramdir -p "$bowtieparam" "$fastq" $prefix $build
    parse2wig.sh $pa $pair -b $binsize $pens -f $of $cram $head $build
    if test $nopp != 1; then ssp.sh $pair $cram $head $build; fi
elif test $type = "stats"; then
    a=`parsebowtielog2.pl $pair log/bowtie2-$head | grep -v Sample`
    b=`cat log/parsestats-$head.GC.100000 | grep -v Sample | cut -f6,7,8,9`
    gcov=`cat log/parsestats-$head.$binsize | grep -v Sample | cut -f10`
    b2=`cat log/parsestats-$head.GC.100000 | grep -v Sample | cut -f11,12`
    echo -en "$a\t$b\t$gcov\t$b2\t$c"

    if test $nopp != 1; then
	echo -en "`tail -n1 sspout/$head.stats.txt | cut -f4,5,6,7,8,9,10,11,12,13,14`"
    fi
    echo ""
elif test $type = "header"; then
    a=`parsebowtielog2.pl $pair log/bowtie2-$head | grep Sample`
    b=`cat log/parsestats-$head.GC.100000 | grep Sample | cut -f6,7,8,9`
    gcov=`cat log/parsestats-$head.$binsize | grep Sample | cut -f10`
    b2=`cat log/parsestats-$head.GC.100000 | grep Sample | cut -f11,12`
    echo -e "$a\t$b\t$gcov\t$b2\t$c"
#    echo -e "\tSequenced reads	Mapped 1 time	%	Mapped >1 times	%	Mapped all	%	Unmapped	%	Nonredundant	Redundant	Complexity for10M	Read depth	Genome coverage	Tested reads	GC summit	read length	fragment length	SSP-NSC	SSP-RLSC	SSP-RSC	Background uniformity	FCS(read)	FCS(flen)	FCS(1k)	FCS(10k)	FCS(100k)
"
fi
