#!/bin/bash

GEOid=$1

acc=$(GSE=$GEOid; curl -fsSL "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=$GSE" | grep -oE 'PRJNA[0-9]+' | sort -u)
download_accession.sh $acc
downloadFASTQ_by_assay.sh metadata/$acc.SRR.txt

