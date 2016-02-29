#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
open(IN, $ARGV[0]) || die "error: cannot open $ARGV[0].";
while(<IN>) {
    next if($_ eq "\n");
    chomp;
    if($_ =~ /<binding site> all: (.+), upstream: (.+), downstream: (.+), genic: (.+), intergenic: (.+), all-intergenic: (.+)/){
	printf("%d\t%d\t%.1f\t%d\t%.1f\t%d\t%.1f\t%d\t%.1f\n",$1,$2, $2*100/$1,$3, $3*100/$1,$4, $4*100/$1, $5, $5*100/$1);
	exit;
    }
}
close IN;
