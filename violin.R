print.usage <- function() {
	cat('\nUsage: Rscript violin.R <options>\n',file=stderr())
	cat('   MANDATORY ARGUMENTS\n',file=stderr())
	cat('      -i=<input file>  , input file separatd by \',\') \n',file=stderr())
	cat('   OPTIONAL ARGUMENTS\n',file=stderr())
	cat('      -nrowname=<int> , row name (default: 1) \n',file=stderr())
	cat('      -p=<float>      , threshold for FDR (default: 0.01) \n',file=stderr())
	cat('      -color=<color>  , heatmap color (blue|orange|purple|green , default: blue) \n',file=stderr())
	cat('      -density        , density plot of expression level \n',file=stderr())
	cat('   OUTPUT ARGUMENTS\n',file=stderr())
	cat('      -o=<output> , prefix of output file \n',file=stderr())
	cat('\n',file=stderr())
}

args <- commandArgs(trailingOnly=TRUE);
nargs = length(args);
minargs = 2;
maxargs = 2;
if (nargs < minargs | nargs > maxargs) {
	print.usage()
	q(save="no",status=1)
}

for(each.arg in args){
    if(grepl('^-i=',each.arg)) { #-i=<inputfile>
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if(!is.na(arg.split[2])){
            files <- strsplit(arg.split[2],',',fixed=TRUE)[[1]]
        }else{
            stop('No inputfile name provided for parameter -i=')
        }
    }else if(grepl('^-o=',each.arg)) { #-o=<outputfilename>
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]] # split on =
        if (!is.na(arg.split[2])){
            output <- arg.split[2]
        } else {
            stop('No outputfile for parameter -o=')
        }
    }
}

files
output

width <- NULL
for (file in files) {
  print (file)
  t <- read.table(file, header=T, sep="\t", quote="")
  width <- cbind(width, t[,3] - t[,2])
}

q(save="no",status=1)


library(vioplot)
png(paste(outputname,".png", sep=""), width = 480, height = 480)
vioplot(width[,0], ylim=c(0,1000), col="lightpink")
dev.off()
