#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
use Path::Class;
use Getopt::Long qw/:config posix_default no_ignore_case bundling auto_help/;
use Pod::Usage qw/pod2usage/;

if($#ARGV){
    print "bam2tagAlign.pl <bam>\n";
    exit;
}
my $filename=shift;

open(FILE, " samtools view -F 0x0204 -o - $filename |") or die("Error");
while(<FILE>){
    next if($_ eq "");
    chomp;
    my @F = split(/\t/, $_);
    my $s = $F[3]-1;
    my $e = $s + length($F[9]);
    if($F[1]) {
	print "$F[2]\t$s\t$e\t$F[9]\t1000\t-\n";
    } else{
	print "$F[2]\t$s\t$e\t$F[9]\t1000\t+\n";
    }
}
