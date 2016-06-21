#!/usr/bin/env perl

=head1 NAME
    parse file output from uniq command
=head1 SYNOPSIS
    parseuniq.pl [--sort] <file>
=cut

use strict;
use warnings;
use autodie;
use Path::Class;
use Array::Utils qw(unique);
use Getopt::Long qw(:config posix_default bundling no_ignore_case auto_help);
use Pod::Usage qw(pod2usage);
my $filename = shift;
pod2usage unless $filename;

my $file = file($filename);
my $fh = $file->open('r') 
    or pod2usage(2);
while(<$fh>){
    next if($_ eq "\n" || $_ =~ /#rank/);
    chomp;
    my @clm = split(/\t/, $_);
    print "$clm[1]\t$clm[2]\t$clm[3]\t$clm[0]\t$clm[6]\t$clm[4]\t$clm[9]\n";
}
