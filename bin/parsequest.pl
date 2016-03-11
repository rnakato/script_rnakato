#!/usr/bin/perl -w

$filename = $ARGV[0];
open(ListFile,$filename) ||die "error: can't open file.\n";
while($line = <ListFile>){
    if($line eq "\n"){next;}
    chomp($line);
    if($line =~ /chr/){
	my @clm = split(/ /, $line);
	if($clm[0] =~ /R/){
	    if($clm[2] =~ /(.+)-(.+)/){
		print "$clm[1]\t$1\t$2\t$clm[26]\n";
	    }
	}
    }

}
close (ListFile);
