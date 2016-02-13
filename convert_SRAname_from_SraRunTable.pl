#! /usr/bin/perl -w

use strict;
use warnings;
use autodie;
$file=$ARGV[0];
$line_name=$ARGV[1];
open(IN, $file) || die;
$file=<IN>;
@clm= split(/\t/, $file);
for($i=0;$i<=$#clm;$i++){
    $line_id = $i if($clm[$i] eq "Run_s");
    $line_org = $i if($clm[$i] eq "Organism_s");
    $line_type = $i if($clm[$i] eq "LibraryLayout_s");
}

while(<IN>) {
    next if($_ eq "\n");
    chomp;
    @clm= split(/\t/, $_);
    my $srr = $clm[$line_id];
    my ($gsm, $name) = split(': ', $clm[$line_name]);
    $name =~ s/(?:\()/_/g;
    $name =~ s/(?:\))/_/g;
    $type{$name} = $clm[$line_type];
    $species{$name} = $clm[$line_org];
    $infos->{$name} ||= [];
    $infos->{$name}[0]++;
    $infos->{$name}[$infos->{$name}[0]] = $srr;
}
close IN;

foreach $name (keys($infos)){
    $fastq{$name} ||= "";
    for($i=1;$i<=$infos->{$name}[0];$i++){
	$fastq{$name} = $fastq{$name} . "\$dir/$infos->{$name}[$i].fastq";
	if($i!=$infos->{$name}[0]){$fastq{$name} = $fastq{$name} . ",";}
    }
}

print "FASTQ=(\n";
foreach $name (sort keys($infos)){
    print "\"$fastq{$name}\"\n";
}
print ")\n";

print "NAME=(\n";
foreach $name (sort keys($infos)){
    print "\"$name\"\t# $species{$name}, $type{$name}\n";
}
print ")\n";
