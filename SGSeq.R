
## ----knitr, include=FALSE, cache=FALSE-----------------------------------
library(knitr)
opts_chunk$set(fig.align='center', fig.show='hold')

BiocStyle::latex()
library(SGSeq)
library(TxDb.Hsapiens.UCSC.hg19.knownGene)

path <- system.file("extdata", package = "SGSeq")
si$file_bam <- file.path(path, "bams", si$file_bam)


## ------------------------------------------------------------------------
txdb <- TxDb.Hsapiens.UCSC.hg19.knownGene
txdb <- keepSeqlevels(txdb, "chr16")
seqlevelsStyle(txdb) <- "NCBI"


## ------------------------------------------------------------------------
txf_annotated <- convertToTxFeatures(txdb)
txf_annotated <- txf_annotated[txf_annotated %over% gr]


## ------------------------------------------------------------------------
sgfc <- analyzeFeatures(si, features = txf_annotated)


## ----figure-1, fig.width=4.5, fig.height=4.5-----------------------------
df <- plotFeatures(sgfc, geneID = 1)
df


## ------------------------------------------------------------------------
sgfc <- analyzeFeatures(si, which = gr)


## ------------------------------------------------------------------------
sgfc <- annotate(sgfc, txf_annotated)


## ----figure-2, fig.width=4.5, fig.height=4.5-----------------------------
df <- plotFeatures(sgfc, geneID = 1, color_novel = "red")
df


## ------------------------------------------------------------------------
sgvc <- analyzeVariants(sgfc)


## ------------------------------------------------------------------------
mcols(sgvc)


## ----figure-3, fig.width=1.5, fig.height=4.5-----------------------------
plotVariants(sgvc, eventID = 1, color_novel = "red")


## ------------------------------------------------------------------------
txf <- predictTxFeatures(si, gr)
sgf <- convertToSGFeatures(txf)
sgf <- annotate(sgf, txf_annotated)
sgfc <- getSGFeatureCounts(si, sgf)
sgv <- findSGVariants(sgf)
sgvc <- getSGVariantCounts(sgv, sgfc)


## ----results="asis", echo=FALSE------------------------------------------
toLatex(sessionInfo())

