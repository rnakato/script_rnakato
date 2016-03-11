#! /usr/bin/perl -w

use Getopt::Long;
use Scalar::Util qw( looks_like_number ); 

$genefile=$ARGV[0];
$expfile=$ARGV[1];
$linenum=$ARGV[2];
$output_notshown=0; $output_expressed=0;
GetOptions('notshown' => \$output_notshown, 'expressed' => \$output_expressed);

open(IN, $genefile) || die;
while(<IN>){
    next if($_ eq "\n");
    chomp;
    @clm= split(/\t/, $_);
    $Hash{$clm[0]}=1;
}
close IN;

open(IN, $expfile) || die;
while(<IN>){
    next if($_ eq "\n");
    chomp;
    @clm= split(/\t/, $_);
    $Hash_exp{$clm[0]} = $clm[$linenum];
}
close IN;

if($output_notshown){
    foreach $name (keys %Hash_exp){
	if(!exists($Hash{$name})){
	    if($output_expressed){
		if(looks_like_number($Hash_exp{$name}) && $Hash_exp{$name}>0){print "$Hash_exp{$name}\n";}
	    }else{
		if(looks_like_number($Hash_exp{$name})){print "$Hash_exp{$name}\n";}
	    }
	}
    }
}

foreach $name (keys %Hash){
    if(exists($Hash_exp{$name})){
	if($output_expressed){
	    if($Hash_exp{$name}>0){print "$Hash_exp{$name}\n";}
	}else{
	    print "$Hash_exp{$name}\n";
	}
    }
}
