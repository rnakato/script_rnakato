#!/usr/bin/perl -w

use strict;
use warnings;
use autodie;
die "randomextract_csfasta.pl <csfasta> <qual> <p>\n" if($#ARGV !=2);

$csfastafile=$ARGV[0];
$qualfile=$ARGV[1];
$p=$ARGV[2];

open(File1, $csfastafile) ||die "error: can't open $csfastafile.\n";
open(File2, $qualfile) ||die "error: can't open $qualfile.\n";
open(OUT1, ">$csfastafile-rand-$p.csfasta"); 
open(OUT2, ">$qualfile-rand-$p.qual");

while($line_csfasta = <File1>){
    if($line_csfasta =~ /#/){ next;} else{last;}
}
while($line_qual = <File2>){
    if($line_qual =~ /#/){ next;} else{last;}
}
&output();

while($line_csfasta = <File1>){
    $line_qual = <File2>;
    &output();
}

sub output{
    $x = rand();
    if($x < $p){
	print OUT1 $line_csfasta;
	print OUT2 $line_qual;
	$line_csfasta = <File1>;
	$line_qual = <File2>;
	print OUT1 $line_csfasta;
	print OUT2 $line_qual;
    }else{
	$line_csfasta = <File1>;
	$line_qual = <File2>;
    }
}

close (File1);
close (File2);
close (OUT1);
close (OUT2);
