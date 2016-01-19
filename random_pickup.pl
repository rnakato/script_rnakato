#!/usr/bin/perl -w

die "random_pickup.pl <file> <p>\n" if($#ARGV !=1);

$file=$ARGV[0];
$p=$ARGV[1];

open(File, $file) ||die "error: can't open $file.\n";

while($line = <File>){
    $x = rand();
    if($x < $p){ print $line;}
}
close (File);
