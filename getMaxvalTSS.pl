#!/usr/bin/env perl

=head1 DESCRIPTION

    describe DESCRIPTION

=head1 SYNOPSIS

    % sample.pl [options] <filename>

    Options:
    --binsize=<int>
    --pair

=cut

use strict;
use warnings;
use autodie;
use Path::Class;
use Getopt::Long qw/:config posix_default no_ignore_case bundling auto_help/;
use Pod::Usage qw/pod2usage/;

my $nsample=0;
GetOptions(
    "n=i" => \$nsample,
) or pod2usage(1);

my $filename=shift;
pod2usage(2) unless $filename;

my $file = file($filename);
my $fh = $file->open('r') or die $!;
my %Hash=();
my %max=();

while(<$fh>){
    next if($_ eq "");
    chomp;
    my @clm = split(/\t/, $_);
    my $sum=0;
    for(my $i=0; $i<$nsample; $i++) {
	$sum += $clm[$i+17];
    }
    if(!exists($Hash{$clm[0]}) || $sum > $max{$clm[0]}) {
	$Hash{$clm[0]} = $_;
	$max{$clm[0]} = $sum;
    }
}
$fh->close;

while (my ($key, $value) = each(%Hash)){
  print "$value\n";
}
