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

my $nrow;
for(my $i=0; $i<=$#ARGV; $i++) {
    $name[$i] = $ARGV[$i];
#    print "$ARGV[$i]\n";

    $nrow=0;
    my $file = file($ARGV[$i]);
    my $fh = $file->open('r') or die $!;
    while(<$fh>){
	chomp;
	next if($_ =~ /Type/);
	my @clm = split(/\t/, $_);
	$rownames[$nrow] = $clm[0];
	$data[$i][$nrow] = $clm[5];
	$nrow++;
    }
    $fh->close;
}


for(my $i=0; $i<=$#ARGV; $i++) {
    print "\t$name[$i]";
}
print "\n";


for(my $i=0; $i<$nrow; $i++) {
    print "$rownames[$i]";
    for(my $j=0; $j<=$#ARGV; $j++) {
	print "\t$data[$j][$i]";
    }
    print "\n";
}
