#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
die "random_pickup4bam.pl <file> <num>\n" if($#ARGV !=1);

my $file=$ARGV[0];
my $num=$ARGV[1];

open(FILE, "samtools view -F 0x04 -b $file | samtools view |");
my $nread=0;
while (<FILE>) {
    $nread++;
}
close FILE;
my $p = $num/$nread;

open(FILE, "samtools view -F 0x04 -b $file | samtools view -h |");
while (<FILE>) {
    print $_ if($_ =~/@/);
    my $x = rand();
    if($x < $p){ print $_;}
}
close FILE;
