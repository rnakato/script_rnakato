#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [-a] [-e] [-mp] [-b binsize] [-k kmer] [-o dir] [-f of] <bam> <prefix> <build>" 1>&2
}

binsize=100
k=50
pdir=parse2wigdir
all=0
db=UCSC
of=0
pair=""
mp=0
while getopts aeb:mk:o:f:p option
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
	m)
	    mp=1
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

if test $mp = 1; then
    mp="-mp $mpbl"
    mppost="-mpbl"
else
    mp=""
    mppost=""
fi

ex(){ echo $1; eval $1; }

func(){
    if test $all = 1; then
	if test ! -e $pdir/$prefix-raw$mppost.$binsize.xls; then
	    ex "parse2wig -gt $gt -f BAM -i $bam $mp $pair -o $prefix-raw$mppost -binsize $binsize -odir $pdir -of $of"
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
	if test ! -e $pdir/$prefix-raw$mppost-GR.$b.xls; then
	    ex "parse2wig -gt $gt -f BAM -i $bam $mp $pair -o $prefix-raw$mppost-GR -n GR -binsize $b -odir $pdir -of $of"
	fi
    done
    if test ! -e $pdir/$prefix-GC-depthoff$mppost-GR.100000.xls; then
	ex "parse2wig -gt $gt -f BAM -i $bam $mp -mpbin $mpbin $pair -o $prefix-GC-depthoff$mppost-GR -n GR -GC $chrpath -binsize 100000 -gcdepthoff -odir $pdir -of $of"
    fi
}

func
parsestats4DROMPA3.pl $pdir/$prefix-GC-depthoff$mppost-GR.100000.xls >& log/parsestats-$prefix.GC.100000
parsestats4DROMPA3.pl $pdir/$prefix-raw$mppost-GR.$binsize.xls >& log/parsestats-$prefix.$binsize
