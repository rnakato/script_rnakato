#!/bin/bash
function usage()
{
    echo "drompa_draw.sh [-e] [PC|GV|BROAD] <samples> <options> <output> <build>" 1>&2
}

ens=0
while getopts e option
do
    case ${option} in
        e)
	    ens=1
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

if test $# -ne 5; then
    usage
    exit 0
fi

mdir=pdf
if test ! -e $mdir; then mkdir $mdir; fi

type=$1
s=$2
param=$3
output=$4
build=$5

Ddir=$(database.sh)/UCSC/$build
gt=$Ddir/genome_table
GC=$Ddir/GCcontents
genedensity=$Ddir/genedensity

if test $ens = 0; then
    gene=$Ddir/refFlat.dupremoved.txt
else
    gene=$(database.sh)/Ensembl/GRCh38/gtf_chrUCSC/Homo_sapiens.GRCh38.88.chr.gene.name.refFlat
fi

if test $type = "GV"; then
    drompa_draw GV -gt $gt $s $param -p $mdir/drompa3.GV.$output -GC $GC -gcsize 500000 -GD $genedensity -gdsize 500000
elif test $type = "BROAD"; then
    drompa_draw PC_ENRICH -gene $gene $s $param -p $mdir/drompa3.BROAD.$output -gt $gt -ls 20000 -binsize 100000 -nosig -offbg
else
    drompa_draw PC_SHARP -gene $gene $s $param -p $mdir/drompa3.PC.$output -gt $gt
fi
