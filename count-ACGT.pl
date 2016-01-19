#!/usr/bin/perl -w

$len_all=0;
$len_nonN=0;
open(ListFile, $ARGV[0]) ||die "error: can't open $ARGV[0].\n";
while($line = <ListFile>){
    chomp $line;
    if($line =~ ">"){
    }else{
	chomp($line);
	$len_all += length($line);
	$len_nonN += $line =~ s/[ACGT]/[ACGT]/gi;
    }

}
close (ListFile);

print "ALL: $len_all\n";
print "ACGT: $len_nonN\n";
