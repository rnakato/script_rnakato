print.usage <- function() {
	cat('\nUsage: Rscript edgeR.R <options>\n',file=stderr())
	cat('   MANDATORY ARGUMENTS\n',file=stderr())
	cat('      -i=<input file>  , input file (RSEM gene/transcript file, estimated count) \n',file=stderr())
	cat('      -n=<num1>:<num2>:<num3>, num of replicates for each group \n',file=stderr())
	cat('   OPTIONAL ARGUMENTS\n',file=stderr())
	cat('      -nrowname=<int> , row name (default: 1) \n',file=stderr())
	cat('      -gname=<name1>:<name2>:<num3> , name of each group \n',file=stderr())
	cat('      -p=<float>      , threshold for FDR (default: 0.01) \n',file=stderr())
	cat('   OUTPUT ARGUMENTS\n',file=stderr())
	cat('      -o=<output> , prefix of output file \n',file=stderr())
	cat('\n',file=stderr())
}

args <- commandArgs(trailingOnly = T) 
nargs = length(args);
minargs = 1;
maxargs = 7;
if (nargs < minargs | nargs > maxargs) {
	print.usage()
	q(save="no",status=1)
}

gname1 <- "groupA"
gname2 <- "groupB"
gname3 <- "groupC"
p <- 0.01
nrowname <- 1

for (each.arg in args) {
    if (grepl('^-i=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            filename <- arg.split[2]
        }
        else { stop('No input file name provided for parameter -i=')}
    }
    else if (grepl('^-n=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            sep.vals <- arg.split[2]
            sep.vals.split <- strsplit(sep.vals,':',fixed=TRUE)[[1]]     
            if (length(sep.vals.split) != 3) {
                stop('must be specified as -n=<num1>:<num2>:<num3>')                    
            } else {
                if (any(is.na(as.numeric(sep.vals.split)))) { # check that sep vals are numeric
                    stop('must be numeric values')
                }
                num1 <- as.numeric(sep.vals.split[1])
                num2 <- as.numeric(sep.vals.split[2])
 		num3 <- as.numeric(sep.vals.split[3])
            }      				
        }
        else { stop('No value provided for parameter -n=')}
    }
    else if (grepl('^-gname=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            sep.vals <- arg.split[2]
            sep.vals.split <- strsplit(sep.vals,':',fixed=TRUE)[[1]]     
            if (length(sep.vals.split) != 3) {
                stop('must be specified as -gname=<gname1>:<gname2>:<gname3>')                    
            } else {
                gname1 <- sep.vals.split[1]
                gname2 <- sep.vals.split[2]
                gname3 <- sep.vals.split[3]
            }      
        }
        else { stop('No value provided for parameter -gname=')}
    }
    else if (grepl('^-nrowname=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            nrowname <- as.numeric(arg.split[2])
        }
        else { stop('No value provided for parameter -nrowname=')}
    }
    else if (grepl('^-p=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            p <- as.numeric(arg.split[2])
        }
        else { stop('No value provided for parameter -p=')}
    }
    else if (grepl('^-o=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) { output <- arg.split[2] }
        else { stop('No output file name provided for parameter -o=')}
    }
}

filename
nrowname
p
output

group <- data.frame(group = factor(c(rep(gname1,num1),rep(gname2,num2),rep(gname3,num3))))

# filename <- "Matrix.ALL.isoforms.count.GRCh38.txt"
#num1 <- 4
#num2 <- 2
                                        #num3 <- 4
#gname1 <- "Normal"
#    gname2 <-"CdLS"
#        gname3 <- "CHOPS"
#p <- 0.01
#nrowname <- 2
# group <- data.frame(group = factor(c(rep("Normal",4),rep("CdLS",2),rep("CHOPS",4))))
# data <- read.table(filename, header=T, row.names=2, sep="\t")
# data <- data[,-1]

### read data
cat('\nread in', filename, '\n',file=stdout())
if(nrowname==2){
    data <- read.table(filename, header=T, row.names=nrowname, sep="\t")
    data <- data[,-1]
}else{
    data <- read.table(filename, header=T, row.names=nrowname, sep="\t")
}
counts <- as.matrix(data)
counts <- floor(counts) # DESeq2は整数しか受け付けない
counts <- subset(counts,rowSums(counts[,1:num1])>1) # 値が1より大きいものだけ残す
counts <- subset(counts,rowSums(counts[,(num1+1):(num1+num2)])>1) # 値が1より大きいものだけ残す
counts <- subset(counts,rowSums(counts[,(num1+num2+1):(num1+num2+num3)])>1) # 値が1より大きいものだけ残す

library(DESeq2)
library(ggplot2)
# データ読み込みとDEGs計算
dds <- DESeqDataSetFromMatrix(countData = counts, colData = group, design = ~ group)
dds <- DESeq(dds)
# 結果の抽出
res.A.B <- results(dds, contrast=c("group",gname1,gname2), alpha = p)
res.A.C <- results(dds, contrast=c("group",gname1,gname3), alpha = p)
head(res.A.B)
head(res.A.C)
# 結果表示
summary(res.A.B)
summary(res.A.C)

## ----log+1よりも頑健な補正法
vsd <- varianceStabilizingTransformation(dds)  #　これを推奨
vsdMat <- assay(vsd)
res <- transform(exp=vsdMat, res.A.B)

sigA.B <- res.A.B$padj < p
sigA.C <- res.A.C$padj < p
sigA.B[is.na(sigA.B)] <- FALSE
sigA.C[is.na(sigA.C)] <- FALSE
sigA.Bup <- sigA.B & res.A.B$log2FoldChange > 0
sigA.Bdown <- sigA.B & res.A.B$log2FoldChange < 0
sigA.Cup <- sigA.C & res.A.C$log2FoldChange > 0
sigA.Cdown <- sigA.C & res.A.C$log2FoldChange < 0

drawVenn <- function(num1, num2, numshare, str) {
    library(VennDiagram)
    png(paste(output, ".Venn.", str, ".png", sep=""), height=400, width=400)
    draw.pairwise.venn(area1=num1, area2=num2, cross.area=numshare,
                       category=c(gname2,gname3), cat.pos=c(0,33), cat.dist=c(0.01,0.04),
                       fontfamily='Arial', cat.fontfamily='Arial', col=c(colors()[139], 'blue'),
                       alpha=0.5,fill=c(colors()[72],'blue') ,ext.pos=5)
    dev.off()
}

drawVenn(sum(sigA.B), sum(sigA.C), sum(sigA.B & sigA.C), "DEGs")
drawVenn(sum(sigA.Bup), sum(sigA.Cup), sum(sigA.Bup & sigA.Cup), "upDEGs")
drawVenn(sum(sigA.Bdown), sum(sigA.Cdown), sum(sigA.Bdown & sigA.Cdown), "downDEGs")

write.csv(res, file=paste(output, ".DESeq2multi.all.csv", sep=""), quote=F)
write.csv(res[sigA.B & sigA.C,], file=paste(output, ".DESeq2multi.bothDEGs.all.csv", sep=""), quote=F)
write.csv(res[sigA.Bup & sigA.Cup,], file=paste(output, ".DESeq2multi.bothDEGs.up.csv", sep=""), quote=F)
write.csv(res[sigA.Bdown & sigA.Cdown,], file=paste(output, ".DESeq2multi.bothDEGs.down.csv", sep=""), quote=F)

pdf(paste(output, ".DESeq2multi.FCScatter.pdf", sep=""), height=7, width=7)
smoothScatter(res.A.B$log2FoldChange, res.A.C$log2FoldChange, nrpoints = 500, xlab=paste("log2(", gname1, "/", gname2, ")", sep=""), ylab=paste("log2(", gname1, "/", gname3, ")", sep=""))
cc <- cor(res.A.B$log2FoldChange, res.A.C$log2FoldChange, method="spearman")
legend("bottomright", legend = paste("R = ", cc))
dev.off()

pdf(paste(output, ".DESeq2multi.MAplot.pdf", sep=""), height=7, width=7)
plotMA(res.A.B, main=paste(gname1, gname2, sep="-"), ylim=c(-2,2), alpha = p)
plotMA(res.A.C, main=paste(gname1, gname3, sep="-"), ylim=c(-2,2), alpha = p)
dev.off()

library(pheatmap)
plotTopDEGs <- function(res, str){
    # FDRでランキング
    resAndvsd <- transform(exp=assay(vsd), res)
    resOrdered <- resAndvsd[order(res$padj),]
    
    pdf(paste(output, ".DESeq2multi.topDEGs", ".", str, ".pdf", sep=""), height=16, width=12)
    par(mfrow=c(4,3))
    topDEGsid <- order(res$padj, decreasing=F)[1:12]
    for(i in topDEGsid) {
        plotCounts(dds, gene=i, intgroup="group")
    }
    dev.off()

    select <- order(res$padj, decreasing=F)[1:60]
    nt <- normTransform(dds) # log2(x+1)
    df <- as.data.frame(colData(dds)[,c("group","group")])
    pdf(paste(output, ".DESeq2multi.topDEGsHeatmap", ".", str, ".pdf", sep=""), height=7, width=7)
    pheatmap(assay(nt)[select,], cluster_rows=F, show_rownames=F, cluster_cols=F, annotation_col=df)
    pheatmap(vsdMat[select,], cluster_rows=F, show_rownames=F, cluster_cols=F, annotation_col=df)
dev.off()
}

plotTopDEGs(res.A.B, paste(gname1, gname2, sep="-"))
plotTopDEGs(res.A.C, paste(gname1, gname3, sep="-"))

# sample clustering
library("RColorBrewer")
sampleDists <- dist(t(vsdMat))
sampleDistMatrix <- as.matrix(sampleDists)
#rownames(sampleDistMatrix) <- paste(rld$condition, rld$type, sep="-")
colnames(sampleDistMatrix) <- NULL
colors <- colorRampPalette( rev(brewer.pal(9, "Blues")) )(255)
pdf(paste(output, ".DESeq2multi.sampleClustering.pdf", sep=""), height=7, width=8)
pheatmap(sampleDistMatrix, clustering_distance_rows=sampleDists, clustering_distance_cols=sampleDists, col=colors)
dev.off()

# PCA plot
pdf(paste(output, ".DESeq2multi.samplePCA.pdf", sep=""), height=7, width=7)
plotPCA(vsd, intgroup=c("group"))
dev.off()
