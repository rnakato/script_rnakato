#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "edgeR.sh [-n] <Matrix> <build> <num of reps> <FDR> <gtf>" 1>&2
}

name=0
while getopts n option
do
    case ${option} in
        n)
            name=1
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

outname=$1
build=$2
n=$3
p=$4
gtf=$5

Rdir=$(cd $(dirname $0) && pwd)
R="Rscript $Rdir/edgeR.R"

ex(){
    echo $1
    eval $1
}

convertname(){
    str=$1
    nline=$2
    s=""
    for ty in all DEGs upDEGs downDEGs; do
	head=$outname.$str.count.$build.edgeR.$ty
	cat $head.csv | sed 's/,/\t/g' > $head.csv.temp
	mv $head.csv.temp $head.csv
	convert_genename_fromgtf.pl gene $head.csv $gtf $nline > $head.name.csv
	s="$s -i $head.name.csv"
    done
    csv2xlsx.pl $s -o $outname.$str.count.$build.edgeR.name.xlsx
}

if test $p = "density"; then
    ex "$R -i=$outname.genes.TPM.$build.txt    -n=$n -o=$outname.genes.TPM.$build    -density"
    ex "$R -i=$outname.isoforms.TPM.$build.txt -n=$n -o=$outname.isoforms.TPM.$build -density -nrowname=2"
else
    ex "$R -i=$outname.genes.count.$build.txt    -n=$n -o=$outname.genes.count.$build    -p=$p"
    ex "$R -i=$outname.isoforms.count.$build.txt -n=$n -o=$outname.isoforms.count.$build -p=$p -nrowname=2 -color=orange"
    for str in genes isoforms; do
	s=""
	for ty in all DEGs upDEGs downDEGs;do s="$s -i $outname.$str.count.$build.edgeR.$ty.csv"; done
	csv2xlsx.pl $s -o $outname.$str.count.$build.edgeR.xlsx -d,
    done
    if test $name -eq 1; then
	convertname genes 0
	convertname isoforms 0
    fi
fi
