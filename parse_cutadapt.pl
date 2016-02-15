#!/usr/bin/perl -w

use strict;
use warnings;
use autodie;
my $all;
my $ad;
my $rad;
my $short;
my $rshort;
my $pass;
my $rpass;
my $allbp;
my $passbp;
my $rpassbp;
open(File, $ARGV[0]) ||die "error: can't open $ARGV[0].\n";
while(<File>){
    next if($_ eq "\n");
    chomp;
    if($_ =~ /Total reads processed:\s+(.+)/){
	$all=$1;
    }elsif($_ =~ /Reads with adapters:\s+(.+) \((.+)%\)/){
	$ad=$1;
	$rad=$2;
    }elsif($_ =~ /Reads that were too short:\s+(.+) \((.+)%\)/){
	$short=$1;
	$rshort=$2;
    }elsif($_ =~ /Reads written \(passing filters\):\s+(.+) \((.+)%\)/){
	$pass=$1;
	$rpass=$2;
    }elsif($_ =~ /Total basepairs processed:\s+(.+) bp/){
	$allbp=$1;
    }elsif($_ =~ /Total written \(filtered\):\s+(.+) bp \((.+)%\)/){
	$passbp=$1;
	$rpassbp=$2;
    }
}

print STDERR "Total reads\twith adapters\t%\ttoo short\t%\tpassing filters\t%\tTotal bases\tTotal written\t%\n";
print "$all\t$ad\t$rad\t$short\t$rshort\t$pass\t$rpass\t$allbp\t$passbp\t$rpassbp\n";
