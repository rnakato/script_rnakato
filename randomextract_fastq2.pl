#!/usr/bin/perl -w

die "randomextract_fastq2.pl <fastq> <num_def> <num_all> <outputname>\n" if($#ARGV !=3);

$fastqfile=$ARGV[0];
$num_def=$ARGV[1];
$num_all=$ARGV[2];
$output=$ARGV[3];

open(File1, $fastqfile) ||die "error: can't open $fastqfile.\n";
open(OUT1, ">$output"); 

$p=$num_def/$num_all;
if($p>1){
    print "$num_def > $num_all\n";
    exit;
}

while($line = <File1>){
    $x = rand();
    if($x < $p){
	print OUT1 $line;
	$line = <File1>;
	print OUT1 $line;
	$line = <File1>;
	print OUT1 $line;
	$line = <File1>;
	print OUT1 $line;
    }else{
	$line = <File1>;
	$line = <File1>;
	$line = <File1>;
    }
}
close (File1);
close (OUT1);
