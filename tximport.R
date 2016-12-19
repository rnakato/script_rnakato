library(tximport)
library(readr)

library(EnsDb.Hsapiens.v86)
edb <- EnsDb.Hsapiens.v86
organism(edb)
Tx <- transcripts(edb, filter = list(GenenameFilter("BCL2L11")))
Tx

library(TxDb.Hsapiens.UCSC.hg19.knownGene)
txdb <- TxDb.Hsapiens.UCSC.hg19.knownGene
k <- keys(txdb, keytype="GENEID")
df <- select(txdb, keys=k, keytype="GENEID", columns="TXNAME")
tx2gene <- df[,2:1] # tx ID, then gene ID

library(TxDb.Hsapiens.UCSC.hg38.knownGene)
txdb <- TxDb.Hsapiens.UCSC.hg38.knownGene
k <- keys(txdb, keytype="GENEID")
df <- select(txdb, keys=k, keytype="GENEID", columns="TXNAME")
tx2gene <- df[,2:1] # tx ID, then gene ID

tx2gene <- data.frame(TXNAME=Tx$tx_name, GENEID=Tx$gene_name)

files <- file.path("salmon", dir("salmon"), "quant.sf")
txi.salmon <- tximport(files, type="salmon", tx2gene=tx2gene, reader=read_tsv)
