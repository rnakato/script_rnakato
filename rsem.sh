#!/bin/bash

if test $# -ne 6; then
    echo "rsem.sh <single|paired> <output prefix> <fastq> <Ensembl|UCSC> <build> <--forward-prob [0-1]>"
    exit 0
fi

readtype=$1
prefix=$2
fastq=$3
db=$4
build=$5
prob=$6

if test ! -e log; then mkdir log; fi
if test ! -e rsem; then mkdir rsem; fi

index=`database.sh`/rsem-star-indexes/$db-$build/$db-$build

if test $readtype = "paired"; then pair="--paired-end"; fi

if [ "`echo $fastq | grep '.gz'`" ] ; then
    pzip="--star-gzipped-read-file"
fi

rsem-calculate-expression --star $pzip $pair -p 12 --forward-prob $prob --calc-ci --star-output-genome-bam $fastq $index rsem/$prefix-$build  # --estimate-rspd

log=log/rsem-$prefix-$build
echo -en "$prefix\t" > $log
parse_rsem_cnt.pl rsem/$prefix-$build.stat/$prefix-$build.cnt | grep -v Sequenced >> $log


paramTr="--outSAMtype BAM SortedByCoordinate --quantMode TranscriptomeSAM"
par_unstranded="--outSAMstrandField intronMotif"


STAR $paramENCODE $paramENCODEmeta $paramTr --runThreadN $thread --genomeDir $index_star --readFilesIn $fastq $par_unstranded --outFileNamePrefix $dir/star/$prefix.
rsem-calculate-expression --bam --estimate-rspd --calc-ci --no-bam-output --seed 12345 -p $thread --ci-memory 30000 $dir/star/${prefix}.Aligned.toTranscriptome.out.bam $index_rsem_star $dir/star/rsem-$prefix


STAR $paramENCODE $paramENCODEmeta $paramTr --runThreadN $thread --genomeDir $index_star --readFilesIn $fq1 $fq2 $par_unstranded --outFileNamePrefix $dir/star/$prefix.
rsem-calculate-expression --bam --estimate-rspd --calc-ci --no-bam-output --seed 12345 --paired-end -p $thread --ci-memory 30000 $dir/star/$prefix.Aligned.toTranscriptome.out.bam $index_rsem_star $dir/star/rsem-$prefix


paramENCODE="--outSAMunmapped Within --outFilterType BySJout --outSAMattributes NH HI AS NM MD --outFilterMultimapNmax 20 --outFilterMismatchNmax 999 --outFilterMismatchNoverReadLmax 0.04 --alig\
nIntronMin 20 --alignIntronMax 1000000 --alignMatesGapMax 1000000 --alignSJoverhangMin 8 --alignSJDBoverhangMin 1 --sjdbScore 1" # --genomeLoad LoadAndKeep --limitBAMsortRAM 10000000000          
paramENCODEmeta="--outSAMheaderCommentFile commentsENCODElong.txt --outSAMheaderHD @HD VN:1.4 SO:coordinate"

paramTr="--outSAMtype BAM SortedByCoordinate --quantMode TranscriptomeSAM"
par_unstranded="--outSAMstrandField intronMotif"

outdir=star
fastq="data/WT1-1_R1.fq.gz data/WT1-1_R2.fq.gz"
#mkdir $outdir                                                                                                                                                                                     
#STAR $paramENCODE $paramENCODEmeta $paramTr --runThreadN 12 --genomeDir $STARgenomeDir --readFilesIn $fastq --outFileNamePrefix $outdir/                                                          
#STAR --runThreadN 12  --readFilesCommand zcat --genomeLoad NoSharedMemory --genomeDir $STARgenomeDir --readFilesIn $fastq --outFileNamePrefix $outdir/                                            
STAR --runThreadN 12  --readFilesCommand zcat --genomeLoad NoSharedMemory --genomeDir $STARgenomeDir --readFilesIn $fastq --outFileNamePrefix ${outdir}2pass/ --sjdbFileChrStartEnd star/SJ.out.ta\
b


#STAR --genomeDir `database.sh`/rsem-star-indexes/UCSC-hg19  --outSAMunmapped Within  --outFilterType BySJout  --outSAMattributes NH HI AS NM MD  --outFilterMultimapNmax 20  --outFilterMismatch\
Nmax 999  --outFilterMismatchNoverLmax 0.04  --alignIntronMin 20  --alignIntronMax 1000000  --alignMatesGapMax 1000000  --alignSJoverhangMin 8  --alignSJDBoverhangMin 1  --sjdbScore 1  --runThre\
adN 12  --genomeLoad NoSharedMemory  --outSAMtype BAM Unsorted  --quantMode TranscriptomeSAM  --outSAMheaderHD \@HD VN:1.4 SO:unsorted  --outFileNamePrefix test.temp/test  --readFilesIn data/WT1\
-1_R1.fq data/WT1-1_R2.fq                                                                                                                                                                          


parWig_stranded="--outWigStrand Stranded"
parWig_unstranded="--outWigStrand Unstranded"
#STAR --runMode inputAlignmentsFromBAM --inputBAMfile $outdir/Aligned.sortedByCoord.out.bam --outWigType bedGraph $parWig_stranded --outFileNamePrefix $outdir/Signal/ --outWigReferencesPrefix ch\
r                     
