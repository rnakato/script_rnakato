library(grid)
source(file.path("/home/rnakato/git/BaMMmotif/R/plotBaMM.R" ))
source(file.path("/home/rnakato/git/BaMMmotif/R/readBaMM.R" ))

bammDir <- file.path(commandArgs(trailingOnly=TRUE)[1])
logoDir <- file.path(bammDir, "Logos")
if(!(file.exists(logoDir))) dir.create(logoDir)

plot <- function(filename) {
    order <- 0 # BaMM logo order (maximum order = 5)
    RNASeqLogo <- FALSE
    useFreqs <- FALSE
    icColumnScale <- TRUE # icLetterScale and not icColumnScale is not implemented
    icLetterScale <- TRUE # icLetterScale and not icColumnScale is not implemented
    alpha <- .3 # icLetterScale only
    plot.xaxis <- TRUE
    plot.xlab <- TRUE
    plot.border.labels <- TRUE
    xanchor <- NULL
    xanchor.labels <- FALSE
    plot.xanchor <- FALSE # numeric xanchor.labels only
    plot.yaxis <- TRUE
    plot.ylab <- TRUE
    ylim <- c( -.5, 2 )
    yat <- c( -.5, 0, 1, 2 )
    yaxis.vjust <- .5
    cex <- 2.7
    lwd <- 4
    width <- 7
    height <- 7
    pointsize <- 12
    
    svg(file.path(logoDir, paste(filename, "_logo-k", order, ".svg", sep="")),
        width=width, height=height, pointsize=pointsize)
    opar <- par(no.readonly=TRUE)
    
    hoSeqLogo(filename=file.path(bammDir, filename), order=order, rna=RNASeqLogo,
              useFreqs=useFreqs, icColumnScale=icColumnScale,
              icLetterScale=icLetterScale, alpha=alpha, plot.xaxis=plot.xaxis,
              plot.xlab=plot.xlab, plot.border.labels=plot.border.labels,
              xanchor=xanchor, xanchor.label=xanchor.labels,
              plot.xanchor=plot.xanchor, plot.yaxis=plot.yaxis,
              plot.ylab=plot.ylab, ylim=ylim, yat=yat, yaxis.vjust=yaxis.vjust,
              cex=cex, lwd=lwd )
    par(opar)
    dev.off()
}

plot(commandArgs(trailingOnly=TRUE)[2])
