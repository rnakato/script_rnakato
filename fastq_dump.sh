#!/bin/bash

cmdname=`basename $0`
function usage()
{
    echo "Usage: ${cmdname} [-t] SraRunTable.txt" 1>&2
    echo '   Options:' 1>&2
    echo '      -t: tab-separated file (default: comma-separated file)' 1>&2
    echo '      -p: paired-end fastq (default: single-end)' 1>&2
    echo '      -n <int>: column of SRR id (0-based, default: 1)' 1>&2
}

# check options
tab=FALSE
pair=FALSE
n=1
while getopts tpn: option
do
  case ${option} in
    t) tab=TRUE;;
    t) pair=TRUE;;
    n) n=${OPTARG};;
    *)
      usage
      exit 1
      ;;
  esac
done
shift $((OPTIND - 1))

# check arguments
if [ $# -ne 1 ]; then
  usage
  exit 1
fi
file="$1"

if test $tab; then
    ids=`cut -d, -f$n $file | grep -v Run`
else
    ids=`cut     -f$n $file | grep -v Run`
fi

for id in $ids
do
    echo $id
    if test $pair; then
        fq=$id.fastq.gz
        if test -e $fq && test -s $fq ; then
            echo "$fq exists"
        else
            echo "singularity exec --bind /home,/work,/work2 /work/SingularityImages/SRAtools.3.0.0.sif fastq-dump --gzip $id"
    fi
    else
        fq1=${id}_1.fastq.gz
        fq2=${id}_2.fastq.gz
        if test -e $fq1 && test -s $fq1 && test -e $fq2 && test -s $fq2 ; then
            echo "$fq1| $fq2 exists"
        else
            echo "singularity exec --bind /home,/work,/work2 /work/SingularityImages/SRAtools.3.0.0.sif fastq-dump --gzip $id"
        fi
    fi
done
