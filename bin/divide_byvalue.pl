#! /usr/bin/perl

$filename=$ARGV[0];
$linenum=$ARGV[1];
$thre=$ARGV[2];
$get=$ARGV[3];

undef %Hash;

open(IN, $filename) || die "cannot open $filename.";
while(<IN>) {
    next if($_ eq "\n");
    chomp;
    @clm= split(/\t/, $_);
    if($get eq "-up"){
	print "$_\n" if($clm[$linenum] > $thre);
    }else{
	print "$_\n" if($clm[$linenum] <= $thre);
    }
}
close IN;

