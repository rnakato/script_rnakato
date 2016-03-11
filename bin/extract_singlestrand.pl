#! /usr/bin/perl -w

open(IN, $ARGV[0]) || die;
while(<IN>) {
    next if($_ eq "\n");
    chomp;
    @clm= split(/\t/, $_);
    if($ARGV[1] eq "+"){
	print "$_\n" if ($clm[1] eq "+");
    }else{
	print "$_\n" if ($clm[1] eq "-");
    }
}
close IN;
