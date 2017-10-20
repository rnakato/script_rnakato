#!/usr/bin/env perl
use strict;
use warnings;

my $filename=$ARGV[0];

my $num = `wc -l $filename | cut -f1 -d' '`;

open(FILE, ">>", $filename) or die;
for (my $i=0;$i<$num-1;$i++) {
    printf FILE "CONECT%5d%5d\n", $i, $i+1;
}
close(FILE)
