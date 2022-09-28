#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname" '[Options] <fastq> <prefix> <build>' 1>&2
    echo ' Options:' 1>&2
    echo '    -B: output as BAM format (defalt: CRAM)' 1>&2
    echo '    -d: output directory of map files (default: cram)' 1>&2
    echo '    -p "bowtie2 param": parameter of bowtie2 (shouled be quated)' 1>&2
    echo "  Example:" 1>&2
    echo "  For single-end: $cmdname -p \"--very-sensitive\" chip.fastq.gz chip hg38" 1>&2
    echo "  For paired-end: $cmdname \"\-1 chip_1.fastq.gz \-2 chip_2.fastq.gz\" chip hg38" 1>&2
}

echo $cmdname $*

format=CRAM
type=hiseq
bamdir=cram
db=UCSC
param=""
while getopts Bd:p: option
do
    case ${option} in
        B) format=BAM
           bamdir=bam
           ;;
	d)
	    bamdir=${OPTARG}
	    ;;
        p)
            param=${OPTARG}
            ;;
	*)
	    usage
	    exit 1
	    ;;
    esac
done
shift $((OPTIND - 1))

if [ $# -ne 3 ]; then
  usage
  exit 1
fi

fastq=$1
prefix=$2
build=$3
post="-bowtie2"`echo $param | tr -d ' '`

if test ! -e $bamdir; then mkdir $bamdir; fi
if test ! -e log; then mkdir log; fi

Ddir=`database.sh`
bowtie2="bowtie2"
if test $format = "BAM"; then
    file=$bamdir/$prefix$post-$build.sort.bam
else
    file=$bamdir/$prefix$post-$build.sort.cram
fi

if test -e "$file" && test 1000 -lt `wc -c < $file` ; then
    echo "$file already exist. quit"
    exit 0
fi

ex(){ echo $1; eval $1; }

ex_hiseq(){
    if test $build = "scer"; then
	index=$Ddir/bowtie2-indexes/S_cerevisiae
    elif test $build = "pombe"; then
	index=$Ddir/bowtie2-indexes/S_pombe
    else
	index=$Ddir/bowtie2-indexes/$db-$build
    fi
    genome=$index.fa

    $bowtie2 --version

    if test $format = "BAM"; then
        ex "bowtie2 $param -p12 -x $index \"$fastq\" | samtools sort > $file"
        if test ! -e $file.bai; then samtools index $file; fi
    else
        ex "bowtie2 $param -p12 -x $index \"$fastq\" | samtools view -C - -T $genome | samtools sort -O cram > $file"
        if test ! -e $file.crai; then samtools index $file; fi
    fi
}

log=log/bowtie2-$prefix$post-$build
ex_hiseq >& $log
