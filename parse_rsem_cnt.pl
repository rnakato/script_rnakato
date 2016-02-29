#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
open(File, $ARGV[0]) ||die "error: can't open $ARGV[0].\n";
$line = <File>;
chomp($line);
if($line =~ /([0-9]+) ([0-9]+) ([0-9]+) ([0-9]+)/){
    $unmap=$1;
    $mapped=$2;
    $filtered=$3;
    $total=$4;
    $rmapped = $mapped*100/$total;
    $runmap = $unmap*100/$total;
}

$line = <File>;
chomp($line);
if($line =~ /([0-9]+) ([0-9]+) ([0-9]+)/){
    $uniq=$1;
    $multi=$2;
    $uncertain=$3;
}
$runiq = $uniq*100/$mapped;
$rmulti = $multi*100/$mapped;

$line = <File>;
chomp($line);
if($line =~ /([0-9]+) ([0-9]+)/){
    $nHits=$1;
    $type=$2;
}
if($type==0){$str="single-end read, no quality";}
elsif($type==1){$str="single-end read, with quality score";}
elsif($type==2){$str="paired-end read, no quality score";}
elsif($type==3){$str="paired-end read, with quality score";}

print STDERR "Sequenced\tmapped\t(%)\tunique\t(%)\tmultiple\t(%)\tUncertain\tunmapped\t(%)\tfiltered\ttotal alignments\tread type\n";
print "$total\t$mapped\t$rmapped\t$uniq\t$runiq\t$multi\t$rmulti\t$uncertain\t$unmap\t$runmap\t$filtered\t$nHits\t$str\n";

