#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
die "random_pickup4bam.pl <file> <num>\n" if($#ARGV !=1);

my $file=$ARGV[0];
my $num=$ARGV[1];

#open(FILE, "samtools view -F 0x04 -b $file | samtools view |");
#my $nread=0;
#while (<FILE>) {
#    $nread++;
#}
#close FILE;
#chomp(my $nread = `bamtools count -in $file`);
chomp(my $result = `bamtools stats -in $file | head -n7 | tail -n1`);
my $nread=0;
if($result =~ /(.+)\s+([0-9]+)\s+(.+)/) {
    $nread = $2;
}
my $p = $num/$nread;

my $on=0;
open(FILE, "samtools view -F 0x04 -b $file | samtools view -h |");
while (<FILE>) { 
    if($on) {
	my $x = rand(1);
	print $_ if($x < $p);
    }else {
	$on=1 if($_ =~/\@PG/);
	print $_;
	next;
    }
}
close FILE;

