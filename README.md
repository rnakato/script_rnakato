# script_rnakato
Scripts for NGS analysis

#### combine_lines_from2files.pl 
Merge rows of two files for overlapping rows (the column1 of file1 are overlapping the column2 in file2)

Usage:

     combine_lines_from2files.pl <file1> <file2> <column1> <column2>

#### plotRatioOfTwoUniqfiles.py
plot bargraph of ratio between two files output by uniq command

Usage:

    plotRatioOfTwoUniqfiles.py [-h] [--threshold THRESHOLD] [--sizex SIZEX]
                                    [--sizey SIZEY] [--png]
                                    numerator denominator output

#### rGREAT.R
R script to utilize rGREAT

Usage: 

     Rscript rGREAT.R <bed> <output prefix>


## ChIP-seq analysis
### mapping_QC.sh
#### Usage

      mapping_QC.sh [-s] [-e] [-a] [-d bamdir] <exec|stats> <fastq> <prefix> <bowtie param> <build>

for multiple fastq files:

      for prefix in `ls $dir/*fastq| sed -e 's/'$dir'\/'//g -e 's/.fastq//g'`
      do
          fastqc.sh $prefix                                                      
          mapping_QC.sh -a exec $dir/$prefix.fastq $prefix "-n2 -m1" $build
          mapping_QC.sh -a stats $dir/$prefix.fastq $prefix "-n2 -m1" $build         
      done

#### Example
Execute bowtie and parse2wig
      mapping_QC.sh exec fastq/SRR20753.fastq Rad21 "-n2 -m1" hg38

Output:
* mapfile (bam/Rad21-n2-m1-hg38.sort.bam)

* parse2wig output (parse2wigdir/Rad21-n2-m1-hg38-*)

* output by SSP (with option option)
 sspout/Rad21-n2-m1-hg38.*

* log
 log/bowtie-Rad21-hg38    # bowtie
 log/parsestats-Rad21-n2-m1-hg38  # parse2wig

Check stats:

    mapping_QC.sh stats $dir/$prefix.fastq $prefix "-n2 -m1" $build


||Sample	reads	|mapped unique	|%	|mapped >= 2	|%	|mapped total	|%	|unmapped	|%	|Nonredundant	|Redundant	|Complexity for10M	|Read depth	|Genome coverage	|Tested_reads	|GC summit	|NSC	|RSC	|Qtag|
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
|CTCF |	59,677,529	|47,893,926	|80.25	|10,056,318	|16.85	|57,950,244	|97.11	|1,727,285	|2.89	|19856031 (41.5%)	|28037895 (58.5%)	|0.732	|1.11	|0.99	|7,320,051 / 9,995,223|	43	|1.131071|	1.729936|	2|
|Rad21	|33,035,083	|9,543,103	|28.89	|3,975,423	|12.03	|13,518,526	|40.92	|19,516,557	|59.08	|8321928 (87.2%)	|1221175 (12.8%)|(0.872)	|0.46	|0.99	|8,321,928 / 9,543,103	|50	|1.162648	|0.9433482	|0|

## RNA-seq analysis
### star.sh: execute STAR
#### Usage

    star.sh <single|paired> <output prefix> <fastq> <Ensembl|UCSC> <build>  <--forward-prob [0-1]>

Output: 
* star/*Aligned.sortedByCoord.out.bam # mapfile for genome
* star/*.Aligned.toTranscriptome.out.bam  # mapfile for gene
* star/*.<genes|isoforms>.results  # gene expression data
* log/star-*.txt

|Sequenced	|Uniquely mapped|	(%)	|Mapped to multiple loci|	(%)|	Mapped to too many loci|	(%)|	Unmapped (too many mismatches)	|Unmapped (too short)	|Unmapped (other)	|chimeric reads|	(%)	|Splices total	|Annotated	|(%)	|Non-canonical	|(%)	|Mismatch rate per base (%)|	Deletion rate per base (%)	|Insertion rate per base (%)|
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
|29446992	|27430449	|93.15	|1012811	|3.44	|5253	|0.02	|0%|	3%	|0%	|0	|0	|18960488	|18725703	|98.76	|30590	|0.16	|0.19	|0.01	|0.01|

### Example

    for prefix in CDLS1 CDLS2 WT1 WT2; do
       star.sh paired $prefix "fastq/${prefix}_R1.fq.gz fastq/${prefix}_R2.fq.gz" Ensembl GRCh38 0
    done
    
    rsem_merge.sh "WT1 WT2 CDLS1 CDLS2" Matrix.CdLS Ensembl GRCh38 "2015_001"
    edgeR.sh Matrix.CdLS Ensembl GRCh38 2:2 0.05

### rsem_merge.sh: execute RSEM

    rsem_merge.sh <files> <output> <Ensembl|UCSC> <build> <strings for sed>

Output:
* gene expression data: *.<genes|isoforms>.<TPM|count>.<build>.txt
* merged xlsx: *.<build>.xlsx 


### edgeR.sh: execute edgeR for two groups

    edgeR.sh [-a] <Matrix> <Ensembl|UCSC> <build> <num of reps> <groupname>  <FDR>

Output
* merged xlsx: *.<genes|isoforms>.count.<build>.edgeR.xlsx
* BCV/MDS plot: *.<genes|isoforms>.count.<build>.BCV-MDS.pdf
* MA plot:  *.<genes|isoforms>.count.<build>.MAplot.pdf

* DEGのリストからは1kbpより短い遺伝子は除かれます。また、出力されるのはprotein_coding、antisense, lincRNAのみです。ALLには全て含まれます。
* DEGにこれらの遺伝子を含めたい場合は-aオプションを指定します。


To be continued
