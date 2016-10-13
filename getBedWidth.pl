#!/usr/bin/env perl

=head1 DESCRIPTION

    describe DESCRIPTION

=head1 SYNOPSIS

    % getBedWidth.pl <bed>

=cut

use strict;
use warnings;
use autodie;
use Path::Class;
use Statistics::Lite qw(:all);
use Pod::Usage qw/pod2usage/;
pod2usage(2) if($#ARGV !=0);
my $file1=$ARGV[0];

my $file = file($file1);
my $fh = $file->open('r') or die $!;
my @array=();
while(<$fh>){
    next if($_ eq "\n" || $_ =~ /start/ || $_ =~ /\#/);
    chomp;
    my @clm = split(/\s/, $_);
    push (@array, $clm[2] - $clm[1]);
}
$fh->close;

printf("%d\t%.1f\t%.1f\n", (sum @array), (mean @array), (variance @array));
