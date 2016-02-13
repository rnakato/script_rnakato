#!/usr/bin/perl -w

=head1 DESCRIPTION
 
    Parse stats output by bowtie2.
 
=head1 SYNOPSIS

    parsebowtielog2.pl [--pair] <file>

=cut

use strict;
use warnings;
use autodie;
use Path::Class;
use Getopt::Long qw/:config posix_default no_ignore_case bundling auto_help/;
use Pod::Usage qw/pod2usage/;
my $pair=0;
GetOptions('pair' => \$pair);

my $filename=shift;
pod2usage unless $filename;
my $file = file($filename);
my $k=0;
my $fh = $file->open('r') or die $!;
while(<$fh>){
    next if($_ eq "\n");
    chomp;
    if($_ =~ /    (.+) (\(.+\)) aligned exactly (.+) time/){
	$k = $3;
	last;
    }
}

my $sample="";
my $num_total="";
my $num_mapped="";
my $num_unaligned="";
my $num_filtered="";
my $num_pcrfiltered=" -";

print "Sample\treads\tmapped $k time\t%\tmapped >$k time\t%\tmapped total\t%\tunmapped\t%\n";

$fh = $file->open('r') or die $!;
while(<$fh>){
    next if($_ eq "\n");
    chomp;
    if($_ =~ /bowtie2 (.+) (.+)\.fastq (.+)/){
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
    }elsif($_ =~ /(.+) reads; of these:/){
	$num_total=$1;
    }elsif($_ =~ /    (.+) (\(.+\)) aligned exactly (.+) time/){
	$num_mapped=$1;
	$k = $2;
    }elsif($_ =~ /    (.+) (\(.+\)) aligned 0 times/){
	$num_unaligned=$1;
    }elsif($_ =~ /    (.+) (\(.+\)) aligned (.+) times/){
	$num_filtered=$1;
 #   }elsif($_ =~ /(.+) overall alignment rate/){
#	$per_total_map=$1;
    }elsif($_ =~ /total: pcr bias position: (.+), filter read num: (.+)/){
	$num_pcrfiltered=$2;
    }elsif($_ =~ /Warning: Could not open read file/){
	$sample="";
    }
}
$fh->close;

if($num_total ne ""){
    my $totalnum = $num_mapped + $num_filtered;
	    printf "%s\t%d\t%d\t%.2f\t%d\t%.2f\t%d\t%.2f\t%d\t%.2f\t%s\n", $sample, $num_total, $num_mapped, $num_mapped*100/$num_total, $num_filtered, $num_filtered*100/$num_total, $totalnum, $totalnum*100/$num_total, $num_unaligned, $num_unaligned*100/$num_total, $num_pcrfiltered;
}
