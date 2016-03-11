#! /usr/bin/perl -w 

open(IN, $ARGV[0]) || die;
while(<IN>) {
    next if($_ eq "\n");
    print "chr$_";
}
close IN;
