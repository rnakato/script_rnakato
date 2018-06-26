#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
die "add_geneinfo_fromRefFlat.pl [genes|isoforms] <file> <refFlat> <nline>\n" if($#ARGV !=3);

my $type=$ARGV[0];
my $file=$ARGV[1];
my $refflat=$ARGV[2];
my $nline=$ARGV[3];

my %Hash;

open(ListFile, $refflat) ||die "error: can't open $refflat.\n";
while(<ListFile>){
    next if($_ eq "\n");
    chomp;
    my @clm = split(/\t/, $_);
    my $id = "";
    if($type eq "isoforms") {
	$id = $clm[1];
    } else {
	$id = $clm[0];
    }
    $Hash{$id}=$_;
}
close (ListFile);

open(ListFile, $file) ||die "error: can't open $file.\n";
my $line = <ListFile>;
chomp($line);
print "$line\tchromosome\tstrand\tstart\tend\tlength\ttype\n";
while(<ListFile>){
    next if($_ eq "\n");
    chomp;
    my @clm = split(/\t/, $_);

    if(exists($Hash{$clm[$nline]})){
	my @clm2 = split(/\t/, $Hash{$clm[$nline]});
	my $len = $clm2[5] - $clm2[4];
	my $desc = $clm2[11];
	$desc = $clm2[12] if($type eq "isoforms");
	print "$_\t$clm2[2]\t$clm2[3]\t$clm2[4]\t$clm2[5]\t$len\t$desc\n";
    }else{
	print "$_\n";
    }
}
close (ListFile);
