#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "IDR.sh [-b] <peakfile1> <peakfile2> <prefix> [signal.value|p.value|q.value]" 1>&2
    echo " (REMEMBER TO USE RELAXED THRESHOLDS AND TRY TO CALL 150k to 300k peaks even if most of them are noise)" 1>&2
}

broad="F"
while getopts s option
do
    case ${option} in
	b)
	    broad="T"
	    ;;
	*)
	    usage
	    exit 1
	    ;;
    esac
done
shift $((OPTIND - 1))

# check arguments
if [ $# -ne 4 ]; then
  usage
  exit 1
fi

bed1=$1
bed2=$2
prefix=$3
measure=$4

R=$(cd $(dirname $0) && pwd)/../binaries/idrCode/batch-consistency-analysis.r
mdir=IDR
if test ! -e $mdir; then mkdir $mdir; fi

#Rscript $R [peakfile1] [peakfile2] [peak.half.width] [outfile.prefix] [min.overlap.ratio] [is.broadpeak] [ranking.measure]
Rscript $R $bed1 $bed2 -1 $prefix 0 $broad $measure


#### FOR SELF-CONSISTENCY ANALYSIS CALL PEAKS ON PSEUDOREPLICATES OF INDIVIDUAL REPLICATES

#fileName='chipSampleRep1.tagAlign.gz' # input tagAlign file name
#outputDir='/mapped/selfPseudoReps' # output directory for pseudoreplicate files
#outputStub='chipSampleRep1' # prefix name for pseudoReplicate files

#nlines=$( zcat ${fileName} | wc -l ) # Number of reads in the tagAlign file
#nlines=$(( (nlines + 1) / 2 )) # half that number
#zcat "${fileName}" | shuf | split -d -l ${nlines} - "${outputDir}/${outputStub}" # This will shuffle the lines in the file and split it into two parts
#gzip "${outputDir}/${outputStub}00"
#gzip "${outputDir}/${outputStub}01"
#mv "${outputDir}/${outputStub}00.gz" "${outputDir}/${outputStub}.pr1.tagAlign.gz"
#mv "${outputDir}/${outputStub}01.gz" "${outputDir}/${outputStub}.pr2.tagAlign.gz"
