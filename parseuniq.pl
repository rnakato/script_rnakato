#!/usr/bin/env perl

=head1 NAME
    parse file output from uniq command
=head1 SYNOPSIS
    parseuniq.pl [--sort] <file>
=cut

#use strict;
#use warnings;
#use autodie;
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
    next if($_ eq "\n");
    chomp;
    if($_ =~ /\s+([0-9]+) (.+)/){
	
	print "$2\t$1\n";
    }
}
