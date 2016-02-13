#!/usr/bin/perl -w

use strict;
use warnings;
use autodie;

$filename = $ARGV[0];

open(InputFile,$filename) ||die "error: can't open file.\n";
while($line = <InputFile>){
    
    # $BG[Ns$K$D$$$F$N%G!<%?$N9T(B
    if($line =~ ">"){
	print $line;
    }
    
    #$B!!6u9T(B
    elsif($line eq "\n"){
	next;
    }
    
    # $BG[Ns$N9T(B
    else{
	$line =~ tr/a-z/N/;
	print $line;
    }
	
}
  
close (InputFile);
