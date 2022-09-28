#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname" '[Options] <exec|stats|header> <fastq> <prefix> <build>' 1>&2
    echo '      -a: output raw count data in addition to normalized count data in parse2wig+' 1>&2
    echo '      -b: binsize of parse2wig+ (defalt: 100)' 1>&2
    echo '      -B: output as BAM format (defalt: CRAM)' 1>&2
    echo '      -n: omit ssp' 1>&2
    echo '      -f: output format of parse2wig+ (default: 3)' 1>&2
    echo '               0: compressed wig (.wig.gz)' 1>&2
    echo '               1: uncompressed wig (.wig)' 1>&2
    echo '               2: bedGraph (.bedGraph)' 1>&2
    echo '               3: bigWig (.bw)' 1>&2
    echo '      -d: output directory of map files (default: cram)' 1>&2
    echo '      -p "param": parameter of bowtie|bowtie2 (shouled be quated)' 1>&2
    echo "  Example:" 1>&2
    echo "  For single-end: $cmdname exec chip.fastq.gz chip hg38" 1>&2
    echo "  For paired-end: $cmdname exec \"-1 chip_1.fastq.gz -2 chip_2.fastq.gz\" chip hg38" 1>&2
}

pa=""
bowtieparam=""
nopp=0
format=CRAM
cramdir=cram
of=3
binsize=100
while getopts ab:Bd:nf:p: option
do
    case ${option} in
	a)
	    pa="-a"
	    ;;
	b)
	    binsize=${OPTARG}
                ;;
        B) format=BAM
           cramdir=bam
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

if [ $# -eq 0 ]; then
  usage
  exit 1
fi

if test $1 = "header"; then
    echo -e "\tSample\tSequenced reads	Mapped 1 time	%	Mapped >1 times	%	Mapped all	%	Unmapped	%	Nonredundant	Redundant	Complexity for10M	Tested reads	Read depth	Genome coverage	reads in peaks	FRiP	GC summit	read length	fragment length	SSP-NSC	SSP-RLSC	SSP-RSC	Background uniformity	FCS(read)	FCS(flen)	FCS(1k)	FCS(10k)	FCS(100k)"
    exit
fi

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

if test $type = "exec"; then
    if test $format = "CRAM"; then
        bowtie2.sh    -d $cramdir -p "$bowtieparam" "$fastq" $prefix $build
    else
        bowtie2.sh -B -d $cramdir -p "$bowtieparam" "$fastq" $prefix $build
    fi

    if test $format = "CRAM"; then
        mapfile=$cramdir/$head.sort.cram
    else
        mapfile=$cramdir/$head.sort.bam
    fi
    parse2wig+.sh $pa $pair -b $binsize $pens -f $of $mapfile $head $build
    if test $nopp != 1; then ssp.sh $pair $mapfile $head $build; fi
elif test $type = "stats"; then
    a=`parsebowtielog2.pl $pair log/bowtie2-$head | grep -v Sample`
    b=`cat log/parsestats-$head.GC.100000 | grep -v Sample | cut -f6,7,8,9`
    gcov=`cat log/parsestats-$head.$binsize | grep -v Sample | cut -f10`
    b2=`cat log/parsestats-$head.GC.100000 | grep -v Sample | cut -f11,12,13,14`
    echo -en "$a\t$b\t$gcov\t$b2\t$c"

    if test $nopp != 1; then
	echo -en "`tail -n1 sspout/$head.stats.txt | cut -f4,5,6,7,8,9,10,11,12,13,14`"
    fi
    echo ""
fi
