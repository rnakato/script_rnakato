# edgeR.R
# =============
# Author: Ryuichiro Nakato
# Email: rnakato@iam.u-tokyo.ac.jp
# =============
# MANDATORY ARGUMENTS

print.usage <- function() {
	cat('\nUsage: Rscript edgeR.R <options>\n',file=stderr())
	cat('   MANDATORY ARGUMENTS\n',file=stderr())
	cat('      -i=<input file>  , input file (RSEM gene/transcript file, estimated count) \n',file=stderr())
	cat('      -n=<num1>:<num2> , num of replicates for each group \n',file=stderr())
	cat('   OPTIONAL ARGUMENTS\n',file=stderr())
	cat('      -nrowname=<int> , row name (default: 1) \n',file=stderr())
	cat('      -p=<float>      , threshold for FDR (default: 0.01) \n',file=stderr())
	cat('      -color=<color>  , heatmap color (blue|orange|purple|green , default: blue) \n',file=stderr())
	cat('   OUTPUT ARGUMENTS\n',file=stderr())
	cat('      -o=<output> , prefix of output file \n',file=stderr())
	cat('\n',file=stderr())
}

args <- commandArgs(trailingOnly = T) 
nargs = length(args);
minargs = 1;
maxargs = 6;
if (nargs < minargs | nargs > maxargs) {
	print.usage()
	q(save="no",status=1)
}

nrowname <- 1
p <- 0.01
color <- "blue"
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
                stop('Strand shift limits must be specified as -n=<num1>:<num2>')                    
            } else {
                if (any(is.na(as.numeric(sep.vals.split)))) { # check that sep vals are numeric
                    stop('Strand shift limits must be numeric values')
                }
                num1 <- as.numeric(sep.vals.split[1])
                num2 <- as.numeric(sep.vals.split[2])
            }      
        }
        else { stop('No value provided for parameter -n=')}
    }
    else if (grepl('^-color=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            color <- arg.split[2]
        }
        else { stop('No value provided for parameter -color=')}
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
color
nrowname
p
num1
num2
output
if(nrowname==2){
    data <- read.table(filename, header=T, row.names=nrowname, sep="\t")
    data <- data[,-1]
}else{
    data <- read.table(filename, header=T, row.names=nrowname, sep="\t")
}

counts <- as.matrix(data)
group <- factor(c(rep("A",num1),rep("B",num2)))
design <- model.matrix(~ group)
design

library(edgeR)
d <- DGEList(counts = counts, group = group)
d <- calcNormFactors(d)  # TMM norm factor
d$samples
d <- estimateGLMCommonDisp(d, design)  # variance  μ(1 + μφ)  for all genes
d <- estimateGLMTrendedDisp(d, design)
d <- estimateGLMTagwiseDisp(d, design) # variance  μ(1 + μφ)  for each gene

pdf(paste(output, ".BCV-MDS.pdf", sep=""), height=7, width=14)
par(mfrow=c(1,2))
plotBCV(d) # coefficient of variation of biological variation
plotMDS(d, method="bcv")
dev.off()

# exact test
result <- exactTest(d)
table <- as.data.frame(topTags(result, n = nrow(counts)))
is.DEG <- as.logical(table$FDR < p)
DEG.names <- rownames(table)[is.DEG]
pdf(paste(output, ".MAplot.pdf", sep=""), height=7, width=7)
plotSmear(result, de.tags = DEG.names)
dev.off()

# 2群の尤度比検定
fit <- glmFit(d, design)
lrt <- glmLRT(fit, coef = 2)
tt <- topTags(lrt, sort.by="none", n=nrow(data))
cnts <- cbind(lrt$fitted.values, tt$table)
cnts <- cnts[order(cnts$FDR),]
significant <- cnts$FDR < p
cnts_sig <- cnts[significant,]
#cnts_sig[cnts_sig==0] <- NA
#cnts_sig <- na.omit(cnts_sig)

sig_up <- cnts_sig$logFC > 0
cnts_sig_up <- cnts_sig[sig_up,]
sig_down <- cnts_sig$logFC < 0
cnts_sig_down <- cnts_sig[sig_down,]

write.table(cnts, file=paste(output, ".edgeR.all.xls", sep=""), quote=F, sep = "\t")
write.table(cnts_sig, file=paste(output, ".edgeR.DEGs.xls", sep=""), quote=F, sep = "\t")
write.table(cnts_sig_up, file=paste(output, ".edgeR.upDEGs.xls", sep=""), quote=F, sep = "\t")
write.table(cnts_sig_down, file=paste(output, ".edgeR.downDEGs.xls", sep=""), quote=F, sep = "\t")


# zスコアを用いてクラスタリング
library(som)
t <- apply(cnts_sig[,1:ncol(counts)], c(1,2), as.numeric)
t <- t+1
logt <- apply(t, c(1,2), log2)
logt.z <- normalize(logt, byrow=T)
logt.z <- na.omit(logt.z)      # NANを除去（全カラムが0の遺伝子）
colnames(logt.z) <- colnames(logt)
dist.z <- dist(logt.z)
tdist.z <- dist(t(logt.z))
rlt.z <- hclust(dist.z, method="ward.D2")
trlt.z <- hclust(tdist.z, method="ward.D2")

#heatmap
library("RColorBrewer")
library("gplots")

if(color=="blue"){
    hmcol <- colorRampPalette(brewer.pal(9, "GnBu"))(100)
}else if(color=="green"){
    hmcol <- colorRampPalette(brewer.pal(9, "YlGn"))(100)
}else if(color=="orange"){
    hmcol <- colorRampPalette(brewer.pal(9, "OrRd"))(100)
}else if(color=="purple"){
    hmcol <- colorRampPalette(brewer.pal(9, "Purples"))(100)
}

png(paste(output, ".heatmap.", p,".png", sep=""), h=1000, w=1000, pointsize=20)
heatmap.2(logt.z, scale = "none",
          dendrogram="both", Rowv=as.dendrogram(rlt.z), Colv=as.dendrogram(trlt.z), trace="none",
          col=hmcol, key.title="Color Key", key.xlab="Z score", key.ylab=NA)
dev.off()
