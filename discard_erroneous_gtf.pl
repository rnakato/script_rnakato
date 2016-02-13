#!/usr/bin/perl -w

use strict;
use warnings;
use autodie;
use Path::Class;
use Array::Utils qw(unique);

=head1 SYNOPSIS
discard_erroneous_gtf.pl --gtf <gtffile>
=cut

use Pod::Usage 'pod2usage';
use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat);
my $gtf;
GetOptions ('gtf=s' => \$gtf) or pod2usage;
pod2usage unless $gtf;

my $file = file($gtf);
my $hash = {};
my $fh = $file->open('r') or die $!;
while(<$fh>){
        my @cols = split("\t",$_);
        if($cols[8] =~ m/gene_id\s+\"(.+)\"/){
                push @{$hash->{$1}},\@cols;
        }
}

while (my ($geneid,$entry) = each(%$hash)){
        my (@chr,@strand);
        foreach(@$entry){
                push @chr, $_->[0];
                push @strand,$_->[6];
                next unless(scalar(unique(@chr)) == 1 and scalar(unique(@strand)) == 1);
                print (join( "\t",@$_));
        }

}

