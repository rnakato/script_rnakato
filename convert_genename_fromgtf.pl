#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
die "add_genename_fromgtf.pl <file> <gtf>\n" if($#ARGV !=1);

my $file=$ARGV[0];
my $gtf=$ARGV[1];
my %Hashgname;
my %Hashtname;

open(ListFile, $gtf) ||die "error: can't open $gtf.\n";
while(<ListFile>){
    next if($_ eq "\n");
    chomp;
    my @clm = split(/;/, $_);
    my $gene="";
    my $tr="";
    my $genename="";
    my $trname="";
    foreach my $str (@clm){
	$gene = $2 if($str =~ /(.*)gene_id "(.+)"/);
	$tr   = $2 if($str =~ /(.*)transcript_id "(.+)"/);
	$genename = $2 if($str =~ /(.*)gene_name "(.+)"/);
        $trname   = $2 if($str =~ /(.*)transcript_name "(.+)"/);
    }
    $Hashgname{$gene}=$genename;
    $Hashtname{$tr}=$trname;
}
close (ListFile);

open(ListFile, $file) ||die "error: can't open $file.\n";
my $line = <ListFile>;
print "\t$line";
while(<ListFile>){
    next if($_ eq "\n");
    chomp;
    my @clm = split(/\t/, $_);

    if(exists($Hashgname{$clm[0]})){
	print "$Hashgname{$clm[0]}\t$_\n";
    }elsif(exists($Hashtname{$clm[0]})){
	print "$Hashtname{$clm[0]}\t$_\n";
    }else{
	print "\t$_\n";
    }
}
close (ListFile);
