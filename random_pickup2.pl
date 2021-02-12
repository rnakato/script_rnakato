#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
die "random_pickup2.pl <file> <number>\n" if($#ARGV !=1);

my $file=$ARGV[0];
my $number=$ARGV[1];

open(File, $file) ||die "error: can't open $file.\n";

my @filearray=();
while(<File>){
    next if($_ =~ /gene name/ || $_ eq "\n");
    push (@filearray, $line);
}
close (File);

my $num=0;
for(;;){
    my $x = int(rand()*$#filearray);
    if($filearray[$x] ne "used"){
        print $filearray[$x];
        $filearray[$x] = "used";
        $num++;
        if($num>=$number){ exit;}
    }else{
        next;
    }
}
