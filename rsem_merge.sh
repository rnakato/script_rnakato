#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "rsem_merge.sh [-n] <files> <output> <gtf> <build> <strings for sed>" 1>&2
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

array=$1
outname=$2
gtf=$3
build=$4
str_sed=$5

for str in genes isoforms; do
    s=""
    for prefix in $array; do s="$s star/$prefix.$build.$str.results"; done

    for tp in count TPM; do
	head=$outname.$str.$tp.$build
	rsem-generate-data-matrix-modified $tp $s > $head.txt
	cat $head.txt | sed -e 's/.'$build'.'$str'.results//g' > $head.temp
	mv $head.temp $head.txt
	for rem in $str_sed "star\/"
	  do
	  cat $head.txt | sed -e 's/'$rem'//g' > $head.temp
	  mv $head.temp $head.txt
	done
    done
done

for tp in count TPM; do
    add_genename_fromgtf.pl $outname.isoforms.$tp.$build.txt $gtf > $outname.isoforms.$tp.$build.addname.txt
    mv $outname.isoforms.$tp.$build.addname.txt $outname.isoforms.$tp.$build.txt
done

if test $name -eq 1; then
    for str in genes isoforms; do
	for tp in count TPM; do
	    convert_genename_fromgtf.pl $outname.$str.$tp.$build.txt $gtf > $outname.$str.$tp.$build.temp.txt
	    mv $outname.$str.$tp.$build.temp.txt $outname.$str.$tp.$build.txt
	done
    done
fi

s=""
for str in genes isoforms; do
    for tp in count TPM; do
	head=$outname.$str.$tp.$build
	s="$s -i $head.txt"
    done
done

csv2xlsx.pl $s -o $outname.$build.xlsx
