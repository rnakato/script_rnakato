#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
$file=$ARGV[0];
$gt = $ARGV[1];
$window=$ARGV[2];

open(File,$gt) ||die "error: can't open $gt.\n";
while(<File>){
    next if($_ eq "\n");
    chomp;
    my @clm = split(/\t/, $_);
    $length{$clm[0]} = $clm[1];
} 
close (File);


foreach $chr (sort (keys %length)){
    my $winnum = $length{$chr}/$window +1;
    for(0 .. $winnum){$array[$_]=0;}
    open(File,$file) ||die "error: can't open $file.\n";
    while(<File>){
	next if($_ eq "\n");
	chomp;
	my @clm = split(/\t/, $_);
	if($clm[0] eq $chr){
	    for($i=$clm[1];$i<$clm[2];$i++){
		$array[int($i/$winnum)]++;
	    }
	}
    } 
    close(File);
    for(0 .. $winnum){
	$array[$_] /= $winnum;
	printf("%s\t%d\t%.2f\n", $chr, $_*$window, $array[$_]);
    }
    undef @array;
}
