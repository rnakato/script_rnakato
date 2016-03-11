#! /usr/bin/perl

undef %Hash;
undef %Hashname;

$num_elem=@ARGV;
$postfix=$ARGV[0];

for($i=1;$i<$num_elem; $i++){
    open(IN, "$ARGV[$i]$postfix") || die;
    $line = <IN>;
    $line = <IN>;
    while(<IN>) {
	next if($_ eq "\n");
	chomp;
	@clm= split(/\t/, $_);
	$Hashname{$clm[0]} = $clm[1];
	$Hash_genetype{$clm[0]}=$clm[2];
	$Hash_len{$clm[0]}=$clm[3];
	$Hash_plus->{$ARGV[$i]}{$clm[0]}=$clm[4];
	$Hash_minus->{$ARGV[$i]}{$clm[0]}=$clm[5];
	$Hash_tagsum->{$ARGV[$i]}{$clm[0]}=$clm[6];
	$Hash_RPKM->{$ARGV[$i]}{$clm[0]}=$clm[7];
    }
    close IN;
}

# 1st line
print "\t\t\t\t";
for($i=1;$i<$num_elem-1; $i++){
    print "$ARGV[$i]\t\t\t\t";
}
print "$ARGV[$num_elem-1]\n";

# 2nd line
print "Accession Number\tname\tgenetype\tmRNA length\t";
for($i=1;$i<$num_elem; $i++){
    print "tag (plus)\ttag (minus)\ttag (sum)\tRPKM\t";
}
print "\n";

# data lines
foreach $name (sort {$a cmp $b} keys(%Hashname)){
    print "$name\t$Hashname{$name}\t$Hash_genetype{$name}\t$Hash_len{$name}\t";
    for($i=1;$i<$num_elem;$i++){
	if(!exists($Hash_plus->{$ARGV[$i]}{$name})){$Hash_plus->{$ARGV[$i]}{$name} = 0;}
	if(!exists($Hash_minus->{$ARGV[$i]}{$name})){$Hash_minus->{$ARGV[$i]}{$name} = 0;}
	if(!exists($Hash_tagsum->{$ARGV[$i]}{$name})){$Hash_tagsum->{$ARGV[$i]}{$name} = 0;}
	if(!exists($Hash_RPKM->{$ARGV[$i]}{$name})){$Hash_RPKM->{$ARGV[$i]}{$name} = 0;}

	printf("%.2f\t%.2f\t%.2f\t%.2f", $Hash_plus->{$ARGV[$i]}{$name}, $Hash_minus->{$ARGV[$i]}{$name}, $Hash_tagsum->{$ARGV[$i]}{$name}, $Hash_RPKM->{$ARGV[$i]}{$name});
	if ($i!=$num_elem-1){print "\t";}
	else{print "\n";}
    }
}
