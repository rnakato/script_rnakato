#! /usr/bin/perl -w

$n1=0; $n2=0;

open(IN, $ARGV[0]) || die;
while(<IN>) {
    next if($_ eq "\n");
    chomp;
    @clm= split(/\t/, $_);
    $Hash1{$clm[0]}=1;
    $n1++;
}
close IN;

open(IN, $ARGV[1]) || die;
while(<IN>) {
    next if($_ eq "\n");
    chomp;
    @clm= split(/\t/, $_);
    $Hash2{$clm[0]}=1;
    $n2++;
}
close IN;

$nshare=0;
foreach $name (keys(%Hash1)){
    if(exists($Hash2{$name})){
	print "$name\n";
	$nshare++;
    }
}
print "$n1, $n2, $nshare\n";
