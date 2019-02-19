args <- commandArgs(trailingOnly=TRUE)
inputfile <- args[1]
output <- args[2]

library(rGREAT)
bed = inputfile
job = submitGreatJob(bed, species = "hg19", version = 3.0)
tb = getEnrichmentTables(job, ontology = c("GO Biological Process"))
write.table(tb[[1]], file=paste(output, ".tsv", sep=""), quote=F, sep = "\t",row.names = F, col.names = T)

pdf(paste(output, ".pdf", sep=""), height=7, width=3)
par(mfrow = c(1, 3))
res = plotRegionGeneAssociationGraphs(job)
dev.off()

