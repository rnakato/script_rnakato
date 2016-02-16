args <- commandArgs(trailingOnly = T) # コマンドライン引数を読み込む
infile  <- args[1] # 1番目の引数を入力ファイル名として代入する。
outfile <- args[2] # 2番目の引数を出力ファイル名として代入する。
t <- args[3]       # 転置行列にするか
clst <- as.logical(args[4])

library(RColorBrewer)
library(gplots)

counts <- read.table(infile, header=T, row.names=1, sep="\t")

counts <- as.matrix(counts)

if(t == "T"){
    counts <- t(counts)
}

library(gplots)
pdf(outfile)
xval <- formatC(counts, format="f", digits=2)	
pal <- colorRampPalette(c(rgb(0.96,0.96,1), rgb(0.1,0.1,0.9)), space = "rgb")
heatmap.2(
    counts, 
    Rowv=clst,Colv=clst,
    dendrogram="both",   # 樹形図
    main="Overlap Matrix Heatmap", 
                                        #        xlab="Columns", ylab="Rows", 
    col=pal, 
    tracecol="#303030", 
    trace="none",
                                        #        cellnote=xval, 
    notecol="black", 
    notecex=0.5, 
    keysize = 1.5, 
    margins=c(10, 10),
    hclustfun=function(d) hclust(d, method="complete")
#    hclustfun=function(d) hclust(d, method="ward.D2") 
)
dev.off()

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
 
