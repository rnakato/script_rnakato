#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "DESeq2multi.sh [-n] <Matrix> <build> <num of reps> <groupname> <FDR> <gtf>" 1>&2
    echo "  Example:" 1>&2
    echo "  DESeq2multi.sh -n star/Matrix GRCh38 2:2:2 WT:KD1:KD2 0.05 GRCh38.gtf" 1>&2
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

if [ $# -ne 6 ]; then
  usage
  exit 1
fi

outname=$1
build=$2
n=$3
gname=$4
p=$5
gtf=$6

Rdir=$(cd $(dirname $0) && pwd)
R="Rscript $Rdir/DESeq2multi.R"

ex(){
    echo $1
    eval $1
}

convertname(){
    str=$1
    nline=$2
    s=""
    for ty in all bothDEGs.all bothDEGs.up bothDEGs.down; do
	head=$outname.$str.count.$build.DESeq2multi.$ty
	cat $head.csv | sed 's/,/\t/g' > $head.csv.temp
	mv $head.csv.temp $head.csv
	if test $str = "genes"; then
	    convert_genename_fromgtf.pl gene $head.csv $gtf $nline > $head.name.csv
	else
	    convert_genename_fromgtf.pl transcript $head.csv $gtf $nline > $head.name.csv
	fi
	s="$s -i $head.name.csv -n $str-$ty"
    done
    csv2xlsx.pl $s -o $outname.$str.count.$build.DESeq2multi.name.xlsx
}

ex "$R -i=$outname.genes.count.$build.txt    -n=$n -gname=$gname -o=$outname.genes.count.$build    -p=$p"
ex "$R -i=$outname.isoforms.count.$build.txt -n=$n -gname=$gname -o=$outname.isoforms.count.$build -p=$p -nrowname=2"

for str in genes isoforms; do
    s=""
    for ty in all bothDEGs.all bothDEGs.up bothDEGs.down; do
	s="$s -i $outname.$str.count.$build.DESeq2multi.$ty.csv -n $str-$ty"
    done
    csv2xlsx.pl $s -o $outname.$str.count.$build.DESeq2multi.xlsx -d,
done

if test $name -eq 1; then
    convertname genes 0
    convertname isoforms 0
fi
