## Scripts for NGS analysis
---
### combine_lines_from2files.pl
Merge rows of two files for overlapping rows (the column1 of file1 are overlapping the column2 in file2)

     combine_lines_from2files.pl -1 <file1> -2 <file2> -a <column1> -b <column2>

### plotRatioOfTwoUniqfiles.py
plot bargraph of ratio between two files output by uniq command

    plotRatioOfTwoUniqfiles.py [-h] [--threshold THRESHOLD] [--sizex SIZEX]
                                    [--sizey SIZEY] [--png]
                                    numerator denominator output

### rGREAT.R
R script to utilize rGREAT

     Rscript rGREAT.R <bed> <output prefix>

