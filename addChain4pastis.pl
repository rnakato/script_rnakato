#!/usr/bin/env perl
use strict;
use warnings;

my $filename=$ARGV[0];
my $output=$filename . ".addCONECT.pdb";

my $num = `wc -l $filename | cut -f1 -d' '`;
system("cp $filename $output");

open(FILE, ">>", $output) or die;
for (my $i=0;$i<$num-1;$i++) {
    printf FILE "CONECT%5d%5d\n", $i, $i+1;
}
close(FILE)
