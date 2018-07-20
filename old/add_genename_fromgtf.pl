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
    my @clm = split(/;/, $_);
    my $gene="";
    my $tr="";
    foreach my $str (@clm){
	$gene = $2 if($str =~ /(.*)gene_id "(.+)"/);
	$tr   = $2 if($str =~ /(.*)transcript_id "(.+)"/);
    }
    $Hash{$tr}=$gene;
}
close (ListFile);

open(ListFile, $file) ||die "error: can't open $file.\n";
my $line = <ListFile>;
print "\t$line";
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
