#!/bin/bash

if test $# -ne 6; then
    echo "star.sh <single|paired> <output prefix> <fastq> <Ensembl|UCSC> <build>  <--forward-prob [0-1]>"
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

index_star=/home/Database/rsem-star-indexes/$db-$build
index_rsem=/home/Database/rsem-star-indexes/$db-$build/$db-$build

#paramENCODE="--outSAMunmapped Within --outFilterType BySJout --outSAMattributes NH HI AS NM MD --outFilterMultimapNmax 20 --outFilterMismatchNmax 999 --outFilterMismatchNoverReadLmax 0.04 --alignIntronMin 20 --alignIntronMax 1000000 --alignMatesGapMax 1000000 --alignSJoverhangMin 8 --alignSJDBoverhangMin 1 --sjdbScore 1" # --genomeLoad LoadAndKeep --limitBAMsortRAM 10000000000
#paramENCODEmeta="--outSAMheaderCommentFile commentsENCODElong.txt --outSAMheaderHD @HD VN:1.4 SO:coordinate"

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

parSTAR="--genomeLoad NoSharedMemory --outSAMtype BAM SortedByCoordinate --quantMode TranscriptomeSAM --runThreadN 12"
STAR $parSTAR $pzip --genomeDir $index_star --readFilesIn $fastq $parstr --outFileNamePrefix $odir/$prefix.
log=log/star-$prefix-$build
echo -en "$prefix\t" > $log
parse_starlog.pl $odir/$prefix.Log.final.out >> $log

rsem-calculate-expression $pair --alignments --estimate-rspd --forward-prob $prob --calc-ci --no-bam-output --seed 12345 -p 12 --ci-memory 30000 $odir/${prefix}.Aligned.toTranscriptome.out.bam $index_rsem $odir/$prefix

wigdir=bedGraph
if test ! -e $odir/$wigdir; then mkdir $odir/$wigdir; fi
STAR --runMode inputAlignmentsFromBAM --runThreadN 12 --inputBAMfile $odir/${prefix}.Aligned.sortedByCoord.out.bam --outWigType bedGraph $parWig --outFileNamePrefix $odir/$wigdir/$prefix --outWigReferencesPrefix chr
