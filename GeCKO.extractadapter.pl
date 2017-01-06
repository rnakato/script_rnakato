#!/usr/bin/env perl
use strict;
use warnings;
use autodie;
die "extractadapter.pl <fastq> <adapter>\n" if($#ARGV !=1);

my $fastqfile=$ARGV[0];
my $adapter=$ARGV[1];

my $linenum=0;
open(File, $fastqfile) ||die "error: can't open $fastqfile.\n";
while(<File>){ $linenum++; }
close (File);
$linenum /= 4;

open(File, $fastqfile) ||die "error: can't open $fastqfile.\n";
my $n=0;
my $adapternum=0;
my $short=0;
my %Hash;
while(my $line = <File>){
    if($n%4 == 1){
	if($line =~ /(.*)$adapter(.+)/) {
	    if(length($2)>=20){
		$Hash{substr($2, 0, 20)}++;
		$adapternum++;
	    }else{
		$short++;
	    }
	}
    }
    $n++;
}
close (File);

open(OUT, ">$fastqfile.count");
foreach my $tag (keys(%Hash)){
    print OUT "$tag\t$Hash{$tag}\n";
}
close (OUT);

my $per = $adapternum/$linenum;
my $pshort = $short/$linenum;
print "read\twith adapter\tprop\ttoo short\tprop\n";
print "$linenum\t$adapternum\t$per\t$short\t$pshort\n";
