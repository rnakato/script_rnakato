#! /usr/bin/perl -w

$n=0;
$totallen=0;
open(IN, $ARGV[0]) || die;
while(<IN>) {
    next if($_ eq "\n");
    $n++;
    if($n%4==2){
	chomp;
	$totallen += length($_);
    }
}
close IN;
$nread=$n/4;

$n2=0;
$totallen2=0;
open(IN, $ARGV[1]) || die;
while(<IN>) {
    next if($_ eq "\n");
    $n2++;
    if($n2%4==2){
	chomp;
	$totallen2 += length($_);
    }
}
close IN;
$nread2=$n2/4;
if($nread>0){$p =$nread2*100/$nread;}
else{$p=0;}
if($totallen>0){$p2 =$totallen2*100/$totallen;}
else{$p2=0;}
print "$nread\t$nread2\t$p\t$totallen\t$totallen2\t$p2\n";
