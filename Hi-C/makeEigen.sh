#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname <matrixdir> <hic file> <binsize> <build>" 1>&2
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

if [ $# -ne 4 ]; then
  usage
  exit 1
fi

matrixdir=$1
hic=$2
binsize=$3
build=$4

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
    for norm in VC_SQRT KR
    do
        echo $chr
	$juicertool pearsons    -p $norm $hic chr$chr BP $binsize $dir/pearson.$norm.matrix
        $juicertool eigenvector -p $norm $hic chr$chr BP $binsize $dir/eigen.$norm.txt
        gzip -f $dir/pearson.$norm.matrix $dir/eigen.$norm.txt
    done
done
