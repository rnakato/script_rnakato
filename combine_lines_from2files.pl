#!/usr/bin/env perl

=head1 DESCRIPTION

    Merge rows of two files for overlapping rows (the column1 of file1 are overlapping the column2 in file2)

=head1 SYNOPSIS

    % combine_lines_from2files.pl [options] -1 file1 -2 file2 -a line1 -b line2

    Options:
    --all  output all redundant lines (default 1st one)

=cut

use strict;
use warnings;
use autodie;
use Path::Class;
use Getopt::Long qw/:config posix_default no_ignore_case bundling auto_help/;
use Pod::Usage qw/pod2usage/;

my $file1="";
my $file2="";
my $line1="";
my $line2="";
#my $all=0;

GetOptions(
    "file1|1=s" => \$file1,
    "file2|2=s" => \$file2,
    "l1|a=i" => \$line1,
    "l2|b=i" => \$line2
#    "all" => \$all
) or pod2usage(1);

#print "file1=$file1, file2=$file2, line1=$line1, line2=$line2, all=$all\n";

pod2usage(2) unless $file1;
pod2usage(2) unless $file2;
#pod2usage(2) unless $line1;
#pod2usage(2) unless $line2;

my %Hash = ();
my $file = file($file1);
my $fh = $file->open('r') or die "$file1 not found";
while(<$fh>){
    next if($_ eq "\n");
    chomp;
    my @clm = split(/\s/, $_);
    my $str = $clm[$line1];
    if (exists($Hash{$str})){
        print "Warning: $str already exists. The latter one is stored.\n";
    }
    $Hash{$str} = $_;
}
$fh->close;

$file = file($file2);
$fh = $file->open('r') or die "$file2 not found";
while(<$fh>){
    next if($_ eq "\n");
    chomp;
    my @clm = split(/\s/, $_);
    my $name = $clm[$line2];
    print "$Hash{$name}\t$_\n" if(exists($Hash{$name}));
}
$fh->close;
