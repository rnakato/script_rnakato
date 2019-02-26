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


To be continued
