matrix <- commandArgs(trailingOnly=TRUE)[1]
bed <- commandArgs(trailingOnly=TRUE)[2]
odir <- commandArgs(trailingOnly=TRUE)[3]

cat('\n--HiTC analysis--\n', file=stdout())
cat('Matrix: ', matrix, '\n', file=stdout())
cat('Bed: ', bed, '\n', file=stdout())
cat('Output dir: ', odir, '\n\n', file=stdout())

library(HiTC)
hiC <-importC(matrix, xgi.bed=bed)
#detail(hiC$chr6chr6)

list <- c(hiC$chr1chr1,
	  hiC$chr2chr2,
	  hiC$chr3chr3,
	  hiC$chr4chr4,
	  hiC$chr5chr5,
	  hiC$chr6chr6,
	  hiC$chr7chr7,
	  hiC$chr8chr8,
	  hiC$chr9chr9,
	  hiC$chr10chr10,
	  hiC$chr11chr11,
	  hiC$chr12chr12,
	  hiC$chr13chr13,
	  hiC$chr14chr14,
	  hiC$chr15chr15,
	  hiC$chr16chr16,
	  hiC$chr17chr17, 
	  hiC$chr18chr18, 
	  hiC$chr19chr19,
	  hiC$chr20chr20, 
	  hiC$chr21chr21, 
	  hiC$chr22chr22, 
	  hiC$chrXchrX)

for (c in list) {
    pr <- pca.hic(c, npc=1, asGRangesList=TRUE)
    filename <- paste(odir, "/", c@xgi@seqinfo@seqnames, ".txt", sep="")
    write.table(pr, filename, quote=F, col.names=F, row.names=F, sep="\t")
}

#sset <- reduce(hiC, chr=c("chr5","chr6","chr7"))
#imr90_500 <- HTClist(mclapply(sset, binningC, binsize=500000, bin.adjust=FALSE, method="sum", step=1))
#mapC(imr90_500)
# mapC(hiC$chr1chr1)
# hox <- extractRegion(hiC$chr6chr6, chr="chr6", from=50e6, to=58e6)
# plot(hox, maxrange=50, col.pos=c("white", "orange", "red", "black"))
