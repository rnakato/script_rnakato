#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname <matrixdir> <hic file> <binsize> <build>" 1>&2
}

norm=VC_SQRT
while getopts k option
do
    case ${option} in
        k)
            norm=KR
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

matrixdir=$1
hic=$2
binsize=$3
build=$4

gt=/home/Database/UCSC/$build/genome_table

if test $build = "mm10" -o $build = "mm9"; then
    chrnum=19
else
    chrnum=22
fi

juicertool="java -Xms512m -Xmx2048m -jar /home/git/binaries/Aidenlab/juicer_tools.1.8.9_jcuda.0.8.jar"
dir=$matrixdir/intrachromosomal/$binsize
mkdir -p $dir

pwd=$(cd $(dirname $0) && pwd)

for chr in $(seq 1 $chrnum) X; do
    echo $chr
    for type in observed oe
    do
        $juicertool dump $type $norm $hic $chr $chr BP $binsize $dir/$type.$norm.chr$chr.txt
        $pwd/convert_JuicerDump_to_dense.py $dir/$type.$norm.chr$chr.txt $dir/$type.$norm.chr$chr.matrix.gz $gt chr$chr $binsize
        rm $dir/$type.$norm.chr$chr.txt
    done
    for type in #expected norm
    do
        $juicertool dump $type #$norm $hic.hic $chr BP $binsize $dir/$type.$norm.chr$chr.matrix -d
    done
done


