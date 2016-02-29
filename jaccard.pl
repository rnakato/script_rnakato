#!/usr/bin/env perl

=head1 DESCRIPTION

    describe DESCRIPTION

=head1 SYNOPSIS

    % jaccard.pl [options] -f <filename> -n <name> [-f <filename> -n <name> ...]

    Options:
    --prop

=cut

use strict;
use warnings;
use autodie;
use Getopt::Long qw/:config posix_default no_ignore_case bundling auto_help/;
use Pod::Usage qw/pod2usage/;

my @file;
my @name;
my $pair=0;
GetOptions(
    "file|f=s@" => \@file,
    "name|n=s@" => \@name,
    "prop|p" => \$pair
) or pod2usage(1);

die "different num: -f and -n.\n" if($#file != $#name);

foreach (@name){
    print "\t$_";
}
print "\n";

for(my $i=0;$i<=$#file;$i++){
    my $f1 = $file[$i];
    print "$name[$i]";
    foreach my $f2 (@file){
	system("sort -k1,1 -k2,2n $f1 > $f1.sorttemp");
	system("sort -k1,1 -k2,2n $f2 > $f2.sorttemp");
	my $jaccard=`bedtools jaccard -a $f1.sorttemp -b $f2.sorttemp | grep -v jaccard | cut -f3 | tr -d '\n'`;
	print "\t$jaccard";
    }
    print "\n";
}

foreach my $f2 (@file){
    unlink "$f2.sorttemp";
}
