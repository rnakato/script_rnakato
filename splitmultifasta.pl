#!/usr/bin/perl -w

$filename = $ARGV[0];
$dir = $ARGV[1];
$head ="";
$seq = "";
open(InputFile,$filename) ||die "error: can't open file.\n";
while(<InputFile>){
    next if($_ eq "\n");
    chomp;
    if($_ =~ />(.+)/){
	if($seq ne ""){
	    open(OUT,">$dir/$filename.fa");
	    print OUT ">$filename\n";
	    print OUT "$seq\n";
	    $seq = "";
	    close(OUT);
	}
	$head =$1;
	my @str = split(/ /, $head);
	$filename = $str[0];
	print "$filename\n"
    }else{
	$seq .= $_;
    }
} 
close (InputFile);

if($seq ne ""){
    open(OUT,">$dir/$filename.fa");
    print OUT ">$filename\n";
    print OUT "$seq\n";
    $seq = "";
    close(OUT);
}
