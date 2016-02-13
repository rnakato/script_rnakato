#! /usr/bin/perl -w

use strict;
use warnings;
use autodie;
open(IN, $ARGV[0]) || die;
while(<IN>) {
    next if($_ eq "\n");
    $_ =~ s/\s+/\t/g;
    print $_;
}
close IN;
