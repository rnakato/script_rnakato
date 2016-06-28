#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
die "random_pickup2_forfa.pl <file> <number>\n" if($#ARGV !=1);

my $file=$ARGV[0];
my $number=$ARGV[1];

my $wc = `wc -l $file`;
my @c = split(/ /, $wc);
my $nread = $c[0]/2;

open(File, $file) ||die "error: can't open $file.\n";
while(my $line = <File>){
    next if($line eq "\n");
    if($line =~ />/){
	my $line2 = <File>;
	if(int(rand($nread)) <= $number) {
	    print $line;
	    print $line2;
	}
    }
}
close (File);


