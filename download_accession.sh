#!/bin/bash

cmdname=`basename $0`
function usage()
{
  echo "Usage: ${cmdname} <accession id>" 1>&2
  echo "  Example: ${cmdname} PRJNA1445099" 1>&2
}

# check arguments
if [ $# -ne 1 ]; then
  usage
  exit 1
fi

ex(){ echo $1; eval $1; }

acc=$1 #PRJNA1445099
ex "mkdir -p metadata"

ex "curl -L --fail --retry 5 --retry-delay 5 \
  \"https://www.ebi.ac.uk/ena/portal/api/filereport?accession=${acc}&result=read_run&fields=run_accession,study_accession,secondary_study_accession,experiment_accession,sample_accession,secondary_sample_accession,scientific_name,library_strategy,library_layout,read_count,base_count,fastq_ftp,sra_ftp&format=tsv&download=true\" \
  -o metadata/${acc}.ena.runinfo.tsv"

ex "tail -n +2 metadata/${acc}.ena.runinfo.tsv \
  | cut -f1,8,9 \
  | grep -E '^SRR' \
  > metadata/${acc}.SRR.txt"
