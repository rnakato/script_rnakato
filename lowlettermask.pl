#!/usr/bin/perl -w

use strict;
use warnings;
use autodie;

open(File,$ARGV[0]) ||die "error: can't open file.\n";
while(<File>){
    next if($_ eq "\n");
    if($_ =~ ">"){
	print $_;
    }else{
	$_ =~ tr/a-z/N/;
	print $_;
    }
}
close(File);
