#!/usr/bin/perl -w

$filename = $ARGV[0];
$length = $ARGV[1];
open(ListFile,$filename) ||die "error: can't open file.\n";
$line = <ListFile>;
$line = <ListFile>;
while($line = <ListFile>){
    if($line eq "\n" || $line =~ /#/){next;}
    chomp($line);
    my @clm = split(/ /, $line);
    my $med = ($clm[2]+$clm[3])/2;
    my $start = $clm[2] - $length;
    my $end = $clm[3] + $length;
    print "$clm[0]\t$start\t$end\t$med\t$clm[5]\t$clm[1]\n"
}
close (ListFile);
