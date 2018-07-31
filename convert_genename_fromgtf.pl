#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
die "convert_genename_fromgtf.pl [genes|isoforms] [all|pc] <file> <gtf> <line>\n" if($#ARGV !=4);

my $type=$ARGV[0];
my $outputtype=$ARGV[1];
my $file=$ARGV[2];
my $gtf=$ARGV[3];
my $nline=$ARGV[4];

my %Hashgname;
my %Hashtname;
my %Hashgtype;
my %Hashttype;

open(ListFile, $gtf) ||die "error: can't open $gtf.\n";
while(<ListFile>){
    next if($_ eq "\n");
    chomp;
    my @clm = split(/;/, $_);
    my $gene="";
    my $tr="";
    my $genename="";
    my $trname="";
    my $genetype="";
    my $trtype="";
    foreach my $str (@clm){
	$gene = $2 if($str =~ /(.*)gene_id "(.+)"/);
	$tr   = $2 if($str =~ /(.*)transcript_id "(.+)"/);
	$genename = $2 if($str =~ /(.*)gene_name "(.+)"/);
        $trname   = $2 if($str =~ /(.*)transcript_name "(.+)"/);
	$genetype = $2 if($str =~ /(.*)gene_biotype "(.+)"/);
	$trtype = $2 if($str =~ /(.*)transcript_biotype "(.+)"/);
    }
    $Hashgname{$gene}=$genename;
    $Hashtname{$tr}=$trname;
    $Hashgtype{$gene}=$genetype;
    $Hashttype{$tr}=$trtype;
}
close (ListFile);

open(ListFile, $file) ||die "error: can't open $file.\n";
my $line = <ListFile>;
print "\t$line";
while(<ListFile>){
    next if($_ eq "\n");
    chomp;
    my @clm = split(/\t/, $_);
    my $id = $clm[$nline];

    if($type eq "genes") {
	next if($outputtype eq "pc" && $Hashgtype{$id} ne "protein_coding" );
	if(exists($Hashgname{$id})){
	    print "$Hashgname{$id}\t$_\n";
	}else{
	    print "\t$_\n";
	}
    } else {
	next if($outputtype eq "pc" && $Hashttype{$id} ne "protein_coding" );
	if(exists($Hashtname{$id})){
            print "$Hashtname{$id}\t$_\n";
        }else{
            print "\t$_\n";
        }
    }
}
close (ListFile);
