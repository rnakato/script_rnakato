#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [-a] [-e] [-b binsize] [-k kmer] [-o dir] <bam> <prefix> <build>" 1>&2
}

binsize=100
k=50
pdir=parse2wigdir
all=0
db=UCSC
while getopts aeb:k:o: option
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

Ddir=`database.sh`/$db/$build
gt=$Ddir/genome_table
chrpath=$Ddir/chromosomes
mpbl=$Ddir/mappability_Mosaics_${k}mer/map_fragL150
mpbin=$Ddir/mappability_Mosaics_${k}mer/map

func(){
    if test $all = 1; then
	if test ! -e $pdir/$prefix-raw-mpbl.$binsize.xls; then
	    parse2wig -gt $gt -f BAM -i $bam -mp $mpbl -o $prefix-raw-mpbl -binsize $binsize -odir $pdir;
	fi
	for b in $binsize 100000; do
	    if test ! -e $pdir/$prefix-raw-mpbl-GR.$b.xls; then
		parse2wig -gt $gt -f BAM -i $bam -mp $mpbl -o $prefix-raw-mpbl-GR -n GR -binsize $b -odir $pdir;
	    fi
	done
	if test ! -e $pdir/$prefix-GC-depthoff-mpbl-GR.100000.xls; then
	    parse2wig -gt $gt -f BAM -i $bam -mp $mpbl -o $prefix-GC-depthoff-mpbl-GR -n GR -GC $chrpath -mpbin $mpbin -binsize 100000 -gcdepthoff -odir $pdir
	fi
    else
	if test ! -e $pdir/$prefix-raw-mpbl-GR.$binsize.xls; then
	    parse2wig -gt $gt -f BAM -i $bam -mp $mpbl -o $prefix-raw-mpbl-GR -n GR -binsize $binsize -odir $pdir;
	fi
	if test ! -e $pdir/$prefix-GC-depthoff-mpbl-GR.100000.xls; then
	    parse2wig -gt $gt -f BAM -i $bam -mp $mpbl -o $prefix-GC-depthoff-mpbl-GR -n GR -GC $chrpath -mpbin $mpbin -binsize 100000 -gcdepthoff -odir $pdir
	fi
    fi
}

func #>& log/parse2wig-$prefix
parsestats4DROMPA3.pl $pdir/$prefix-GC-depthoff-mpbl-GR.100000.xls >& log/parsestats-$prefix
