#!/usr/bin/env perl

=head1 DESCRIPTION

    Parse stats outputted by bowtie2.

=head1 SYNOPSIS

    parsebowtielog2.pl [--pair] <file>

=cut

use strict;
use warnings;
use autodie;
use Path::Class;
use Getopt::Long;
use Pod::Usage qw/pod2usage/;
my $pair=0;
GetOptions('pair' => \$pair);

my $filename=shift;
pod2usage unless $filename;
my $file = file($filename);
my $k=0;
my $version="";

my $fh = $file->open('r') or die $!;
while(<$fh>){
    next if($_ eq "\n");
    chomp;
    if($_ =~ /    (.+) (\(.+\)) aligned exactly (.+) time/){
	$k = $3;
	last;
    }elsif($_=~ /    (.+) (\(.+\)) aligned concordantly exactly (.+) time/){
	$k = $3;
	last;
    }elsif($_=~ /(.+)bowtie(.+)version (.+)/){
	$version=$3;
    }
}
$fh->close;

my $sample="";
my $num_total="";
my $num_mapped="";
my $num_paired="";
my $num_unaligned="";
my $num_filtered="";

if(!$pair){
    print "\tSample\treads\tmapped $k time\t%\tmapped >$k time\t%\tmapped total\t%\tunmapped\t%\n";
}else{
    print "\tSample\treads\tpaired\t%\tmapped $k time\t%\tmapped >$k time\t%\tmapped total\t%\tunmapped\t%\n";
}

print "bowtie2 version $version\t";

$fh = $file->open('r') or die $!;
while(<$fh>){
    next if($_ eq "\n");
    chomp;
    if($_ =~ /bowtie2 (.+) (.+)\.fastq(.+)\> (.+)\/(.+).sort.(.+)/){
	if($sample ne ""){
	    my $totalnum = $num_mapped + $num_filtered;
	    if(!$pair){
		printf "%s\t%d\t", $sample, $num_total;
	    }else{
		printf "%s\t%d\t%d\t%.2f\t", $sample, $num_total, $num_paired, $num_paired*100/$num_total;
	    }
	    printf "%d\t%.2f\t%d\t%.2f\t%d\t%.2f\t%d\t%.2f\n", $num_mapped, $num_mapped*100/$num_total, $num_filtered, $num_filtered*100/$num_total, $totalnum, $totalnum*100/$num_total, $num_unaligned, $num_unaligned*100/$num_total;
	    $sample="";
	    $num_total="";
	    $num_mapped="";
	    $num_paired="";
	    $num_unaligned="";
	    $num_filtered="";
	}
	$sample = $5;
    }elsif($_ =~ /(.+) reads; of these:/){
	$num_total=$1;
    }elsif($_ =~ /Warning: Could not open read file/){
	$sample="";
    }
    if(!$pair){
	if($_ =~ /    (.+) (\(.+\)) aligned exactly (.+) time/){
	    $num_mapped=$1;
	    $k = $2;
	}elsif($_ =~ /    (.+) (\(.+\)) aligned 0 times/){
	    $num_unaligned=$1;
	}elsif($_ =~ /    (.+) (\(.+\)) aligned (.+) times/){
	    $num_filtered=$1;
	}
    }else{
	if($_ =~ /  (.+) (\(.+\)) were paired; of these:/){
	    $num_paired=$1;
	}elsif($_ =~ /    (.+) (\(.+\)) aligned concordantly exactly (.+) time/){
	    $num_mapped=$1;
	    $k = $2;
	}elsif($_ =~ /    (.+) (\(.+\)) aligned concordantly 0 times/){
	    $num_unaligned=$1;
	}elsif($_ =~ /    (.+) (\(.+\)) aligned concordantly (.+) times/){
	    $num_filtered=$1;
	}
    }
}
$fh->close;

if($num_total ne ""){
    my $totalnum = $num_mapped + $num_filtered;
    if(!$pair){
	printf "%s\t%d\t", $sample, $num_total;
    }else{
	printf "%s\t%d\t%d\t%.2f\t", $sample, $num_total, $num_paired, $num_paired*100/$num_total;
    }
    printf "%d\t%.2f\t%d\t%.2f\t%d\t%.2f\t%d\t%.2f\n", $num_mapped, $num_mapped*100/$num_total, $num_filtered, $num_filtered*100/$num_total, $totalnum, $totalnum*100/$num_total, $num_unaligned, $num_unaligned*100/$num_total;
}
