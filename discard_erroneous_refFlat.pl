#!/usr/bin/perl -w

=head1 SYNOPSIS
discard_erroneous_gtf.pl [gtf|txt] <file>
=cut

use strict;
use warnings;
use autodie;
use Path::Class;
use Array::Utils qw(unique);
use Pod::Usage qw(pod2usage);

my $type=shift;
pod2usage if($type ne "gtf" && $type ne "txt");
my $filename=shift;
pod2usage unless $filename;

if($type eq "txt"){
    system("sort -k3 $filename > $filename.sort");
    $filename = "$filename.sort";
}
my $file = file($filename);
my $hash = {};
my $fh = $file->open('r') or die $!;
while(<$fh>){
    my @cols = split("\t",$_);
    if($type eq "gtf"){
	push @{$hash->{$1}},\@cols if($cols[8] =~ m/gene_id\s+\"(.+)\"/);
    }elsif($type eq "txt"){
	push @{$hash->{$cols[1]}},\@cols;
    }
}

system("rm $filename") if($type eq "txt");

while(my($geneid,$entry) = each(%$hash)){
    my (@chr,@strand);
    foreach(@$entry){
	push @chr, $_->[0];
	push @strand,$_->[6];
	next unless(scalar(unique(@chr)) == 1 and scalar(unique(@strand)) == 1);
	print (join( "\t",@$_));
    }
}
