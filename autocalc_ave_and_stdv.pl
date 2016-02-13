#! /usr/bin/perl -w

use strict;
use warnings;
use autodie;
use Statistics::Lite qw(:all);

$num=0;
$repeatnum=1000;
$gene=$ARGV[0];
$input=$ARGV[1];
$refgenenum=$ARGV[2];
$param=$ARGV[3];

for($i=1; $i<=$repeatnum; $i++){
    $ref="random1000times/random${refgenenum}genes_$i.txt";
    my $str = `compare_bs2tss -g_ens $gene -b $input -gl $ref -1line -showpeaknum -$param`;
    chomp $str;
    @clm= split(/\t/, $str);
    for($j=0; $j<=$#clm; $j++){
	$array[$j][$num] = $clm[$j];
#	print "$array[$j][$num]\t";
    }
#    print "\n";
    $num++;
}

for($i=0; $i<=$#clm; $i++){
    $mean= mean @{$array[$i]};
    print "$mean\t";
}
print "\n";

for($i=0; $i<=$#clm; $i++){
    $stdv= stddev @{$array[$i]};
    print "$stdv\t";
}
print "\n";
