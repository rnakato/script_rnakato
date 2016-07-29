args <- commandArgs(trailingOnly = T) # コマンドライン引数を読み込む
infile  <- args[1] # 1番目の引数を入力ファイル名として代入する。
outfile <- args[2] # 2番目の引数を出力ファイル名として代入する。
t <- args[3]       # 転置行列にするか
clst <- as.logical(args[4])
k <- args[5]

library(RColorBrewer)
library(gplots)

counts <- read.table(infile, row.names=1, header=T, sep="\t")
counts <- as.matrix(counts)

if(t == "T"){
    counts <- t(counts)
cn <- colnames(counts)	
}



#for (i in 2:length(cn)){
#    cn[i-1] <- cn[i]
#}    
#colnames(counts) <- cn
#temp <- counts[,-length(cn)]
#counts <- temp

counts

xval <- formatC(counts, format="f", digits=2)	
pal <- colorRampPalette(c(rgb(0.96,0.96,1), rgb(0.1,0.1,0.9)), space = "rgb")

dist <- dist(counts)
tdist <- dist(t(counts))
rlt <- hclust(dist, method="ward.D2")
trlt <- hclust(tdist, method="ward.D2")
#plot(rlt)
#plot(trlt)

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

k<-3
rlt <- classify(rlt, k)

pdf(paste(outfile, ".pdf", sep=""))
clust.col<-c(rep(c("orange","cyan"),k))
if(clst) {
heatmap.2(counts, Rowv=as.dendrogram(rlt),Colv=as.dendrogram(trlt), dendrogram="both", main="Matrix Heatmap", col=pal, 
          tracecol="#303030", trace="none", notecol="black", notecex=0.5, keysize = 1.5, margins=c(10, 10),
          hclustfun=function(d) hclust(d, method="complete"), RowSideColors=clust.col[rlt$cl])
} else {
heatmap.2(counts, dendrogram="none", Rowv=F, Colv=F, main="Matrix Heatmap", col=pal,
          tracecol="#303030", trace="none", notecol="black", notecex=0.5, keysize = 1.5, margins=c(10, 10))
}
dev.off()

#write.table(rlt$cl, file=paste(outfile, ".cluster.xls", sep=""), quote=F, sep = "\t",row.names = T, col.names = T)

## クラスタリングあり、数字表示
#heatmap.2(
#  counts, scale = "none",
#  dendrogram = "both", Rowv = TRUE, Colv = TRUE,
#  trace = "none",
#  main = "Density none", # グラフにヒストグラムを表示させない
#  col = redgreen(256)
#  col = heat.colors(256)
#)

#heatmap.2(
#  counts, scale = "row",
#  dendrogram = "both", Rowv = TRUE, Colv = TRUE,
#  trace = "none",
#  main = "Density none", # グラフにヒストグラムを表示させない
#  col = redgreen(256)
#)

#heatmap.2(
#  counts,
#  scale = "row",              # ?
#  dendrogram = "both",        # 系統樹の描画を指定（both, row, column, none）
#  Rowv = TRUE,               # dendrogramにboth,rowを指定した時にTRUEにする必要があります
#  Colv = TRUE,               # dendrogramにboth,columnを指定した時にTRUEにする必要があります
#  col = greenred(256),
#  key = TRUE,                 # スケールを表示
#  density.info = "density",   # スケールバーに密度をグラフに示す
#  main = "Peak overlap correlation"
#)
 
