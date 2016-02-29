#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
die "random_pickup2.pl <file> <number>\n" if($#ARGV !=1);

$file=$ARGV[0];
$number=$ARGV[1];

open(File, $file) ||die "error: can't open $file.\n";

@filearray=();
while($line = <File>){
    next if($line =~ /gene name/ || $line eq "\n");
    push (@filearray, $line);
}
close (File);

for(;;){
    $x = int(rand()*$#filearray);
    if($filearray[$x] ne "used"){
	print $filearray[$x];
	$filearray[$x] = "used";
	$num++;
	if($num>=$number){ exit;}
    }else{
	next;
    }
}



