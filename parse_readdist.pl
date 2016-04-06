#!/usr/bin/env perl

my $i=0;
open(File, $ARGV[0]) ||die "error: can't open $ARGV[0].\n";
while(<File>){
    next if($_ eq "\n");
    chomp;
    if($_ =~ /Total Reads\s+([0-9]+)/){
	$total=$1;
    }elsif($_ =~ /Total Assigned Tags\s+([0-9]+)/){
	$assign=$1;
    }elsif($_ =~ /=/){
    }elsif($_ =~ /(.+)\s+([0-9]+)\s+([0-9]+)\s+(.+)/){
	my @clm = split(/\s+/, $_);
	$name[$i] = $1;
	$num[$i] = $3;
	$i++;
    }
}

print STDERR "Total read\tAssigned\t%";
for ($j=0;$j<$i;$j++){
    print STDERR "\t$name[$j]\t%";
}
print STDERR "\n";

printf("%d\t%d\t%.2f",$total,$assign,$assign*100/$total);
for ($j=0;$j<$i;$j++){
    printf("\t%d\t%.2f",$num[$j],$num[$j]*100/$total);
}
print "\n";

