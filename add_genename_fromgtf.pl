#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
die "add_genename_fromgtf.pl <file> <gtf>\n" if($#ARGV !=1);

my $file=$ARGV[0];
my $gtf=$ARGV[1];
my %Hash;
open(ListFile, $gtf) ||die "error: can't open $gtf.\n";
while(<ListFile>){
    next if($_ eq "\n");
    chomp;
    if($_ =~ /(.+)gene_id "(.+)"; transcript_id "(.+)";(.+)/){
	$Hash{$3}=$2;
    }
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
