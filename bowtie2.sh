#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "bowtie2.sh [-e] [-d bamdir] <fastq> <prefix> <build>" 1>&2
}

type=hiseq
bamdir=bam
db=UCSC
while getopts ed: option
do
    case ${option} in
	e)
	    db=Ensembl
	    ;;
	d)
	    bamdir=${OPTARG}
	    ;;
	*)
	    usage
	    exit 1
	    ;;
    esac
done
shift $((OPTIND - 1))

# check arguments
if [ $# -ne 3 ]; then
  usage
  exit 1
fi

fastq=$1
prefix=$2
build=$3
post="-bowtie2"

if test ! -e $bamdir; then mkdir $bamdir; fi
if test ! -e log; then mkdir log; fi

Ddir=`database.sh`

#samtools=$(cd $(dirname $0) && pwd)/../binaries/bwa-current/samtools
samtools=samtools

file=$bamdir/$prefix$post-$build.sort.bam
if test -e "$file.bam" && test 1000 -lt `wc -c < $file.bam` ; then
    echo "$file.bam already exist. quit"
    exit 0
fi


ex_hiseq(){
    index=$Ddir/bowtie2-indexes/$db-$build
    if [ `echo $fastq | grep '.gz'` ] ; then
	command="bowtie2 $param -p12 -x $index <(zcat $fastq) | $samtools view -bS - | $samtools sort > $file"
    else
	command="bowtie2 $param -p12 -x $index $fastq | $samtools view -bS - | $samtools sort > $file"
    fi
    echo $command
    eval $command
}

log=log/bowtie2-$prefix-$build
ex_hiseq >& $log


