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

my $length=50000;
GetOptions(
    "length|l=i" => \$length,
) or pod2usage(1);

my $filename=shift;
pod2usage(2) unless $filename;

my $file = file($filename);
my $fh = $file->open('r') or die $!;
while(<$fh>){
    next if($_ eq "" || $_ =~ /chr/);
    chomp;
    my @clm = split(/\t/, $_);
    printf("%s\t%d\t%d\n",$clm[0], $clm[1]-$length/2, $clm[1]+$length/2);
    printf("%s\t%d\t%d\n",$clm[0], $clm[2]-$length/2, $clm[2]+$length/2);
}
$fh->close;
