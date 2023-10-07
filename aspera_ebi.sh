#!/bin/bash

cmdname=`basename $0`
function usage()
{
    echo "Usage: ${cmdname} RunTable.txt" 1>&2
    echo '   Options:' 1>&2
    echo '      -p: paired-end fastq (default: single-end)' 1>&2
    echo '      -n <int>: column of SRR id (1-based, default: 8)' 1>&2
}

# check options
pair=FALSE
n=8
while getopts tpn: option
do
  case ${option} in
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
urls=`cut -f$n $file | grep -v fastq_ftp | grep -v submitted_ftp | sed 's|ftp.sra.ebi.ac.uk|era-fasp@fasp.sra.ebi.ac.uk:|g'`

ssh=/home/rnakato/.aspera/connect/etc/asperaweb_id_dsa.openssh

for url in $urls
do
    echo $url
    if test $pair; then
        ascp -QT -l 100M -P33001 -i $ssh $url ./
    else
        fq1=${id}_1.fastq.gz
        fq2=${id}_2.fastq.gz
        if test -e $fq1 && test -s $fq1 && test -e $fq2 && test -s $fq2 ; then
            echo "$fq1| $fq2 exists"
        else
            singularity exec --bind /home,/work,/work2 /work/SingularityImages/SRAtools.3.0.0.sif fastq-dump --gzip $id
        fi
    fi
done
