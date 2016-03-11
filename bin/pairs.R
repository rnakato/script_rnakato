args <- commandArgs(trailingOnly = T) # コマンドライン引数を読み込む
infile <- args[1]
outfile <- args[2]

t <- read.table(infile, header=TRUE, row.names=1, sep="\t", quote="")
t[t < 1] <- NA              #シグナル強度が1未満のものをNAにする

#data.log <- log(data, base=2)
#D <- as.matrix(data.log)
D <- as.matrix(t)

panel.hist <- function(x, ...){
    usr <- par("usr"); on.exit(par(usr))
    par(usr = c(usr[1:2], 0, 1.5) )
    h <- hist(x, plot = FALSE)
    breaks <- h$breaks; nB <- length(breaks)
    y <- h$counts; y <- y/max(y)
    rect(breaks[-nB], 0, breaks[-1], y, col="cyan", ...)
}

panel.cor.log <- function(x, y, digits=2, prefix="", cex.cor){
xy <- x+y
x <- x[is.finite(xy)]
y <- y[is.finite(xy)]
         usr <- par("usr"); on.exit(par(usr))
         par(usr = c(0, 1, 0, 1))
         r = (cor(x, y,use="pairwise"))
         txt <- format(c(r, 0.123456789), digits=digits)[1]
         txt <- paste(prefix, txt, sep="")
         if(missing(cex.cor)) cex <- 0.8/strwidth(txt)
         text(0.5, 0.5, txt, cex = cex )
}

pdf(outfile)

par(pch=".")
pairs(D, upper.panel=panel.cor.log, diag.panel=panel.hist)

dev.off()
