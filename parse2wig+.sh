#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [-a] [-e] [-mp] [-b binsize] [-k kmer] [-o dir] [-f of] <bam> <prefix> <build>" 1>&2
}

binsize=100
k=50
pdir=parse2wigdir+
all=0
db=UCSC
of=3
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
            pair="--pair"
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
mptable=$Ddir/mappability_Mosaics_${k}mer/map_fragL150_genome.txt
mpbinary=$Ddir/mappability_Mosaics_${k}mer

if test $mp = 1; then
    mp="--mptable $mptable"
    mppost="-mpbl"
else
    mp=""
    mppost=""
fi

ex(){ echo $1; eval $1; }

parse2wigparam="--gt $gt -i $bam $mp $pair --odir $pdir --outputformat $of -p 4"

func(){
    if test $all = 1; then
	if test ! -e $pdir/$prefix-raw$mppost.$binsize.tsv; then
	    ex "parse2wig+ $parse2wigparam -o $prefix-raw$mppost --binsize $binsize"
	fi
    fi

    if test $build = "scer" -o $build = "pombe"; then
	bins="$binsize"
    else
	bins="$binsize 5000 100000"
    fi
    for b in $bins; do
	if test ! -e $pdir/$prefix-raw$mppost-GR.$b.tsv; then
	    ex "parse2wig+ $parse2wigparam -o $prefix-raw$mppost-GR -n GR --binsize $b"
	fi
    done
    if test ! -e $pdir/$prefix-GC-depthoff$mppost-GR.100000.tsv; then
	ex "parse2wig+ $parse2wigparam -o $prefix-GC-depthoff$mppost-GR -n GR --chrdir $chrpath --mpdir $mpbinary --binsize 100000 --gcdepthoff"
    fi
}

func
parsestats4DROMPAplus.pl $pdir/$prefix-GC-depthoff$mppost-GR.100000.tsv >& log/parsestats-$prefix.GC.100000
parsestats4DROMPAplus.pl $pdir/$prefix-raw$mppost-GR.$binsize.tsv >& log/parsestats-$prefix.$binsize
