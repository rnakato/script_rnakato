#! /usr/bin/perl -w 

open(IN, $ARGV[0]) || die;
while(<IN>) {
    next if($_ eq "\n");
    my @clm = split(/\t/, $_);
    printf("%d\t%f\n", $clm[0]+1, $clm[1]);
}
close IN;
