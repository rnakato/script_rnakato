print.usage <- function() {
	cat('\nUsage: Rscript edgeR.R <options>\n',file=stderr())
	cat('   MANDATORY ARGUMENTS\n',file=stderr())
	cat('      -i=<input file>  , input file (RSEM gene/transcript file, estimated count) \n',file=stderr())
	cat('      -n=<num1>:<num2> , num of replicates for each group \n',file=stderr())
	cat('   OPTIONAL ARGUMENTS\n',file=stderr())
	cat('      -nrowname=<int> , row name (default: 1) \n',file=stderr())
	cat('      -gname=<name1>:<name2> , name of each group \n',file=stderr())
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
            if (length(sep.vals.split) != 2) {
                stop('must be specified as -n=<num1>:<num2>')                    
            } else {
                if (any(is.na(as.numeric(sep.vals.split)))) { # check that sep vals are numeric
                    stop('must be numeric values')
                }
                num1 <- as.numeric(sep.vals.split[1])
                num2 <- as.numeric(sep.vals.split[2])
            }      
        }
        else { stop('No value provided for parameter -n=')}
    }
    else if (grepl('^-gname=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            sep.vals <- arg.split[2]
            sep.vals.split <- strsplit(sep.vals,':',fixed=TRUE)[[1]]     
            if (length(sep.vals.split) != 2) {
                stop('must be specified as -gname=<num1>:<num2>')                    
            } else {
                gname1 <- sep.vals.split[1]
                gname2 <- sep.vals.split[2]
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
num1
num2
output

group <- data.frame(group = factor(c(rep(gname1,num1),rep(gname2,num2))))

# filename <- "Matrix.isoforms.count.GRCh38.txt"
# group <- data.frame(group = factor(c(rep("A",6),rep("B",6))))
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
counts <- subset(counts,rowSums(counts)>1) # 値が1より大きいものだけ残す

library(DESeq2)
library(ggplot2)
# データ読み込みとDEGs計算
dds <- DESeqDataSetFromMatrix(countData = counts, colData = group, design = ~ group)
dds <- DESeq(dds)
# 結果の抽出
res <- results(dds, alpha = p)
head(res)
# 結果表示
summary(res)
pdf(paste(output, ".DESeq2.MAplot.pdf", sep=""), height=7, width=7)
plotMA(res, main="MAplot", ylim=c(-2,2), alpha = p)
dev.off()

## ----log+1よりも頑健な補正法
#rld <- rlog(dds)
vsd <- varianceStabilizingTransformation(dds)  #　これを推奨
#vsd.fast <- vst(dds)                          #　vsdをサンプル抽出でこなす

#rlogMat <- assay(rld)
vsdMat <- assay(vsd)
#vsdfastMat <- assay(vsd.fast)

## vsd and log2 plot
#px     <- counts(dds)[,1] / sizeFactors(dds)[1]
#ord    <- order(px)
#ord    <- ord[px[ord] < 150]
#ord    <- ord[seq(1, length(ord), length=50)]
#last   <- ord[length(ord)]
#vstcol <- c("blue", "black")
#matplot(px[ord], cbind(assay(vsd)[,1], log2(px))[ord,], type="l", lty=1, col=vstcol, xlab="n", ylab="f(n)")
#legend("bottomright", legend = c(expression("variance stabilizing transformation"),expression(log[2](n/s[1]))), fill=vstcol)

# FDRでランキング

resAndvsd <- transform(exp=assay(vsd), res)
resOrdered <- resAndvsd[order(res$padj),]
#head(resOrdered)
# DEGの抽出(FDR < p)
resSig <- subset(resOrdered, padj < p)
#resSig
write.csv(resOrdered, file=paste(output, ".DESeq2.all.csv", sep=""), quote=F)
write.csv(resSig,     file=paste(output, ".DESeq2.DEGs.csv", sep=""), quote=F)
write.csv(resSig[resSig$log2FoldChange>0,], file=paste(output, ".DESeq2.upDEGs.csv", sep=""), quote=F)
write.csv(resSig[resSig$log2FoldChange<0,], file=paste(output, ".DESeq2.downDEGs.csv", sep=""), quote=F)

pdf(paste(output, ".topDEGs.pdf", sep=""), height=14, width=14)
par(mfrow=c(3,3))
topDEGsid <- order(res$padj, decreasing=F)[1:9]
for(i in topDEGsid) {
    plotCounts(dds, gene=i, intgroup="group")
#    d <- plotCounts(dds, gene=which.min(res$padj), intgroup="group", returnData=T)
#    ggplot(d, aes(x=group, y=count)) + geom_point(position=position_jitter(w=0.1,h=0)) + scale_y_log10(breaks=c(25,100,400))
}
dev.off()

## SD against mean
library("vsn")
pdf(paste(output, ".MeanVariance.pdf", sep=""), height=7, width=9)
par(mfrow=c(1,2))
meanSdPlot(log2(counts(dds,normalized=T) + 1))
#meanSdPlot(rlogMat)
meanSdPlot(vsdMat)
#meanSdPlot(vsdfastMat)
dev.off()

# heatmap of top20 highly-expressed genes
library(pheatmap)
select <- order(rowMeans(counts(dds,normalized=TRUE)), decreasing=TRUE)[1:20]

nt <- normTransform(dds) # log2(x+1)
df <- as.data.frame(colData(dds)[,c("group","group")])
pdf(paste(output, ".HighlyExpressedGenes.pdf", sep=""), height=7, width=7)
#par(mfrow=c(1,2))
pheatmap(assay(nt)[select,], cluster_rows=F, show_rownames=F, cluster_cols=F, annotation_col=df)
pheatmap(vsdMat[select,], cluster_rows=F, show_rownames=F, cluster_cols=F, annotation_col=df)
dev.off()

# sample clustering
library("RColorBrewer")
sampleDists <- dist(t(vsdMat))
sampleDistMatrix <- as.matrix(sampleDists)
#rownames(sampleDistMatrix) <- paste(rld$condition, rld$type, sep="-")
colnames(sampleDistMatrix) <- NULL
colors <- colorRampPalette( rev(brewer.pal(9, "Blues")) )(255)
pdf(paste(output, ".sampleClustering.pdf", sep=""), height=7, width=8)
pheatmap(sampleDistMatrix, clustering_distance_rows=sampleDists, clustering_distance_cols=sampleDists, col=colors)
dev.off()

# PCA plot
pdf(paste(output, ".samplePCA.pdf", sep=""), height=7, width=7)
plotPCA(vsd, intgroup=c("group"))
dev.off()

q("no")


# multifactor designs
#designの中の特定のtypeをcontrastにする（single-factor Wald test）
res.A.B <- results(dds, contrast=c("condition","A","B"))
res.A.C <- results(dds, contrast=c("condition","A","C"))
res.B.C <- results(dds, contrast=c("condition","B","C"))

head()
resOrdered <- res.A.B[order(res.A.B$padj),]

# one-way ANOVA (p-value indicates difference at least in one condition)
ddsLRT <- DESeq(dds, test="LRT", reduced= ~ 1)
resLRT <- results(ddsLRT)


# 多群間二因子比較
group <- data.frame(
  condition = factor(c(rep("K",6),rep("W",6))),
  day = factor(c(rep(c(0,2,7),4)))
)
model.matrix(~ group$con + group$day)

dds <- nbinomLRT(dds, full = ~ condition + day, reduced = ~ day)
res <- results(dds)
res
head(res[order(res$pvalue), ])

dds <- nbinomLRT(dds, full = ~ condition + day, reduced = ~ condition)
res <- results(dds)
res
head(res[order(res$pvalue), ])

dds <- estimateSizeFactors(dds)
dds <- estimateDispersions(dds)
res <- results(dds)

