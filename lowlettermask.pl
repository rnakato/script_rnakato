#!/usr/bin/perl -w
# lowlettermask.pl
# fasta形式の配列で小文字の部分をNでマスクします。


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
