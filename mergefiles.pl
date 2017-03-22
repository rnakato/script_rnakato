#!/usr/bin/env perl

=head1 DESCRIPTION
 
    Parse stats output by bowtie1.
 
=head1 SYNOPSIS

    parsebowtielog.pl <file>

=cut

use strict;
use warnings;
use autodie;
use Path::Class;
use Getopt::Long qw/:config posix_default no_ignore_case bundling auto_help/;
use Pod::Usage qw/pod2usage/;

my @name;
my @rownames;
my @data;
my %Hashall;

for(my $i=0; $i<=$#ARGV; $i++) {
#    print "$ARGV[$i]\n";
    my $on=0;
    my $file = file($ARGV[$i]);
    my $fh = $file->open('r') or die $!;
    my %Hash;
    while(<$fh>){
	chomp;
	if($_ =~ /Making Jaccard index profile.../){
	    $on=1;
	    next;
	}
	next if(!$on);
	my @clm = split(/\t/, $_);
	$Hash{$clm[0]} = $clm[1];
	$Hashall{$clm[0]} = 1;
    }
    push @data, \%Hash;
    $fh->close;
}

print "bin";
for(my $j=0; $j<=$#ARGV; $j++) {
    print "\t$ARGV[$j]";
}
print "\n";
foreach my $key (sort { $a <=> $b } (keys %Hashall)){
    print "$key";
    for(my $j=0; $j<=$#ARGV; $j++) {
	if(exists($data[$j]{$key})) {
	    print "\t$data[$j]{$key}";
	}else{
	    print "\t0";
	}
    }
    print "\n";
}
