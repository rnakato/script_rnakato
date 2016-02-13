#!/usr/bin/perl -w

use strict;
use warnings;
use autodie;
die "random_pickup2_forfa.pl <file> <number>\n" if($#ARGV !=1);

$file=$ARGV[0];
$number=$ARGV[1];

open(File, $file) ||die "error: can't open $file.\n";

@headarray=(); @faarray=();
while($line = <File>){
    next if($line eq "\n");
    if($line =~ />/){
	push (@headarray, $line);
	$line = <File>;
	push (@faarray, $line);
    }
}
close (File);

for(;;){
    $x = int(rand()*$#headarray);
    if($headarray[$x] ne "used"){
	print $headarray[$x];
	print $faarray[$x];
	$headarray[$x] = "used";
	$num++;
	if($num>=$number){ exit;}
    }else{
	next;
    }
}



