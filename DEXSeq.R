flattenedFile = "Homo_sapiens.GRCh38.83.chr.gff"
sampleTable = data.frame(
    row.names = c("WT1-1","WT1-2","WT1-3","WT2-1","WT2-2","WT2-3","WT3-2","WT3-3","WT4-1","WT4-2","WT4-3",
                  "CDLS1-1", "CDLS1-2", "CDLS1-3", "CDLS2-1", "CDLS2-2", "CDLS2-3", "CDLS3-1", "CDLS3-2", "CDLS3-3"),
    condition = c(rep("WT", 11), rep("CDLS", 9))
#    libType = c(rep("paired-end",20))
)
sampleTable
countFiles = paste("bam/", rownames(sampleTable), ".homo_sapiens.Aligned.sortedByCoord.out.fb.txt", sep="")

library("DEXSeq")
library("BiocParallel")
BPPARAM <- MulticoreParam(workers = 8)

dxd = DEXSeqDataSetFromHTSeq(countFiles, sampleData=sampleTable, 
                             design=~ sample + exon + condition:exon,
                             flattenedfile=flattenedFile )
genesForSubset = read.table("geneIDsinsubset.txt", stringsAsFactors=FALSE)[[1]]

split(seq_len(ncol(dxd)), colData(dxd)$exon)
head( featureCounts(dxd), 5)
head( rowRanges(dxd), 3 )

#standard annotation
sampleAnnotation( dxd )
dxd = estimateSizeFactors( dxd ) # Total read normalization
dxd = estimateDispersions( dxd, BPPARAM=BPPARAM) # dispersionを推定
plotDispEsts( dxd )  # dispersion plot

dxd = testForDEU( dxd, BPPARAM=BPPARAM ) # for each exon
dxd = estimateExonFoldChanges( dxd, fitExpToVar="condition", BPPARAM=BPPARAM)  # fold change
dxr1 = DEXSeqResults( dxd )  # summary
dxr1
mcols(dxr1)$description    # 各列の説明
table ( dxr1$padj < 0.1 )  # FDR<0.1のexonx
table ( tapply( dxr1$padj < 0.1, dxr1$groupID, any ) )
plotMA( dxr1, cex=0.8 )    # FDR<0.1が赤

#Additional technical or experimental variables (single vs. pair など他の条件を考慮したい場合)
sampleAnnotation(dxd)
formulaFullModel = ~ sample + exon + libType:exon + condition:exon
formulaReducedModel = ~ sample + exon + libType:exon
dxd = estimateDispersions( dxd, formula = formulaFullModel, BPPARAM=BPPARAM )  # dispersionを推定
dxd = testForDEU( dxd, reducedModel = formulaReducedModel, fullModel = formulaFullModel, BPPARAM=BPPARAM)  # for each exon
dxr2 = DEXSeqResults( dxd ) # summary
table( dxr2$padj < 0.1 )
table( before = dxr1$padj < 0.1, now = dxr2$padj < 0.1 )

#visualization
gid <- "ENSG00000164190"
plotDEXSeq( dxr2, gid, legend=TRUE, cex.axis=1.2, cex=1.3, lwd=2 )  # conditionごとの平均plot
plotDEXSeq( dxr2, gid, displayTranscripts=TRUE, legend=TRUE, cex.axis=1.2, cex=1.3, lwd=2 )  # show all transcripts
plotDEXSeq( dxr2, gid, expression=FALSE, norCounts=TRUE, legend=TRUE, cex.axis=1.2, cex=1.3, lwd=2 )  # total read normalization
plotDEXSeq( dxr2, gid, expression=FALSE, splicing=TRUE, legend=TRUE, cex.axis=1.2, cex=1.3, lwd=2 )  # 遺伝子全体の差をキャンセルしたplot (splicingの差だけに特化)

DEXSeqHTML(dxr2, FDR=0.1, color=c("#FF000080", "#0000FF80"))
