#! /usr/bin/perl -w

use strict;
use warnings;
use autodie;
my $file1=$ARGV[0];
my $file2=$ARGV[1];
my $line1=$ARGV[2];
my $line2=$ARGV[3];

die "combine_lines_from2files.pl <file1> <file2> <line1> <line2>\n" if($#ARGV !=3);

my %Hash = {};
open(List, $file1) ||die "error: can't open $file1.\n";
while(<List>){
    next if($_ eq "\n");
    chomp;
    my @clm = split(/\s/, $_);
    $Hash{$clm[$line1]} = $_;
}
close (ListFile);

open(List, $file2) ||die "error: can't open $file2.\n";
while(<List>){
    next if($_ eq "\n");
    chomp;
    my @clm = split(/\s/, $_);
    my $name = $clm[$line2];
    if(exists($Hash{$name})){
	print "$Hash{$name}\t$_\n";
    }
}
close (ListFile);
