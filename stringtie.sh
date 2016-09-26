build=hg38
Ddir=/home/Database
index_hisat2=$Ddir/hisat2-indexes/UCSC-$build
gtf=$Ddir/UCSC/$build/refFlat.dupremoved.gtf
fq1=data/IHEC12_R1.fastq.gz
fq2=data/IHEC12_R2.fastq.gz

prefix=IHEC12
hisat2 -p 12 --dta -x $index_hisat2 --rna-strandness RF --novel-splicesite-outfile novelsplice.txt -1 $fq1 -2 $fq2 | samtools view -bS - | samtools sort - hisat2/$prefix.sort
stringtie hisat2/$prefix.sort.bam -p 12 -G $gtf -e -o hisat2/$prefix-stringtie.gtf -B -A hisat2/$prefix-stringtie.abund.tab -C hisat2/$prefix-stringtie.cov

#-f 0.1
# Sets the minimum isoform abundance of the predicted transcripts as a fraction of the most abundant transcript assembled at a given locus.
# Lower abundance transcripts are often artifacts of incompletely spliced precursors of processed transcripts. 