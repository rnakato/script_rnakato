
data <- read.csv("ratio_vs_gd.csv", header=TRUE, sep="\t", quote="")

pdf("scatter.pdf", height=7, width=14)
par(mfrow=c(1,2))

plot(data[,2], data[,3], ylim=c(0,2), xlab="gene num", ylab="ChIP/Input", pch="+", col="red", main="ab1220_TT2")
#result <- lm(data[,2] ~ data[,3])
#abline(result)

plot(data[,2], data[,4], ylim=c(0,2), xlab="gene num", ylab="ChIP/Input", pch="+", col="blue", main="ab1220_DKO")
#result <- lm(data[,2] ~ data[,4])
#abline(result)

dev.off()
