#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
my $gd = $ARGV[0];
my $file1 = $ARGV[1];
my $file2 = $ARGV[2];

my %Hash;
my %wig;
my %wig2;
open(ListFile, $gd) ||die "error: can't open $gd\n";
while(<ListFile>){
    next if($_ eq "\n");
    chomp;
    my @clm = split(/\t/, $_);
    $Hash{$clm[0]} = $clm[1];
#    print "$clm[0]\n";
}
close (ListFile);

open(ListFile, $file1) ||die "error: can't open $file1\n";
my $line=<ListFile>;
$line=<ListFile>;
while(<ListFile>){
    next if($_ eq "\n");
    chomp;
    my @clm = split(/\t/, $_);
    $wig{$clm[0]-1} = $clm[1];
 #   print "$clm[0]\n";
}
close (ListFile);

open(ListFile, $file2) ||die "error: can't open $file2\n";
$line=<ListFile>;
$line=<ListFile>;
while(<ListFile>){
    next if($_ eq "\n");
    chomp;
    my @clm = split(/\t/, $_);
    $wig2{$clm[0]-1} = $clm[1];
 #   print "$clm[0]\n";
}
close (ListFile);

my $num=0;
foreach my $key (sort{$wig{$a} <=> $wig{$b}}(keys %wig)){
    if(exists($Hash{$key}) && exists($wig2{$key})){
	print "$key\t$Hash{$key}\t$wig{$key}\t$wig2{$key}\n";
    }
}
