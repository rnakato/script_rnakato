#!/usr/bin/env perl

=head1 DESCRIPTION

    describe DESCRIPTION

=head1 SYNOPSIS

    % combine_lines_from2files.pl [separate|merged] <file1> <file2> ...

=cut

use strict;
use warnings;
use autodie;
use Path::Class;
use Getopt::Long qw/:config posix_default no_ignore_case bundling auto_help/;
use Pod::Usage qw/pod2usage/;

my $type=$ARGV[0];
my $nline=0;
my $clmline=0;
if($type eq "separate") {
    $nline=1;
    $clmline=3;
}elsif($type eq "merged") {
    $nline=0;
    $clmline=1;
}else{
    print "please specify separate or merged.";
    exit;
}

my @Hasharray = ();
my %keys = ();
my $head="";
my $headflag=0;

for(my $i=1;$i<=$#ARGV;$i++) {
#    print "$ARGV[$i]\n";
    
    my %Hash = ();
    my $file = file($ARGV[$i]);
    my $fh = $file->open('r') or die $!;

    while(<$fh>){
	next if($_ eq "\n");
	chomp;
	my @clm = split(/\s/, $_);
	$Hash{$clm[$nline]} = $clm[$clmline];
	
	if(!$headflag) {
	    $head = $clm[$nline];
	    $headflag=1;
	}
	if($type eq "separate") {
	    $keys{$clm[$nline]} = "$clm[0]\t$clm[1]\t$clm[2]";
	}else{
	    $keys{$clm[$nline]} = $clm[0];
	}
    }
    $fh->close;
    push(@Hasharray, \%Hash);
}

print "$keys{$head}";
for my $Hash (@Hasharray) {
    print "\t$Hash->{$head}";
}
print "\n";

for my $key (keys %keys) {
    next if($key eq $head);
    my $on=0;
    for my $Hash (@Hasharray) {
	$on=1 if(!exists($Hash->{$key}));
    }
    next if($on);


    print "$keys{$key}";
    for my $Hash (@Hasharray) {
	print "\t$Hash->{$key}";
    }
    print "\n";
}
