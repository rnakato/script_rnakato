#!/usr/bin/env perl

=head1 DESCRIPTION

    describe DESCRIPTION

=head1 SYNOPSIS

    % getBedWidth.pl <bed>

=cut

use strict;
use warnings;
use autodie;
use Path::Class;;
use Pod::Usage qw/pod2usage/;
pod2usage(2) if($#ARGV !=0);
my $file1=$ARGV[0];

my $file = file($file1);
my $fh = $file->open('r') or die $!;
my $len=0;
while(<$fh>){
    next if($_ eq "\n" || $_ =~ /start/);
    chomp;
    my @clm = split(/\s/, $_);
    $len += $clm[2] - $clm[1];
}
$fh->close;

print "$len\n";
