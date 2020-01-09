#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [-a] [-e] [-b binsize] [-k kmer] [-o dir] [-f of] <bam> <prefix> <build>" 1>&2
}

binsize=100
k=50
pdir=parse2wigdir
all=0
db=UCSC
of=0
pair=""
while getopts aeb:k:o:f:p option
do
    case ${option} in
	a)
	    all=1
	    ;;
	e)
	    db=Ensembl
	    ;;
	b)
	    binsize=${OPTARG}
	    ;;
	k)
	    k=${OPTARG}
	    ;;
	o)
	    pdir=${OPTARG}
	    ;;
	f)
            of=${OPTARG}
            ;;
	p)
            pair="-pair"
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
bam=$1
prefix=$2
build=$3

if test ! -e log; then mkdir log; fi

if test $build = "scer"; then
    Ddir=`database.sh`/others/S_cerevisiae
elif test $build = "pombe"; then
    Ddir=`database.sh`/others/S_pombe
else
    Ddir=`database.sh`/$db/$build
fi
gt=$Ddir/genome_table
chrpath=$Ddir/chromosomes
mpbl=$Ddir/mappability_Mosaics_${k}mer/map_fragL150
mpbin=$Ddir/mappability_Mosaics_${k}mer/map

func(){
    if test $all = 1; then
	if test ! -e $pdir/$prefix-raw-mpbl.$binsize.xls; then
	    echo "parse2wig -gt $gt -f BAM -i $bam -mp $mpbl $pair -o $prefix-raw-mpbl -binsize $binsize -odir $pdir -of $of"
	    parse2wig -gt $gt -f BAM -i $bam -mp $mpbl $pair -o $prefix-raw-mpbl -binsize $binsize -odir $pdir -of $of
	fi
    fi

    if test $build = "scer"; then
	bins="$binsize"
    elif test $build = "pombe"; then
	bins="$binsize"
    else
	bins="$binsize 100000"
    fi
    for b in $bins; do
	if test ! -e $pdir/$prefix-raw-mpbl-GR.$b.xls; then
	    echo "parse2wig -gt $gt -f BAM -i $bam -mp $mpbl $pair -o $prefix-raw-mpbl-GR -n GR -binsize $b -odir $pdir -of $of"
	    parse2wig -gt $gt -f BAM -i $bam -mp $mpbl $pair -o $prefix-raw-mpbl-GR -n GR -binsize $b -odir $pdir -of $of
	fi
    done
    if test ! -e $pdir/$prefix-GC-depthoff-mpbl-GR.100000.xls; then
	echo "parse2wig -gt $gt -f BAM -i $bam -mp $mpbl $pair -o $prefix-GC-depthoff-mpbl-GR -n GR -GC $chrpath -mpbin $mpbin -binsize 100000 -gcdepthoff -odir $pdir -of $of"
	parse2wig -gt $gt -f BAM -i $bam -mp $mpbl $pair -o $prefix-GC-depthoff-mpbl-GR -n GR -GC $chrpath -mpbin $mpbin -binsize 100000 -gcdepthoff -odir $pdir -of $of
    fi
}

func
parsestats4DROMPA3.pl $pdir/$prefix-GC-depthoff-mpbl-GR.100000.xls >& log/parsestats-$prefix.GC.100000
parsestats4DROMPA3.pl $pdir/$prefix-raw-mpbl-GR.$binsize.xls >& log/parsestats-$prefix.$binsize
