print.usage <- function() {
	cat('\nUsage: Rscript edgeR.R <options>\n',file=stderr())
	cat('   MANDATORY ARGUMENTS\n',file=stderr())
	cat('      -i=<input file>  , input file (RSEM gene/transcript file, estimated count) \n',file=stderr())
	cat('      -n=<num1>:<num2> , num of replicates for each group \n',file=stderr())
	cat('   OPTIONAL ARGUMENTS\n',file=stderr())
	cat('      -nrowname=<int> , row name (default: 1) \n',file=stderr())
	cat('      -ncolskip=<int> , colmun num to be skiped (default: 0) \n',file=stderr())
	cat('      -gname=<name1>:<name2> , name of each group \n',file=stderr())
	cat('      -p=<float>      , threshold for FDR (default: 0.01) \n',file=stderr())
	cat('      -color=<color>  , heatmap color (blue|orange|purple|green , default: blue) \n',file=stderr())
	cat('   OUTPUT ARGUMENTS\n',file=stderr())
	cat('      -o=<output> , prefix of output file \n',file=stderr())
	cat('\n',file=stderr())
}

args <- commandArgs(trailingOnly = T) 
nargs = length(args);
minargs = 1;
maxargs = 8;
if (nargs < minargs | nargs > maxargs) {
	print.usage()
	q(save="no",status=1)
}

nrowname <- 1
ncolskip <- 0
p <- 0.01
color <- "blue"
gname1 <- "groupA"
gname2 <- "groupB"
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
    else if (grepl('^-ncolskip=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            ncolskip <- as.numeric(arg.split[2])
        }
        else { stop('No value provided for parameter -ncolskip=')}
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

group <- factor(c(rep(gname1,num1),rep(gname2,num2)))
design <- model.matrix(~ group)
design

### read data
cat('\nread in', filename, '\n',file=stdout())

data <- read.table(filename, header=F, row.names=nrowname, sep="\t")
colnames(data) <- unlist(data[1,])   # ヘッダ文字化け対策 header=Tで読み込むと記号が.になる
data <- data[-1,]

if(ncolskip==1){
    data[,-1] <- lapply(data[,-1], function(x) as.numeric(as.character(x)))
    data <- subset(data,rowSums(data[,-1])!=0)
    genename <- data[,1]
    data <- data[,-1]
}else if(ncolskip==2){
    data[,-1:-2] <- lapply(data[,-1:-2], function(x) as.numeric(as.character(x)))
    data <- subset(data,rowSums(data[,-1:-2])!=0)
    genename <- data[,1:2]
    colnames(genename) <- c('genename','id')
    data <- data[,-1:-2]
}else{
    data <- subset(data,rowSums(data)!=0)
}

name <- colnames(data)
counts <- as.matrix(data)

colnames(counts)

cat('\ndim(', filename, ')\n',file=stdout())
dim(counts)

### omit 0 rows
cat('\ndim(', filename, ') after omitting non-expressed transcripts\n',file=stdout())
#counts <- subset(counts,rowSums(counts)!=0)
dim(counts)

### log and z_score
cat('\nlog(count+1) and z-scored\n',file=stdout())
library(som)
logcounts <- log2(counts+1)
zlog <- normalize(logcounts, byrow=T)  # logcountsを元にしたz-score
zlog[which(is.na(zlog))] <- 0          # 欠損値(全サンプルで同じ値)を0で置換
colnames(zlog) <- colnames(logcounts)

### fitted count
library(edgeR)
d <- DGEList(counts = counts, group = group)
d <- calcNormFactors(d)  # TMM norm factor
d$samples
d <- estimateGLMCommonDisp(d, design)  # variance  μ(1 + μφ)  for all genes
d <- estimateGLMTrendedDisp(d, design)
d <- estimateGLMTagwiseDisp(d, design) # variance  μ(1 + μφ)  for each gene
fit <- glmFit(d, design)
lrt <- glmLRT(fit, coef = 2)
fittedcount <- lrt$fitted.values

pdf(paste(output, ".edgeR.BCV-MDS.pdf", sep=""), height=7, width=14)
par(mfrow=c(1,2))
plotBCV(d) # coefficient of variation of biological variation
plotMDS(d, method="bcv")
dev.off()

### QQ plot
cat('\nmake QQ plot\n',file=stdout())
pdf(paste(output, ".QQplot.1stSample.pdf", sep=""), height=7, width=14)
par(mfrow=c(1,2))
qqnorm(counts[,1], main="linear scale")
qqnorm(logcounts[,1], main="log2 scale")
dev.off()

### density plot
f <- paste(output, ".density.png", sep="")
cat('\ndensity plot in', f, '\n',file=stdout())
library(ggplot2)
png(f, h=600, w=700, pointsize=20)
cells <- rep(name, each = nrow(logcounts))
dat <- data.frame(log2exp = as.vector(logcounts), cells = cells)
ggplot(dat, aes(x = log2exp, fill = cells)) + geom_density(alpha = 0.5)
dev.off()

### PCA
cat('\nmake PCA plot\n',file=stdout())
library(ggfortify)
pdf(paste(output, ".samplePCA.pdf", sep=""), height=7, width=7)
autoplot(prcomp(t(counts)), shape=F, label=T, label.size=3, data=d$samples, colour = 'group', main="raw counts")
autoplot(prcomp(t(logcounts)), shape=F, label=T, label.size=3, data=d$samples, colour = 'group', main="log counts")
autoplot(prcomp(t(zlog)), shape=F, label=T, label.size=3, data=d$samples, colour = 'group', main="z score")
autoplot(prcomp(t(fittedcount)), shape=F, label=T, label.size=3, data=d$samples, colour = 'group', main="fitted counts")
dev.off()

### DEGs
cat('\nobtain DEGs\n',file=stdout())
# Exact test (fitしていないデータを利用)
result <- exactTest(d)
table <- as.data.frame(topTags(result, n = nrow(counts)))
is.DEG <- as.logical(table$FDR < p)
DEG.names <- rownames(table)[is.DEG]
pdf(paste(output, ".MAplot.pdf", sep=""), height=7, width=7)
plotSmear(result, de.tags = DEG.names)
dev.off()

# 2群の尤度比検定
tt <- topTags(lrt, sort.by="none", n=nrow(data))

if(ncolskip==0){
	cnts <- cbind(lrt$fitted.values, tt$table)
}else{
	cnts <- cbind(genename, lrt$fitted.values, tt$table)
}

significant <- cnts$FDR < p
cnts_sig <- cnts[significant,]
cnts_sig <- cnts_sig[order(cnts_sig$PValue),]

# FDRでソートすると同値が発生するので、PValueでソートする
write.csv(cnts[order(cnts$PValue),], file=paste(output, ".edgeR.all.csv", sep=""), quote=F)
write.csv(cnts_sig,      file=paste(output, ".edgeR.DEGs.csv", sep=""), quote=F)
write.csv(cnts_sig[cnts_sig$logFC > 0,],   file=paste(output, ".edgeR.upDEGs.csv", sep=""), quote=F)
write.csv(cnts_sig[cnts_sig$logFC < 0,], file=paste(output, ".edgeR.downDEGs.csv", sep=""), quote=F)

# DEGsのクラスタリング
logt <- apply(fittedcount[significant,]+1, c(1,2), log2)
logt.z <- normalize(logt, byrow=T)
colnames(logt.z) <- colnames(logt)
dist.z <- dist(logt.z)
tdist.z <- dist(t(logt.z))
rlt.z <- hclust(dist.z, method="ward.D2")
trlt.z <- hclust(tdist.z, method="ward.D2")

pdf(paste(output, ".samplesCluster.inDEGs.pdf", sep=""), height=7, width=7)
plot(trlt.z)
dev.off()

#heatmap
cat('\nmake heatmap\n',file=stdout())
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
