#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
die "add_genename_fromrefseqid.pl <file> <refFlat>\n" if($#ARGV !=1);

my $file=$ARGV[0];
my $refflat=$ARGV[1];
my %Hash={};
open(ListFile, $refflat) ||die "error: can't open $refflat.\n";
while(<ListFile>){
    next if($_ eq "\n");
    chomp;
    my @clm = split(/\t/, $_);
    $Hash{$clm[1]}=$clm[0];
}
close (ListFile);

open(ListFile, $file) ||die "error: can't open $file.\n";
while(<ListFile>){
    next if($_ eq "\n");
    chomp;
    my @clm = split(/\t/, $_);
    if(exists($Hash{$clm[0]})){
	print "$Hash{$clm[0]}\t$_\n";
    }else{
	print "\t$_\n";
    }
}
close (ListFile);
