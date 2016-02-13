#! /usr/bin/perl -w

use strict;
use warnings;
use autodie;
die "add_genename_fromrefseqid.pl <file> <refFlat>\n" if($#ARGV !=1);

$file=$ARGV[0];
$refflat=$ARGV[1];
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
