t <- read.table("temp", header=TRUE, skip=0, sep="\t", quote="",)
x <- t[,c(3,4,2)]
 
library(rgl)
plot3d(x)
writeWebGL(width=500, height=550)

install.packages("lattice")
library(lattice)
#levelplot(x[,3]~x[,1]*x[,2])
d <- expand.grid(x=x[,1],y=x[,2])
d$z <- d$x*d$y
levelplot(z~x*y, data=d, asp=1)

install.packages("playwith")
library("playwith")
playwith(cloud(x[,1] ~ x[,2] * x[,3], data = trees))
