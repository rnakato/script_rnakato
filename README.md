## Scripts for NGS analysis

### combine_lines_from2files.pl 
Merge rows of two files for overlapping rows (the column1 of file1 are overlapping the column2 in file2)

     combine_lines_from2files.pl <file1> <file2> <column1> <column2>

### plotRatioOfTwoUniqfiles.py
plot bargraph of ratio between two files output by uniq command

    plotRatioOfTwoUniqfiles.py [-h] [--threshold THRESHOLD] [--sizex SIZEX]
                                    [--sizey SIZEY] [--png]
                                    numerator denominator output

### rGREAT.R
R script to utilize rGREAT

     Rscript rGREAT.R <bed> <output prefix>


## mapping_QC.sh: ChIP-seq analysis
Usage:

    mapping_QC.sh [-s] [-e] [-a] [-d bamdir] <exec|stats> <fastq> <prefix> <bowtie param> <build>

### Example

#### Execute bowtie and parse2wig

    mapping_QC.sh exec fastq/SRR20753.fastq Rad21 "-n2 -m1" hg38

Output:
* mapfile (bam/Rad21-n2-m1-hg38.sort.bam)

* parse2wig output (parse2wigdir/Rad21-n2-m1-hg38-*)

* output by SSP (with option option)
 sspout/Rad21-n2-m1-hg38.*

* bowtie log (log/bowtie-Rad21-hg38)

* parse2wig log (log/parsestats-Rad21-n2-m1-hg38)


#### Check mapping stats:

    mapping_QC.sh stats fastq/SRR20753.fastq Rad21 "-n2 -m1" hg38

||Sample	reads	|mapped unique	|%	|mapped >= 2	|%	|mapped total	|%	|unmapped	|%	|Nonredundant	|Redundant	|Complexity for10M	|Read depth	|Genome coverage	|Tested_reads	|GC summit	|NSC	|RSC	|Qtag|
----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----
|CTCF |	59,677,529	|47,893,926	|80.25	|10,056,318	|16.85	|57,950,244	|97.11	|1,727,285	|2.89	|19856031 (41.5%)	|28037895 (58.5%)	|0.732	|1.11	|0.99	|7,320,051 / 9,995,223|	43	|1.131071|	1.729936|	2|
|Rad21	|33,035,083	|9,543,103	|28.89	|3,975,423	|12.03	|13,518,526	|40.92	|19,516,557	|59.08	|8321928 (87.2%)	|1221175 (12.8%)|(0.872)	|0.46	|0.99	|8,321,928 / 9,543,103	|50	|1.162648	|0.9433482	|0|


#### For multiple gzipped fastq files:

      dir=fastq/
      build=hg38
      for prefix in `ls $dir/*fastq.gz | sed -e 's/'$dir'\/'//g -e 's/.fastq.gz//g'`
      do
          fastqc.sh $prefix                                                      
          mapping_QC.sh -a exec $dir/$prefix.fastq $prefix "-n2 -m1" $build
          mapping_QC.sh -a stats $dir/$prefix.fastq $prefix "-n2 -m1" $build         
      done

To be continued
