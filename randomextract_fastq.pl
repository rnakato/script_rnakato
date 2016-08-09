#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
die "randomextract_fastq.pl <fastq> <num|p> <postfix>\n" if($#ARGV !=2);

my $fastqfile=$ARGV[0];
my $num=$ARGV[1];
my $postfix=$ARGV[2];

my $linenum=0;
open(File, $fastqfile) ||die "error: can't open $fastqfile.\n";
while(<File>){ $linenum++; }
close (File);

my $p=0;
if($num <= 1) {
    $p=$num;
} else {
    $p=4*$num/$linenum;
}

print "$p, $linenum, $num\n";
if($p > 1 || $p < 0){
    print "invalid p=$p\n";
    exit;
}

open(File, $fastqfile) ||die "error: can't open $fastqfile.\n";
open(OUT, ">$fastqfile-$postfix.fastq"); 
while(my $line = <File>){
    my $x = rand();
    if($x < $p){
	print OUT $line;
	$line = <File>;
	print OUT $line;
	$line = <File>;
	print OUT $line;
	$line = <File>;
	print OUT $line;
    }else{
	$line = <File>;
	$line = <File>;
	$line = <File>;
    }
}
close (File);
close (OUT);
