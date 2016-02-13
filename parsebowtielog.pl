#!/usr/bin/perl -w

use strict;
use warnings;
use autodie;
open(ListFile, $ARGV[0]) ||die "error: can't open $ARGV[0].\n";

print "Sample\treads\tmapped unique\t%\tmapped >= 2\t%\tmapped total\t%\tunmapped\t%\n";

$sample="";
$num_total="";
$num_mapped="";
$num_unaligned="";
$num_filtered="";
$num_pcrfiltered="";
while($line = <ListFile>){
    next if($line eq "\n");
    if($line =~ /Could not open read file/){
	print $line;
	next;
    }
    chomp($line);
    if($line =~ /bowtie(.+)[>|samtools sort -] (.+)/){
	if($sample ne ""){
	    if($num_filtered ne ""){
		$totalnum = $num_mapped + $num_filtered;
		printf "%s\t%d\t%d\t%.2f\t%d\t%.2f\t%d\t%.2f\t%d\t%.2f\n", $sample, $num_total, $num_mapped, $num_mapped*100/$num_total, $num_filtered, $num_filtered*100/$num_total, $totalnum, $totalnum*100/$num_total, $num_unaligned, $num_unaligned*100/$num_total;
	    }else{
		$totalnum = $num_mapped;
		printf "%s\t%d\t\t\t%d\t%.2f\t%d\t%.2f\t%d\t%.2f\n", $sample, $num_total, $num_mapped, $num_mapped*100/$num_total, $totalnum, $totalnum*100/$num_total, $num_unaligned, $num_unaligned*100/$num_total;
	    }
	    $sample="";
	    $num_total="";
	    $num_mapped="";
	    $num_unaligned="";
	    $num_filtered="";
	    $num_pcrfiltered=" -";
	}
	$sample = $2;
    }elsif($line =~ /# reads processed: (.+)/){
	$num_total=$1;
    }elsif($line =~ /# reads with at least one reported alignment: (.+) (\(.+\))/){
	$num_mapped=$1;
    }elsif($line =~ /# reads that failed to align: (.+) (\(.+\))/){
	$num_unaligned=$1;
    }elsif($line =~ /# reads with alignments suppressed due to -m: (.+) (\(.+\))/){
	$num_filtered=$1;
    }elsif($line =~ /total: pcr bias position: (.+), filter read num: (.+)/){
	$num_pcrfiltered=$2;
    }

}
close (ListFile);

if($sample ne ""){
    if($num_filtered ne ""){
	$totalnum = $num_mapped + $num_filtered;
	printf "%s\t%d\t%d\t%.2f\t%d\t%.2f\t%d\t%.2f\t%d\t%.2f\n", $sample, $num_total, $num_mapped, $num_mapped*100/$num_total, $num_filtered, $num_filtered*100/$num_total, $totalnum, $totalnum*100/$num_total, $num_unaligned, $num_unaligned*100/$num_total;
    }else{
	$totalnum = $num_mapped;
	printf "%s\t%d\t\t\t%d\t%.2f\t%d\t%.2f\t%d\t%.2f\n", $sample, $num_total, $num_mapped, $num_mapped*100/$num_total, $totalnum, $totalnum*100/$num_total, $num_unaligned, $num_unaligned*100/$num_total;
    }
    $sample="";
    $num_total="";
    $num_mapped="";
    $num_unaligned="";
    $num_filtered="";
    $num_pcrfiltered=" -";
}
