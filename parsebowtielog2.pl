#!/usr/bin/perl -w

use strict;
use warnings;
use autodie;
$k=0;
open(ListFile, $ARGV[0]) ||die "error: can't open $ARGV[0].\n";
while($line = <ListFile>){
    next if($line eq "\n");
    chomp($line);
    if($line =~ /    (.+) (\(.+\)) aligned exactly (.+) time/){
	$k = $3;
	last;
    }
}
close (ListFile);

open(ListFile, $ARGV[0]) ||die "error: can't open $ARGV[0].\n";
$sample="";
$num_total="";
$num_mapped="";
$num_unaligned="";
$num_filtered="";
$num_pcrfiltered=" -";

print "Sample\treads\tmapped $k time\t%\tmapped >$k time\t%\tmapped total\t%\tunmapped\t%\n";

while($line = <ListFile>){
    next if($line eq "\n");
    chomp($line);
    if($line =~ /bowtie2(.+) (.+)\.fastq (.+)/){
	if($sample ne ""){
	    my $totalnum = $num_mapped + $num_filtered;
	    printf "%s\t%d\t%d\t%.2f\t%d\t%.2f\t%d\t%.2f\t%d\t%.2f\n", $sample, $num_total, $num_mapped, $num_mapped*100/$num_total, $num_filtered, $num_filtered*100/$num_total, $totalnum, $totalnum*100/$num_total, $num_unaligned, $num_unaligned*100/$num_total, $num_pcrfiltered;
	    $sample="";
	    $num_total="";
	    $num_mapped="";
	    $num_unaligned="";
	    $num_filtered="";
	    $num_pcrfiltered=" -";
	}
	$sample = $2;
    }elsif($line =~ /(.+) reads; of these:/){
	$num_total=$1;
    }elsif($line =~ /    (.+) (\(.+\)) aligned exactly (.+) time/){
	$num_mapped=$1;
	$k = $2;
    }elsif($line =~ /    (.+) (\(.+\)) aligned 0 times/){
	$num_unaligned=$1;
    }elsif($line =~ /    (.+) (\(.+\)) aligned (.+) times/){
	$num_filtered=$1;
 #   }elsif($line =~ /(.+) overall alignment rate/){
#	$per_total_map=$1;
    }elsif($line =~ /total: pcr bias position: (.+), filter read num: (.+)/){
	$num_pcrfiltered=$2;
    }elsif($line =~ /Warning: Could not open read file/){
	$sample="";
    }
}
close (ListFile);

if($num_total ne ""){
    my $totalnum = $num_mapped + $num_filtered;
	    printf "%s\t%d\t%d\t%.2f\t%d\t%.2f\t%d\t%.2f\t%d\t%.2f\t%s\n", $sample, $num_total, $num_mapped, $num_mapped*100/$num_total, $num_filtered, $num_filtered*100/$num_total, $totalnum, $totalnum*100/$num_total, $num_unaligned, $num_unaligned*100/$num_total, $num_pcrfiltered;
}
