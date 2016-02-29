#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
die "random_pickup_forfa.pl <file> <p>\n" if($#ARGV !=1);

$file=$ARGV[0];
$p=$ARGV[1];

open(File, $file) ||die "error: can't open $file.\n";

while($line = <File>){
    $x = rand();
    if($x < $p){
	print $line;
	$line = <File>;
	print $line;
    }else{
	$line = <File>;	
    }
}
close (File);



