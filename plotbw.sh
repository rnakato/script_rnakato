gtf=/work/Database/Database_fromDocker/Referencedata_mm10/gtf_chrUCSC/chr.gtf
bws="bigwig/hsc.CPM.mapq10.bw bigwig/mac.CPM.mapq10.bw bigwig/lsec.CPM.mapq10.bw bigwig/chol.CPM.mapq10.bw"

for gene in NIPBL MYC Col1a1 Mmp2 Cd68 Trem2 Fabp4 Pcdh17 Epcam
do
python plotbw.py \
  --gene $gene \
  --gtf $gtf \
  --same-y \
  --shade-exons \
  --bigwigs $bws \
  --flank 5000 \
  --colors "#4d4d4d" "#d62728" "#1f77b4" "#2ca02c" \
  --out pdf/$gene.pdf
done
