#!/bin/bash

cmdname=`basename $0`
function usage()
{
    echo "Usage: ${cmdname} [-t] SraRunTable.txt" 1>&2
    echo '   Options:' 1>&2
    echo '      -t: tab-separated file (default: comma-separated file)' 1>&2
    echo '      -p: paired-end fastq (default: single-end)' 1>&2
    echo '      -n <int>: column of SRR id (0-based, default: 1)' 1>&2
    echo '      -x <int>: number of CPUs (default: 10, note that too many CPUs will cause fastq_dump to fail)' 1>&2
}

# check options
tab=0
pair=0
n=1
ncore=10
while getopts tpn:x: option
do
  case ${option} in
    t) tab=1;;
    p) pair=1;;
    n) n=${OPTARG};;
    x) ncore=${OPTARG};;
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
inputfile="$1"

func(){
    id=$1
    pair=$2

    echo $id
    if test $pair -eq 1; then
        fq1=${id}_1.fastq.gz
        fq2=${id}_2.fastq.gz
        if test -e $fq1 && test -s $fq1 && test -e $fq2 && test -s $fq2 ; then
            echo "$fq1| $fq2 exists"
        else
            singularity exec --bind /home,/work,/work2,/work3 /work3/SingularityImages/SRAtools.3.0.0.sif fastq-dump --split-3 --gzip $id
        fi
    else
        fq=$id.fastq.gz
        if test -e $fq && test -s $fq ; then
            echo "$fq exists"
        else
            singularity exec --bind /home,/work,/work2,/work3 /work3/SingularityImages/SRAtools.3.0.0.sif fastq-dump --gzip $id
        fi
    fi
}
export -f func

if test $tab -eq 1; then
echo "tab"
    ids=`cut -f$n $inputfile | grep -v Run | tr '\n' ' '`
else
echo "comma"
    ids=`cut -f$n -d, $inputfile | grep -v Run | tr '\n' ' '`
fi

echo ${ids[@]} | tr ' ' '\n' | xargs -I {} -P $ncore bash -c "func {} $pair"

