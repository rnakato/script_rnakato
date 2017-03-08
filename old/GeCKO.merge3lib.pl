#!/usr/bin/env perl
use strict;
use warnings;
use autodie;
die "merge3lib.pl <file>\n" if($#ARGV !=0);

my $linenum=0;
open(File, $ARGV[0]) ||die "error: can't open $ARGV[0].\n";
my %Hash;
while(<File>){
    next if($_ =~ /gene/);
    my @clm = split(/\t/, $_);
    $Hash{$clm[0]} += $clm[3];
}
close (File);


foreach my $tag (keys(%Hash)){
    print "$tag\t$Hash{$tag}\n";
}
