#!/usr/bin/perl -w

use strict;
use warnings;
use autodie;
$file=$ARGV[0];

$num=0;
open(ListFile, $file) ||die "error: can't open file.\n";
while($line = <ListFile>){
    next if($line eq "\n");
    chomp($line);
    my @clm = split(/\t/, $line);
    next if($clm[2] =~ /random/ || $clm[2] =~ /hap/ || $clm[2] =~ /chrUn/);
    $chr[$num] = $clm[2];
    $strand[$num] = $clm[3];
    $start_gene[$num] = $clm[4];
    $end_gene[$num] = $clm[5];
    $start_tr[$num] = $clm[6];
    $end_tr[$num] = $clm[7];
    $str[$num] = $line;
    $num++;
}
close (ListFile);

for($i=0;$i<$num;$i++){
    for($j=0;$j<$i;$j++){
	if($strand[$j] eq $strand[$i] && $chr[$j] eq $chr[$i]){
	    if(($strand[$j] eq "+" && $start_gene[$j] == $start_gene[$i]) || ($strand[$j] eq "-" && $end_gene[$j] == $end_gene[$i])){
		$str[$i] = "deleted";
		next;
	    }
	    if(($strand[$j] eq "+" && $start_tr[$j] == $start_tr[$i]) || ($strand[$j] eq "-" && $end_tr[$j] == $end_tr[$i])){
		$str[$i] = "deleted";
		next;
	    }
	}
    }
    if($str[$i] ne "deleted"){ print "$str[$i]\n";}
}
