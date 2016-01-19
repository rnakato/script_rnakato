#!/usr/bin/perl -w

$file=$ARGV[0];
open(ListFile, $file) ||die "error: can't open file.\n";
while($line = <ListFile>){
    next if($line eq "\n");
    chomp($line);
    my @clm = split(/\t/, $line);
    next if($clm[2] =~ /random/ || $clm[2] =~ /hap/ || $clm[2] =~ /chrUn/);
    print "$line\n";
}
close (ListFile);
