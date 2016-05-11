#!/bin/bash

if test $# -ne 5; then
    echo "star.sh <output prefix> <fastq> <Ensembl|UCSC> <build>  <--forward-prob [0-1]>"
    exit 0
fi

prefix=$1
fastq=$2
db=$3
build=$4
prob=$5

if test ! -e log; then mkdir log; fi
if test ! -e rsem; then mkdir rsem; fi

index_star=/home/Database/rsem-star-indexes/$db-$build
index_rsem=/home/Database/rsem-star-indexes/$db-$build/$db-$build

paramENCODE="--outSAMunmapped Within --outFilterType BySJout --outSAMattributes NH HI AS NM MD --outFilterMultimapNmax 20 --outFilterMismatchNmax 999 --outFilterMismatchNoverReadLmax 0.04 --alignIntronMin 20 --alignIntronMax 1000000 --alignMatesGapMax 1000000 --alignSJoverhangMin 8 --alignSJDBoverhangMin 1 --sjdbScore 1" # --genomeLoad LoadAndKeep --limitBAMsortRAM 10000000000
paramENCODEmeta="--outSAMheaderCommentFile commentsENCODElong.txt --outSAMheaderHD @HD VN:1.4 SO:coordinate"

paramTr="--outSAMtype BAM SortedByCoordinate --quantMode TranscriptomeSAM"

if test $prob = "0.5"; then  # unstraned
    parstr="--outSAMstrandField intronMotif"
    parWig="--outWigStrand Unstranded"
else          # stranded
    parWig="--outWigStrand Stranded"
fi

if [ "`echo $fastq | grep '.gz'`" ] ; then
    pzip="--readFilesCommand zcat"
fi

STAR --genomeLoad NoSharedMemory $paramTr $pzip --runThreadN 12 --genomeDir $index_star --readFilesIn $fastq $parstr --outFileNamePrefix rsem/$prefix.
rsem-calculate-expression --bam --estimate-rspd --forward-prob $prob --calc-ci --no-bam-output --seed 12345 -p 12 --ci-memory 30000 rsem/${prefix}.Aligned.toTranscriptome.out.bam $index_rsem rsem/$prefix

parWig_stranded="--outWigStrand Stranded"
parWig_unstranded="--outWigStrand Unstranded"
STAR --runMode inputAlignmentsFromBAM --inputBAMfile rsem/${prefix}.Aligned.sortedByCoord.out.bam --outWigType bedGraph $parWig --outFileNamePrefix rsem/Signal/$prefix --outWigReferencesPrefix chr

log=log/rsem-$prefix-$build
#echo -en "$prefix\t" > $log
#parse_rsem_cnt.pl rsem/$prefix-$build.stat/$prefix-$build.cnt | grep -v Sequenced >> $log
