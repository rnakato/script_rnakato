#! /usr/bin/env python
# -*- coding: utf-8 -*-

import sys
assert sys.version_info[:2] >= ( 2, 4 )
import pysam

def __main__():
    inputfile = "/home/rnakato/git/DROMPAplus/random_ATrich_10mil-v0-m1-hg38.sort.bam"
#    inputfile = sys.argv[1]
    bamfile = pysam.AlignmentFile(inputfile, "rb")
    for read in bamfile:
        print(read.reference)
    bamfile.close()
