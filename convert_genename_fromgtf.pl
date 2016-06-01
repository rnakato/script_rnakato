#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
die "convert_genename_fromgtf.pl [gene|transcript] <file> <gtf> <line>\n" if($#ARGV !=3);

my $type=$ARGV[0];
my $file=$ARGV[1];
my $gtf=$ARGV[2];
my $nline=$ARGV[3];
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

    if($type eq "gene") {
	if(exists($Hashgname{$clm[$nline]})){
	    print "$Hashgname{$clm[$nline]}\t$_\n";
	}else{
	    print "\t$_\n";
	}
    } else {
	if(exists($Hashtname{$clm[$nline]})){
            print "$Hashtname{$clm[$nline]}\t$_\n";
        }else{
            print "\t$_\n";
        }
    }
}
close (ListFile);
