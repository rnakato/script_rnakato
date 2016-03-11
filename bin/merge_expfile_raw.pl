#! /usr/bin/perl

use Getopt::Long;

undef %Hash;
undef %Hashname;

$num_elem=@ARGV;
$postfix=$ARGV[0];
$raw_data=0;

for($i=1;$i<$num_elem; $i++){
    open(IN, "$ARGV[$i]-$postfix") || die;
    $line = <IN>;
    $line = <IN>;
    while(<IN>) {
	next if($_ eq "\n");
	chomp;
	@clm= split(/\t/, $_);
	$Hash->{$ARGV[$i]}{$clm[0]}=$clm[4];
	$Hashname{$clm[0]} = $clm[1];
    }
    close IN;
}

print "Accession Number\tname\t";
for($i=1;$i<$num_elem-1; $i++){
    print "$ARGV[$i]\t";
}
print "$ARGV[$num_elem-1]\n";

foreach $name (sort {$a cmp $b} keys(%Hashname)){
    print "$name\t$Hashname{$name}\t";
    for($i=1;$i<$num_elem;$i++){
	if(!exists($Hash->{$ARGV[$i]}{$name})){$Hash->{$ARGV[$i]}{$name} = 0;}

	printf("%.2f",$Hash->{$ARGV[$i]}{$name});
	if ($i!=$num_elem-1){print "\t";}
	else{print "\n";}
    }
}
