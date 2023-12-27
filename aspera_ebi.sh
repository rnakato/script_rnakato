#!/bin/bash

cmdname=`basename $0`
function usage()
{
    echo "Usage: ${cmdname} RunTable.txt" 1>&2
    echo '   Options:' 1>&2
    echo '      -n <int>: column of SRR id (1-based, default: 7)' 1>&2
}

pair=FALSE
n=7
while getopts n: option
do
  case ${option} in
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
urls=`cut -f$n $file | grep -v fastq_ftp | grep -v submitted_ftp | sed -e 's|ftp.sra.ebi.ac.uk|era-fasp@fasp.sra.ebi.ac.uk:|g' | sed -e  's|\;| |g'`

ssh=/home/rnakato/.aspera/connect/etc/asperaweb_id_dsa.openssh

for url in $urls
do
    fq=`basename $url`
    echo $url $fq
    if test -e $fq && test -s $fq; then
        echo "$fq exists"
    else
        ascp -QT -l 100M -P33001 -i $ssh $url ./
    fi
done
