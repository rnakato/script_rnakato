# 2列目と3列目で色を変えて重ねた散布図

data <- read.csv("ratio_vs_gd.csv", header=TRUE, sep="\t", quote="")

plot(data[,2], data[,3], ylim=c(0,2), pch="+", col="red")
par(new=T)
plot(data[,2], data[,4], ylim=c(0,2), pch="+", col="blue") 

legend("topright", legend=c("ab1220_TT2","ab1220_DKO"), col=c("red","blue"), pch=c("+","+"))
