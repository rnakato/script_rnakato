#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "bowtie.sh [-e] [-t <csfasta|csfastq>] [-d bamdir] <fastq> <prefix> <build> <param>" 1>&2
}

type=hiseq
bamdir=bam
db=UCSC
while getopts et:d: option
do
    case ${option} in
	e)
	    db=Ensembl
	    ;;
	t)
	    type=${OPTARG}
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
if [ $# -ne 4 ]; then
  usage
  exit 1
fi

fastq=$1
prefix=$2
build=$3
param=$4
post=`echo $param | tr -d ' '`

if test ! -e $bamdir; then mkdir $bamdir; fi
if test ! -e log; then mkdir log; fi

Ddir=`database.sh`

#samtools=$(cd $(dirname $0) && pwd)/../binaries/bwa-current/samtools

file=$bamdir/$prefix$post-$build.sort
if test -e "$file.bam" && test 1000 -lt `wc -c < $file.bam` ; then
    echo "$file.bam already exist. quit"
    exit 0
fi

ex_hiseq(){
    index=$Ddir/bowtie-indexes/$db-$build
    if [ `echo $fastq | grep '.gz'` ] ; then
	command="bowtie -S $index <(zcat $fastq) $param --chunkmbs 2048 -p12 | $samtools view -bS - | $samtools sort - $file"
    else 
	command="bowtie -S $index $fastq $param --chunkmbs 2048 -p12 | $samtools view -bS - | $samtools sort - $file"
    fi 
    echo $command
    eval $command
}

ex_csfasta(){
    index=$Ddir/bowtie-indexes/$db-$build-cs
    command="bowtie -S -C $index -f $fastq.csfasta -Q ${fastq}.QV.qual $param --chunkmbs 2048 -p12 | samtools view -bS - | samtools sort - $file"
    echo $command
    eval $command
}

ex_csfastq(){
    index=$Ddir/bowtie-indexes/$db-$build-cs
    command="bowtie -S -C $index $fastq $param --chunkmbs 2048 -p12 | samtools view -bS - | samtools sort - $file"
    echo $command
    eval $command
}

log=log/bowtie-$prefix$post-$build
if test $type = "csfasta"; then  ex_csfasta >& $log; 
elif test $type = "csfastq"; then  ex_csfastq >& $log;
else ex_hiseq >& $log
fi

