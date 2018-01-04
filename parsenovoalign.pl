#!/usr/bin/env perl

#use strict;
#use warnings;
#use autodie;
open(File, $ARGV[0]) ||die "error: can't open $ARGV[0].\n";
while(<File>){
    next if($_ eq "\n");
    chomp;
    if($_ =~ /#\s+Read Sequences:\s+([0-9]+)/){
	$all=$1;
    }elsif($_ =~ /#\s+Unique Alignment:\s+([0-9]+) \(\s*(.+)%\)/){
	$uniq=$1;
	$runiq=$2;
    }elsif($_ =~ /#\s+Multi Mapped:\s+([0-9]+) \(\s*(.+)%\)/){
	$multi=$1;
	$rmulti=$2;
    }elsif($_ =~ /#\s+No Mapping Found:\s+([0-9]+) \(\s*(.+)%\)/){
	$unmap=$1;
	$runmap=$2;
    }elsif($_ =~ /#\s+Homopolymer Filter:\s+([0-9]+) \(\s*(.+)%\)/){
	$homo=$1;
	$rhomo=$2;
    }elsif($_ =~ /#\s+Read Length:\s+([0-9]+) \(\s*(.+)%\)/){
	$read=$1;
	$rread=$2;
    }
}
print "$all\t$uniq\t$runiq\t$multi\t$rmulti\t$unmap\t$runmap\t$homo\t$rhomo\t$read\t$rread\n";
