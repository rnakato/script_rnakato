#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
die "random_pickup.pl <file> <p>\n" if($#ARGV !=1);

my $file = $ARGV[0];
my $p = $ARGV[1];

open(File, $file) ||die "error: can't open $file.\n";
while(<File>){
    my $x = rand();
    if($x < $p){ print $_;}
}
close (File);
