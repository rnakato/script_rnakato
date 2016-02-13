#!/usr/bin/perl -w

use strict;
use warnings;
use autodie;

$filename = $ARGV[0];

open(InputFile,$filename) ||die "error: can't open file.\n";
while($line = <InputFile>){
    
    # 配列についてのデータの行
    if($line =~ ">"){
	print $line;
    }
    
    #　空行
    elsif($line eq "\n"){
	next;
    }
    
    # 配列の行
    else{
	$line =~ tr/a-z/N/;
	print $line;
    }
	
}
  
close (InputFile);
