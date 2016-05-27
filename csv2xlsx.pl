#!/usr/bin/env perl

use strict;
use warnings;
use Path::Class;
use Excel::Writer::XLSX;
use Getopt::Long qw/:config posix_default no_ignore_case bundling auto_help/;

my @input = ();
my $output = "";
my $delim = "\t";
GetOptions('input|i=s' => \@input, 'output|o=s' => \$output, 'delim|d=s' => \$delim);

if($#input ==-1 || $output eq ""){
    print "    csv2xlsx.pl: merge csv file(s) to xlsx.\n\n";
    print "    Usage: csv2xlsx.pl -i <input.csv> [-i <input.csv> ...] -o output.xlsx\n\n";
    print "    Options:\n\t-d --delim = <str>: delimiter of csv (default:\\t)\n\n";
    exit;
}

my $workbook = Excel::Writer::XLSX->new($output);

my %hash;
for(my $i=0; $i<=$#input; $i++) {
    my $tabname_full=(split /\//,$input[$i])[-1];
    my $tabname = substr($tabname_full, 0, 27);
    while(exists($hash{$tabname})) {
	$tabname = $tabname . "2";
    }
    $hash{$tabname}=1;
    my $worksheet = $workbook->add_worksheet($tabname);

    my $file = file($input[$i]);
    my $fh = $file->open('r') or die "Error: $input[$i] does not exist.\n";
    my $nrow=0;
    while(<$fh>){
	chomp;
	my @clm = split(/$delim/, $_);
	for(my $j=0; $j<=$#clm; $j++) { $worksheet->write( $nrow, $j, $clm[$j]);}
	$nrow++;
    }
    $fh->close;
}
