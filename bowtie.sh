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

samtools=samtools

file=$bamdir/$prefix$post-$build.sort.bam
if test -e $file && test 1000 -lt `wc -c < $file` ; then
    echo "$file already exist. quit"
    exit 0
fi

ex_hiseq(){
    if test $build = "scer"; then
	index=$Ddir/bowtie-indexes/S_cerevisiae
    elif test $build = "pombe"; then
	index=$Ddir/bowtie-indexes/S_pombe
    else
	index=$Ddir/bowtie-indexes/$db-$build
    fi

    if [[ $fastq = *.gz ]]; then
	command="bowtie -S $index <(zcat $fastq) $param --chunkmbs 2048 -p12 | $samtools view -bS - | $samtools sort > $file"
    else 
	command="bowtie -S $index $fastq $param --chunkmbs 2048 -p12 | $samtools view -bS - | $samtools sort > $file"
    fi 
    echo $command
    eval $command
}

ex_csfasta(){
    # bowtie-1.2.2 has a bug for csfasta
    # use bowtie-1.1.2 
    if test $build = "scer"; then
	index=$Ddir/bowtie-indexes/S_cerevisiae-cs
    elif test $build = "pombe"; then
	index=$Ddir/bowtie-indexes/S_pombe-cs
    else
	index=$Ddir/bowtie-indexes/$db-$build-cs
    fi
    csfasta=`ls $fastq*csfasta*`
    qual=`ls $fastq*qual*`

    if [[ $csfasta = *.gz ]]; then
	command="/home/rnakato/git/binaries/bowtie-1.1.2/bowtie -S -C $index -f <(zcat $csfasta) -Q <(zcat $qual) $param --chunkmbs 2048 -p12 | samtools view -bS - | samtools sort > $file"
    else
	command="/home/rnakato/git/binaries/bowtie-1.1.2/bowtie -S -C $index -f $csfasta -Q $qual $param --chunkmbs 2048 -p12 | samtools view -bS - | samtools sort > $file"
    fi
    echo $command
    eval $command
}

ex_csfastq(){
    if test $build = "scer"; then
	index=$Ddir/bowtie-indexes/S_cerevisiae-cs
    elif test $build = "pombe"; then
	index=$Ddir/bowtie-indexes/S_pombe-cs
    else
	index=$Ddir/bowtie-indexes/$db-$build-cs
    fi
    
    if [[ $fastq = *.gz ]]; then
	command="bowtie -S -C $index <(zcat $fastq) $param --chunkmbs 2048 -p12 | samtools view -bS - | samtools sort > $file"
    else 
	command="bowtie -S -C $index $fastq $param --chunkmbs 2048 -p12 | samtools view -bS - | samtools sort > $file"
    fi 
    echo $command
    eval $command
}

log=log/bowtie-$prefix$post-$build
if test $type = "csfasta"; then  ex_csfasta >& $log; 
elif test $type = "csfastq"; then  ex_csfastq >& $log;
else ex_hiseq >& $log
fi

