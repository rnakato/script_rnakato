print.usage <- function() {
	cat('\nUsage: Rscript matrix_heatmap.R <options>\n',file=stderr())
	cat('   MANDATORY ARGUMENTS\n',file=stderr())
	cat('      -i=<input file>  , input file \n',file=stderr())
	cat('      -o=<output> , prefix of output file \n',file=stderr())
	cat('   OPTIONAL ARGUMENTS\n',file=stderr())
	cat('      -t, Transposed matrix \n',file=stderr())
	cat('      -clst, implement clustering (hclust) \n',file=stderr())
	cat('      -k=<int> , number of clusters classified (default: 3) \n',file=stderr())
	cat('      -method=<string> , method for hclust (default: ward.D2) \n',file=stderr())
	cat('      -fsize=<float> , font size of row and column (default: 0.5) \n',file=stderr())
	cat('\n',file=stderr())
}

args <- commandArgs(trailingOnly = T)

t <- 0
clst <- 0
fsize <- 0.5
k <- 3
method <- "ward.D2"
for (each.arg in args) {
    if (grepl('^-i=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            infile <- arg.split[2]
        }
    }
    else if (grepl('^-o=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            outfile <- arg.split[2]
        }
    }
    else if (grepl('^-t',each.arg)) {
        t <- 1
    }
    else if (grepl('^-clst',each.arg)) {
        clst <- 1
    }
    else if (grepl('^-k=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            k <- as.numeric(arg.split[2])
        }
    }
    else if (grepl('^-method=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            method <- arg.split[2]
        }
    }
    else if (grepl('^-fsize=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            fsize <- as.numeric(arg.split[2])
        }
    }
}

infile
outfile
t
clst
k
method

library(RColorBrewer)
library(gplots)

counts <- read.table(infile, row.names=1, header=T, sep="\t")
counts <- as.matrix(counts)

if(t == "T"){ counts <- t(counts)}

head(counts)

xval <- formatC(counts, format="f", digits=2)

#colors = c(seq(0, 1.2, length=100))
my_palette <- colorRampPalette(c(rgb(0.96,0.96,1), rgb(0.1,0.1,0.9)), space = "rgb")

dist <- dist(counts)
tdist <- dist(t(counts))
rlt <- hclust(dist, method=method)
trlt <- hclust(tdist, method=method)

sortree <- function(rlt){
    name <- rlt$labels
    max <- length(name)

    array <- c(rep(0,k))
    n <- 1
    temp <- 0
    for(i in 1:max){
        j <- rlt$cl[name[rlt$order[max-i+1]]]
        if(n==1 || temp != j){
            print(j)
            array[n] <- j
            temp <- j
            n <- n+1
        }
    }
    return (array)
}

classify <- function(rlt, k){
    rlt$cl <- cutree(rlt,k=k)

    array <- sortree(rlt)
    for(i in 1:length(rlt$labels)){ rlt$cl[i] <- which(array==rlt$cl[i])}
#    sortree(rlt)
    return (rlt)
}

rlt <- classify(rlt, k)

pdf(paste(outfile, ".pdf", sep=""))

if(clst) {
    clust.col <- c(rep(c("orange", "brown", "green", "pink", "purple", "cyan", "grey", "blue"), k))

    heatmap.2(counts, dendrogram="both",
              Rowv=as.dendrogram(rlt),
              Colv=as.dendrogram(trlt),
              main="Correlation Heatmap",
              col=my_palette, #breaks=colors,
              tracecol="#303030",
              trace="none", notecol="black",
              notecex=0.3, keysize = 1.5,
              cexRow=fsize, cexCol=fsize,
              margins=c(10, 10),
              RowSideColors=clust.col[rlt$cl])
#        hclustfun=function(d) hclust(d, method="ward.D2"))
} else {
    heatmap.2(counts, dendrogram="none",
              Rowv=F, Colv=F,
              main="Correlation Heatmap",
              col=my_palette, #breaks=colors,
#              cellnote=counts,
              tracecol="#303030",
              trace="none", notecol="black",
              notecex=0.3, keysize = 1.5,
              cexRow=fsize, cexCol=fsize,
              margins=c(10, 10))
}
dev.off()

#write.table(rlt$cl, file=paste(outfile, ".cluster.xls", sep=""), quote=F, sep = "\t",row.names = T, col.names = T)
