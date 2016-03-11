#!/usr/bin/perl -w

$filename = $ARGV[0];
$len=0;
$lenall=0;
$gc_count=0;
$Ncount=0;

open(InputFile,$filename) ||die "error: can't open file.\n";
while($line = <InputFile>){
    next if($line eq "\n");
    chomp $line;
    if($line =~ ">"){
	if($len){
	    $p = $gc_count/$len;
	    $e = $p*150;
	    print "$len\t$gc_count\t$p\t$e\t$Ncount\n";
	}
	$lenall += $len;
	$len=0;
	$gc_count=0;
	$Ncount=0;
	if($' =~ /([A-Za-z0-9_]+)\s(.+)/){ $name = $1;}
	else{ $name = $';}
	print "$name\t";
	next;
    }else{
	chomp($line);
	$len += length($line);
	$gc_count += ($line =~ tr/cgCG/cgCG/);
	$Ncount += ($line =~ tr/N/N/);
    }
} 
close (InputFile);

$p = $gc_count/$len;
$e = $p*150;
print "$len\t$gc_count\t$p\t$e\t$Ncount\n";
