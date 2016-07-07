#!/bin/bash
function usage()
{
    echo "zinba.sh [-f <tagAlign|bowtie|bed>] [-l <36|50>] <IP> <Input> <output> <build>" 1>&2
}

format="bed"
readlen=50
while getopts f:l: option
do
    case ${option} in
	f)
	    format=${OPTARG}
	    ;;
	l)
	    readlen=${OPTARG}
	    ;;
	*)
	    usage
	    exit 1
	    ;;
    esac
done
shift $((OPTIND - 1))

# check arguments
if [ $# -ne 4 ]; then
  usage
  exit 1
fi

dir=zinba
if test ! -e $dir; then mkdir $dir; fi

IP=$1
Input=$2
outdir=$dir/$3
build=$4

Ddir=`database.sh`
mpdir=$Ddir/UCSC/$build/mappability_${readlen}mer/
genome=$Ddir/UCSC/$build/genome.2bit

zinba=$(cd $(dirname $0) && pwd)/zinba.R

Rscript $zinba -mp=$mpdir -g=$genome -o=$outdir -c=$IP -t=$format -i=$Input 
