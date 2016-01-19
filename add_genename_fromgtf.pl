#! /usr/bin/perl -w

die "add_genename_fromgtf.pl <file> <gtf>\n" if($#ARGV !=1);

$file=$ARGV[0];
$gtf=$ARGV[1];
open(ListFile, $gtf) ||die "error: can't open $gtf.\n";
while(<ListFile>){
    next if($_ eq "\n");
    chomp;
    if($_ =~ /(.+); gene_name "(.+)"; p_id (.+) transcript_id "(.+)"; tss_id (.+)/){
	$Hash{$4}=$2;
    }elsif($_ =~ /(.+); gene_name "(.+)";(.*) transcript_id "(.+)"; tss_id (.+)/){
	$Hash{$4}=$2;
    }
}
close (ListFile);

open(ListFile, $file) ||die "error: can't open $file.\n";
while(<ListFile>){
    next if($_ eq "\n");
    chomp;
    my @clm = split(/\t/, $_);
    if(exists($Hash{$clm[0]})){
	print "$Hash{$clm[0]}\t$_\n";
    }else{
	print "\t$_\n";
    }
}
close (ListFile);
