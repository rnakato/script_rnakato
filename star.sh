#!/bin/bash

scriptname=${0##*/}
if test $# -ne 6; then
    echo "$scriptname <single|paired> <output prefix> <fastq> <Ensembl|UCSC> <build> <--forward-prob [0-1]>"
    exit 0
fi

readtype=$1
prefix=$2
fastq=$3
db=$4
build=$5
prob=$6

odir=star
if test ! -e log; then mkdir log; fi
if test ! -e $odir; then mkdir $odir; fi

if test $build = "S_pombe" -o $build = "S_cerevisiae"; then
    index_star=`database.sh`/rsem-star-indexes/$build
    index_rsem=`database.sh`/rsem-star-indexes/$build/$build
else
    index_star=`database.sh`/rsem-star-indexes/$db-$build
    index_rsem=`database.sh`/rsem-star-indexes/$db-$build/$db-$build
fi

if test $readtype = "paired"; then pair="--paired-end"; fi
if test $prob = "0.5"; then  # unstraned
    parstr="--outSAMstrandField intronMotif"
    parWig="--outWigStrand Unstranded"
else          # stranded
    parWig="--outWigStrand Stranded"
fi

if [ "`echo $fastq | grep '.gz'`" ] ; then
    pzip="--readFilesCommand zcat"
fi

STARdir=$(cd $(dirname $0) && pwd)/../STAR/bin/Linux_x86_64_static

$STARdir/STAR --genomeLoad NoSharedMemory --outSAMtype BAM SortedByCoordinate --quantMode TranscriptomeSAM \
    --runThreadN 12 --outSAMattributes All $pzip \
    --genomeDir $index_star --readFilesIn $fastq $parstr \
    --outFileNamePrefix $odir/$prefix.$build.

log=log/star-$prefix.$build.txt
echo -en "$prefix\t" > $log
parse_starlog.pl $odir/$prefix.$build.Log.final.out >> $log
#wigdir=bedGraph
#if test ! -e $odir/$wigdir; then mkdir $odir/$wigdir; fi
#$STARdir/STAR --runMode inputAlignmentsFromBAM --runThreadN 12 --inputBAMfile $odir/${prefix}.$build.Aligned.sortedByCoord.out.bam --outWigType bedGraph $parWig --outFileNamePrefix $odir/$wigdir/$prefix.$build --outWigReferencesPrefix chr

RSEMdir=$(cd $(dirname $0) && pwd)/../RSEM
$RSEMdir/rsem-calculate-expression $pair --alignments --estimate-rspd --forward-prob $prob --no-bam-output -p 12 $odir/${prefix}.$build.Aligned.toTranscriptome.out.bam $index_rsem $odir/$prefix.$build #--calc-ci --ci-memory 30000 --seed 12345
