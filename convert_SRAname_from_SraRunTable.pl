#!/usr/bin/env perl

#use strict;
use warnings;
use Getopt::Long qw/:config/;
use Pod::Usage qw/pod2usage/;
#use autodie;

my $pair=0;
GetOptions( "pair|p" => \$pair ) or pod2usage(1);

if($#ARGV <1){
    print "    convert_SRAname_from_SraRunTable.pl <file> <line for output (int)>.\n\n";
    exit;
}

$file=$ARGV[0];
$line_name=$ARGV[1];
open(IN, $file) || die;
$file=<IN>;
@clm= split(/,/, $file);
for($i=0;$i<=$#clm;$i++){
    $line_id = $i if($clm[$i] eq "Run_s" || $clm[$i] eq "Run");
    $line_org = $i if($clm[$i] eq "Organism_s" || $clm[$i] eq "Organism");
    $line_type = $i if($clm[$i] eq "LibraryLayout_s" || $clm[$i] eq "LibraryLayout");
}

while(<IN>) {
    next if($_ eq "\n");
    chomp;
    @clm= split(/,/, $_);
    my $srr = $clm[$line_id];
    $name = $clm[$line_name];
    $name =~ s/(?:\()/_/g;
    $name =~ s/\s/_/g;
    $type{$name} = $clm[$line_type];
    $species{$name} = $clm[$line_org];
    $infos->{$name} ||= [];
    $infos->{$name}[0]++;
    $infos->{$name}[$infos->{$name}[0]] = $srr;
}
close IN;

foreach $name (keys(%{$infos})){
    $fastq{$name} ||= "";
    $fastq1{$name} ||= "";
    $fastq2{$name} ||= "";
    for($i=1;$i<=$infos->{$name}[0];$i++){
	$fastq{$name} = $fastq{$name} . "\$dir/$infos->{$name}[$i].fastq.gz";
	$fastq1{$name} = $fastq1{$name} . "\$dir/$infos->{$name}[$i]\_1.fastq.gz";
	$fastq2{$name} = $fastq2{$name} . "\$dir/$infos->{$name}[$i]\_2.fastq.gz";
	if($i!=$infos->{$name}[0]){
	    $fastq{$name} = $fastq{$name} . ",";
	    $fastq1{$name} = $fastq1{$name} . ",";
	    $fastq2{$name} = $fastq2{$name} . ",";
	}
    }
}

print "FASTQ=(\n";
foreach $name (sort keys(%{$infos})){
    if($pair) {
	print "\"$fastq1{$name} $fastq2{$name}\"\t # $species{$name}, $type{$name}\n";
    }else {
	print "\"$fastq{$name}\"\n";
    }
}
print ")\n";

print "NAME=(\n";
foreach $name (sort keys(%{$infos})){
    print "\"$name\"\t # $species{$name}, $type{$name}\n";
}
print ")\n";
