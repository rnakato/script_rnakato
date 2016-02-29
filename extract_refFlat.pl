#!/usr/bin/env perl

=head1 SYNOPSIS
extract_refFlat.pl [UN|NR|NM|TSS] <file>
=cut

use strict;
use warnings;
use autodie;
use Path::Class;
use Array::Utils qw(unique);
use Pod::Usage qw(pod2usage);

my $type=shift;
pod2usage if($type ne "UN" && $type ne "NR" && $type ne "NM" && $type ne "TSS");
my $filename=shift;
pod2usage unless $filename;

my $file = file($filename);
my $hash = {};
my $fh = $file->open('r') or die $!;
while(<$fh>){
    my @clm = split("\t",$_);
    push @{$hash->{$clm[0]}},\@clm;
}

while(my($id,$entry) = each(%$hash)){
    next if($type eq "NR" && $id !~ /NR/);
    next if($type eq "NM" && $id !~ /NM/);
    my @tss;
    foreach(@$entry){
	my $chr    = $_->[2];
	next if($type eq "UN" && ($chr =~ /_random/ || $chr =~ /_hap/ || $chr =~ /chrUn/));
	my $strand = $_->[3];
	my $t;
	if($strand eq "+"){
	    $t = $_->[6];
	}else{
	    $t = $_->[7];
	}
	my $on=0;
	foreach my $pos (@tss){
	    $on++ if($pos == $t);
	}
	next if($type eq "TSS" && $on);
	push @tss, $t;
#	print "@tss\n";
	print (join( "\t",@$_));
    }
}
