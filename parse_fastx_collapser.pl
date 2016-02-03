#!/usr/bin/perl -w

open(File, $ARGV[0]) ||die "error: can't open $ARGV[0].\n";
while(<File>){
    next if($_ eq "\n");
    chomp;
    if($_ =~ /Input:\s+([0-9]+) sequences(.+)/){
	$all=$1;
    }elsif($_ =~ /Output:\s+([0-9]+) sequences(.+)/){
	$out=$1;
    }
}
print "$all\t$out\n";
