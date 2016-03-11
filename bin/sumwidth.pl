#!/usr/bin/perl -w

open(File, $ARGV[0]) ||die "error: can't open $ARGV[0].\n";
<File>;
$sum=0;
while(<File>){
    next if($_ eq "\n");
    chomp;
    my @clm = split(/\t/, $_);
    $sum += $clm[4];
}
close(File);

print "$sum\n";
