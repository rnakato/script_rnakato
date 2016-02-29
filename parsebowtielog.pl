#!/usr/bin/env perl

=head1 DESCRIPTION
 
    Parse stats output by bowtie1.
 
=head1 SYNOPSIS

    parsebowtielog.pl <file>

=cut

use strict;
use warnings;
use autodie;
use Path::Class;
use Getopt::Long qw/:config posix_default no_ignore_case bundling auto_help/;
use Pod::Usage qw/pod2usage/;

my $filename=shift;
pod2usage(2) unless $filename;

print "Sample\treads\tmapped unique\t%\tmapped >= 2\t%\tmapped total\t%\tunmapped\t%\n";
my $sample="";
my $num_total="";
my $num_mapped="";
my $num_unaligned="";
my $num_filtered="";
my $num_pcrfiltered="";
my $totalnum=0;

my $file = file($filename);
my $fh = $file->open('r') or die $!;
while(<$fh>){
    next if($_ eq "\n");
    if($_ =~ /Could not open read file/){
	print $_;
	next;
    }
    chomp;
    if($_ =~ /bowtie (.+)[>|samtools sort -] (.+)/){
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
    }elsif($_ =~ /# reads processed: (.+)/){
	$num_total=$1;
    }elsif($_ =~ /# reads with at least one reported alignment: (.+) (\(.+\))/){
	$num_mapped=$1;
    }elsif($_ =~ /# reads that failed to align: (.+) (\(.+\))/){
	$num_unaligned=$1;
    }elsif($_ =~ /# reads with alignments suppressed due to -m: (.+) (\(.+\))/){
	$num_filtered=$1;
    }elsif($_ =~ /total: pcr bias position: (.+), filter read num: (.+)/){
	$num_pcrfiltered=$2;
    }
}
$fh->close;


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
