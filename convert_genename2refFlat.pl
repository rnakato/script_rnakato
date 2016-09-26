#!/usr/bin/env perl

#use strict;
#use warnings;
#use autodie;
die "convert_genename2refseq.pl <genefile> <refFlat>\n" if($#ARGV !=1);

$file=$ARGV[0];
$refflat=$ARGV[1];
open(ListFile, $refflat) ||die "error: can't open $refflat.\n";
while(<ListFile>){
    next if($_ eq "\n");
    chomp;
    my @clm = split(/\t/, $_);
    $clm[0] =~ s/(\w+)/\U$1/;
    $Hash{$clm[0]}=$_;
}
close (ListFile);

open(ListFile, $file) ||die "error: can't open $file.\n";
while(<ListFile>){
    next if($_ eq "\n");
    chomp;
    my @clm = split(/\t/, $_);
    $clm[0] =~ s/(\w+)/\U$1/;
    if(exists($Hash{$clm[0]})){
	print "$Hash{$clm[0]}\n";
    }
}
close (ListFile);

