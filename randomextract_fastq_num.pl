#!/usr/bin/perl -w

use strict;
use warnings;
use autodie;
die "randomextract_fastq.pl <fastq> <num> <postfix>\n" if($#ARGV !=2);

$fastqfile=$ARGV[0];
$num=$ARGV[1];
$postfix=$ARGV[2];

$linenum=0;

open(File1, $fastqfile) ||die "error: can't open $fastqfile.\n";
while($line = <File1>){
    $linenum++;
}
close (File1);

$p=4*$num/$linenum;

#print "$p, $linenum, $num\n";
if($p > 1 || $p < 0){
    print "invalid p=$p\n";
    exit;
}

open(File1, $fastqfile) ||die "error: can't open $fastqfile.\n";
open(OUT1, ">$fastqfile-$postfix.fastq"); 
while($line = <File1>){
    $x = rand();
    if($x < $p){
	print OUT1 $line;
	$line = <File1>;
	print OUT1 $line;
	$line = <File1>;
	print OUT1 $line;
	$line = <File1>;
	print OUT1 $line;
    }else{
	$line = <File1>;
	$line = <File1>;
	$line = <File1>;
    }
}
close (File1);
close (OUT1);
