#! /usr/bin/perl -w

open(IN, $ARGV[0]) || die;
while(<IN>) {
    chomp;
    @clm= split(/\s+/, $_);
    print "$clm[0]\t$clm[1]\t$clm[2]\n";
}
close IN;
