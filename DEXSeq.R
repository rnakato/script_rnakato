print.usage <- function() {
	cat('\nUsage: Rscript DEXSeq.R <options>\n',file=stderr())
	cat('   MANDATORY ARGUMENTS\n',file=stderr())
	cat('      -i=<input file>       , input file (ht.txt, separated by \',\') \n',file=stderr())
	cat('      -t=<gff file>         , gene annotation (gff format)\n',file=stderr())
	cat('      -name=<name1>:<name2> , name of each group \n',file=stderr())
	cat('      -num=<num1>:<num2>    , num of replicates for each group \n',file=stderr())
	cat('   OUTPUT ARGUMENTS\n',file=stderr())
	cat('      -o=<output> , prefix of output file \n',file=stderr())
	cat('\n',file=stderr())
}

args <- commandArgs(trailingOnly = T)

nargs = length(args);
nargs
minargs = 5;
maxargs = 6;
if (nargs < minargs | nargs > maxargs) {
	print.usage()
	q(save="no",status=1)
}

for (each.arg in args) {
    if (grepl('^-i=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            sep.vals <- arg.split[2]
            files <- strsplit(sep.vals,',',fixed=TRUE)[[1]]
        }
        else { stop('No gff file name provided for parameter -i=')}
    }
    else if (grepl('^-t=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            flattenedFile <- arg.split[2]
        }
        else { stop('No gff file provided for parameter -t=')}
    }
    else if (grepl('^-num=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            sep.vals <- arg.split[2]
            sep.vals.split <- strsplit(sep.vals,':',fixed=TRUE)[[1]]     
            if (length(sep.vals.split) != 2) {
                stop('number must be specified as -num=<num1>:<num2>')                    
            } else {
                num1 <- as.numeric(sep.vals.split[1])
                num2 <- as.numeric(sep.vals.split[2])
            }      
        }
        else { stop('No value provided for parameter -n=')}
    }
    else if (grepl('^-name=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            sep.vals <- arg.split[2]
            sep.vals.split <- strsplit(sep.vals,':',fixed=TRUE)[[1]]     
            if (length(sep.vals.split) != 2) {
                stop('names must be specified as -name=<name1>:<name2>')                    
            } else {
                name1 <- sep.vals.split[1]
                name2 <- sep.vals.split[2]
            }      
        }
        else { stop('No value provided for parameter -n=')}
    }
    else if (grepl('^-o=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) { output <- arg.split[2] }
        else { stop('No output file name provided for parameter -o=')}
    }
    else if (grepl('^-l=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) { genelist <- arg.split[2] }
        else { stop('No output file name provided for parameter -o=')}
    }
}

files
name1
name2
num1
num2
flattenedFile
output
genelist

numtotal <- num1 + num2

sampleTable = data.frame(
    row.names = files,
    condition = c(rep(name1, num1), rep(name2, num2)),
    libType = c(rep("paired-end",numtotal))
)
sampleTable
countFiles = rownames(sampleTable)

library("DEXSeq")
library("BiocParallel")
#BPPARAM <- MulticoreParam(workers = 8)
BPPARAM <- SnowParam(workers = 12)

dxd = DEXSeqDataSetFromHTSeq(countFiles, sampleData=sampleTable, 
                             design=~ sample + exon + condition:exon,
                             flattenedfile=flattenedFile )

genesForSubset = read.table(genelist, stringsAsFactors=FALSE)[[1]]
dxd <- dxd[geneIDs(dxd) %in% genesForSubset,]

split(seq_len(ncol(dxd)), colData(dxd)$exon)
#head( featureCounts(dxd), 5)
#head( rowRanges(dxd), 3 )

#standard annotation
sampleAnnotation( dxd )
dxd = estimateSizeFactors( dxd ) # Total read normalization
dxd = estimateDispersions( dxd, BPPARAM=BPPARAM) # dispersionを推定

f <- paste(output, ".disp.png", sep="")
png(f, h=600, w=700, pointsize=20)
plotDispEsts( dxd )  # dispersion plot
dev.off()

dxd = testForDEU(dxd, BPPARAM=BPPARAM ) # for each exon

head  <- paste("log2fold_", name1, "_", name2, sep="")
s <- paste("na <- is.na(dxd@rowRanges$", head, ")", sep="")
eval(parse(text=s))

dxd@rowRanges$allZero[na] <- TRUE
dxd = estimateExonFoldChanges( dxd, fitExpToVar="condition", BPPARAM=BPPARAM)  # fold change
dxr1 = DEXSeqResults( dxd )  # summary
#dxr1
#mcols(dxr1)$description    # 各列の説明
table ( dxr1$padj < 0.1 )  # FDR<0.1のexon
table ( tapply( dxr1$padj < 0.1, dxr1$groupID, any ) )

f <- paste(output, ".MAplot.png", sep="")
png(f, h=600, w=700, pointsize=20)
plotMA( dxr1, cex=0.8 )    # FDR<0.1が赤
dev.off()

DEXSeqHTML(dxr1, path=paste(output, ".DEXSeqReport", sep=""), FDR=0.1, color=c("#FF000080", "#0000FF80"))

save(list=ls(), file=paste(output, ".all.Rdata", sep=""))

q(save="no",status=1)

load("all.Rdata")
library("DEXSeq")
library("BiocParallel")

#visualization
gid <- "ENSG00000164190"
plotDEXSeq( dxr1, gid, displayTranscripts=TRUE, splicing=TRUE, legend=TRUE, cex.axis=1.2, cex=1.3, lwd=2 )  # show all transcripts
#plotDEXSeq( dxr1, gid, expression=FALSE, norCounts=TRUE, legend=TRUE, cex.axis=1.2, cex=1.3, lwd=2 )  # total read normalization
#plotDEXSeq( dxr1, gid, expression=FALSE, splicing=TRUE, legend=TRUE, cex.axis=1.2, cex=1.3, lwd=2 )  # 遺伝子全体の差をキャンセルしたplot (splicingの差だけに特化)

#Additional technical or experimental variables (single vs. pair など他の条件を考慮したい場合)
sampleAnnotation(dxd)
formulaFullModel = ~ sample + exon + libType:exon + condition:exon
formulaReducedModel = ~ sample + exon + libType:exon
dxd = estimateDispersions( dxd, formula = formulaFullModel, BPPARAM=BPPARAM )  # dispersionを推定
dxd = testForDEU( dxd, reducedModel = formulaReducedModel, fullModel = formulaFullModel, BPPARAM=BPPARAM)  # for each exon
dxr2 = DEXSeqResults( dxd ) # summary
table( dxr2$padj < 0.1 )
table( before = dxr1$padj < 0.1, now = dxr2$padj < 0.1 )
