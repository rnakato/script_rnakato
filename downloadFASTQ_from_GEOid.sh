#!/bin/bash

GEOid=$1

#acc=$(GSE=$GEOid; curl -fsSL "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=$GSE" | grep -oE 'PRJNA[0-9]+' | sort -u)

prefix=$(echo "$GEOid" | sed -E 's/[0-9]{1,3}$/nnn/')
acc=$(curl -fsSL \
  "https://ftp.ncbi.nlm.nih.gov/geo/series/$prefix/$GEOid/soft/${GEOid}_family.soft.gz" | gzip -dc | grep -oE 'PRJNA[0-9]+' | sort -u)

download_accession.sh $acc
downloadFASTQ_by_assay.sh metadata/$acc.SRR.txt
