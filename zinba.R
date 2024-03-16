
print.usage <- function() {
	cat('\nUsage: Rscript zinba.R <options>\n',file=stderr())
	cat('   MANDATORY ARGUMENTS\n',file=stderr())
	cat('      -c=<ChIP file>       , ChIP file\n',file=stderr())
	cat('      -i=<Input file>       , Input file\n',file=stderr())
	cat('      -g=<genome>         , 2bit genome\n',file=stderr())
	cat('      -mp=<mappability>     , mappablity directory\n',file=stderr())
	cat('      -t=<file type>     , <tagAlign|bed|bowtie>\n',file=stderr())
	cat('      -o=<output> , prefix of output file \n',file=stderr())
	cat('\n',file=stderr())
}

args <- commandArgs(trailingOnly = T)

nargs = length(args);
nargs
minargs = 6;
maxargs = 6;
if (nargs < minargs | nargs > maxargs) {
	print.usage()
	q(save="no",status=1)
}

flen   <- 200
wigdir <- "align_athresh1_extension200/"
numthread <- 4
for (each.arg in args) {
    if (grepl('^-c=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            IP <- arg.split[2]
        }
        else { stop('No data provided for parameter -g=')}
    }
    else if (grepl('^-i=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            input <- arg.split[2]
        }
        else { stop('No data provided for parameter -g=')}
    }
    else if (grepl('^-p=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            numthread <- as.numeric(arg.split[2])
        }
        else { stop('No data provided for parameter -p=')}
    }
    else if (grepl('^-t=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            ftype <- arg.split[2]
        }
        else { stop('No data provided for parameter -t=')}
    }
    else if (grepl('^-g=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            genome <- arg.split[2]
        }
        else { stop('No data provided for parameter -g=')}
    }
    else if (grepl('^-mp=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) {
            mpdir <- arg.split[2]
        }
        else { stop('No mpdir provided for parameter -mp=')}
    }
    else if (grepl('^-o=',each.arg)) {
        arg.split <- strsplit(each.arg,'=',fixed=TRUE)[[1]]
        if (! is.na(arg.split[2]) ) { output <- arg.split[2] }
        else { stop('No output file name provided for parameter -o=')}
    }
}

basecountfile <- paste(IP, ".basecount", sep="")

library(zinba)
generateAlignability(
  mapdir=mpdir,
  outdir=wigdir,
  athresh=1,
  extension=flen,
  twoBitFile=genome
)

basealigncount(
  inputfile=IP,
  outputfile=basecountfile,
  extension=flen,
  filetype=ftype,
  twoBitFile=genome
)

zinba(
  align=wigdir,
  numProc=4,
  seq=IP,
  basecountfile=basecountfile,
  filetype=ftype,
  outfile=output,
  twoBit=genome,
  extension=flen,
  printFullOut=1,
  refinepeaks=1,
  broad=F,
  input=input
)
