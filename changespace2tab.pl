#! /usr/bin/perl -w

use strict;
use warnings;
use autodie;
$mapfile=$ARGV[0];
open(IN, $mapfile) || die "error: cannot open $mapfile.";
while(<IN>) {
    next if($_ eq "\n");
    chomp;
    $_ =~ s/\s+/\t/g;
    print "$_\n";
}
close IN;
