#!/bin/bash
for fastq in `ls *.fastq`; do gzip $fastq; done