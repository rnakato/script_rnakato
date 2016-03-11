#!/usr/bin/perl -w

$file=$ARGV[0];
open(ListFile, $file) ||die "error: can't open file.\n";
$on=0;
$ncol=0;
while(<ListFile>){
    next if($_ eq "\n");
    chomp;
    my @clm = split(/\t/, $_);
    if(!$on){
	for($i=0;$i<=$#clm;$i++){
	    if($clm[$i] eq "locus"){
		$ncol=$i;
		print "chromosome\tstart\tend";
	    }else{print "$clm[$i]";}
	    if($i==$#clm){
		print "\n";
	    }
	    else{
		print "\t";
	    }
	}
	$on=1;
    }else{
	for($i=0;$i<=$#clm;$i++){
	    if($i==$ncol){
		print "$1\t$2\t$3" if($clm[$i] =~ /(.+):(.+)-(.+)/);
	    }else{
		print "$clm[$i]";
	    }
	    if($i==$#clm){
		print "\n";
	    }
	    else{
		print "\t";
	    }
	}
    }
}
close (ListFile);
