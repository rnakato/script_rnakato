args <- commandArgs(trailingOnly=TRUE)
inputfile <- args[1]
label <- args[2]

library(reshape2)
library(ggplot2)
input1 <- read.table(inputfile)
data1 <- input1[c(3,5)]
total_cis_contact1 <- apply(data1[c(2)], 2, sum)
prob1 <- sapply(data1[c(2)], function(x){return(x/total_cis_contact1)})
p1 <- as.data.frame(prob1)
problist <-cbind(data1[c(1)],p1[c(1)])
name <- c("distance",label)
names(problist) <- name
df <-melt(problist, id.vars = "distance", measure.vars = label, variable.name = "data", value.name = "probability")
g <- ggplot(df, aes (distance,probability, colour = data))
xbreaks <- c(1000, 10000,100000,1000000,10000000,100000000,1000000000)
ybreaks <- c(1,0.1,0.01,0.001,0.0001,0.00001,0.000001)
g <- g + scale_x_log10(breaks=xbreaks,labels=xbreaks)
g <- g + scale_y_log10(breaks=ybreaks,labels=ybreaks)
l <- g + geom_line()
pdf(sub(".txt", ".pdf", inputfile), width = 10, height = 10)
plot(l)
dev.off()
