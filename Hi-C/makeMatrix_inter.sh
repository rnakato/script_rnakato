#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname <matrixdir> <hic file> <binsize> <build> <lim_pzero>" 1>&2
}

all=0
while getopts a option
do
    case ${option} in
        a)
            all=1
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

if [ $# -ne 5 ]; then
  usage
  exit 1
fi

dir=$1
hic=$2
binsize=$3
build=$4
lim_pzero=$5

gt=/home/Database/UCSC/$build/genome_table

if test $build = "mm10" -o $build = "mm9"; then
    chrnum=19
else
    chrnum=22
fi

juicertool="java -Xms512m -Xmx2048m -jar /home/git/binaries/Aidenlab/juicer_tools.1.8.9_jcuda.0.8.jar"
pwd=$(cd $(dirname $0) && pwd)

for i in $(seq 1 $chrnum)
do
    for j in $(seq $i $chrnum); do
        d=$dir/interchromosomal/$binsize/chr$i-chr$j
        mkdir -p $d
        for type in observed oe; do
            echo $i $j $type
            $juicertool dump $type VC_SQRT $hic $i $j BP $binsize $d/$type.matrix -d
	    gzip -f $d/$type.matrix
        done
    done
done

for str in observed #oe
do
    $pwd/merge_JuicerMatrix_to_Genome.py $dir/interchromosomal \
        $dir/interchromosomal/$binsize/genome.$str.full.$lim_pzero.pickle \
        $binsize $str $lim_pzero $chrnum
    $pwd/merge_JuicerMatrix_to_Genome.py $dir/interchromosomal \
        $dir/interchromosomal/$binsize/genome.$str.evenodd.$lim_pzero.pickle \
        $binsize $str $lim_pzero $chrnum --evenodd
done
