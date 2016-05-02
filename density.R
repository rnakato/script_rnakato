data <- read.table("Matrix.genes.hg38.txt", header=T, row.names=1, sep="\t")

name <- colnames(data)
data <- data+1
exp <- as.vector(as.matrix(data))
logexp <- log10(exp)
cells <- rep(name, each = nrow(data))
dat <- data.frame(logexp = logexp, cells = cells)

library(ggplot2)
ggplot(dat, aes(x = logexp, fill = cells)) + geom_density(alpha = 0.5)

