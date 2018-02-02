library(tximport)
library(GenomicFeatures)

args <- commandArgs(trailingOnly=TRUE)
output <- args[1]
gtf <- args[2]
files <- args[3:length(args)]

output
gtf
files

txdb <- makeTxDbFromGFF(gtf)
k <- keys(txdb, keytype = "GENEID")
df <- select(txdb, keys = k, keytype = "GENEID", columns = "TXNAME")
tx2gene <- df[, 2:1]
#head(tx2gene)

#names(files) <- gsub("kallisto/|/abundance.tsv","",files)
txi.kallisto <- tximport(files, type = "kallisto", tx2gene = tx2gene, ignoreTxVersion=TRUE)

#head(txi.kallisto$counts)
#names(txi.kallisto)

write.table(txi.kallisto$counts, file=paste(output, ".csv", sep=""), quote=F, sep = "\t", row.names = T, col.names = F)
