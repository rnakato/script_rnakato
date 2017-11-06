#!/usr/bin/env perl
use strict;
use warnings;

my $filename=$ARGV[0];
my $bedgraph=$ARGV[1];
my $start=$ARGV[2];
my $output=$filename . ".addCompartment.pdb";

open(File, $bedgraph) ||die "error: can't open $bedgraph\n";
my @compartment = ();
while(<File>) {
    next if($_ eq "\n");
    chomp;
    my @clm = split(/\t/, $_);
    if($clm[3]>=0) {
	push(@compartment, "A");
    } else {
	push(@compartment, "B");
    }
}
close (File);

#for(my $i=0;$i<=$#compartment;$i++){
#    print "$compartment[$i]\n";
#}

open(FILE, ">", $output) or die;
open(PDB, $filename) ||die "error: can't open $filename\n";
my $num = $start;
while(<PDB>) {
    next if($_ eq "\n");
    if($compartment[$num] eq "B") {
	$_ =~ s/A       /B       /g;
    }
    printf FILE "$_";
    $num++;
}
close(FILE);
close(PDB);
