#!/usr/bin/perl -w

$file=$ARGV[0];
open(ListFile, $file) ||die "error: can't open file.\n";
while($line = <ListFile>){
    next if($line eq "\n");
    chomp($line);
    my @clm = split(/\t/, $line);
    if($clm[1] eq $ARGV[1]){
	print "$line\n";
    }
}
close (ListFile);
