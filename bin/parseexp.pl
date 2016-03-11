#! /usr/bin/perl -w

undef %Hash;
undef @array;
$num=0;
$numall=0;
$numuniq=0;
$name="";

$mapfile=$ARGV[0];
open(IN, $mapfile) || die "error: cannot open $mapfile.";
while(<IN>) {
    next if($_ eq "\n");
    chomp;
    @clm= split(/\t/, $_);
    if($num && ($name ne $clm[0])){
	foreach $str (@array){
	    if(exists($Hash{$str})){ $Hash{$str} += 1/$num;}
	    else{ $Hash{$str} = 1/$num;}
	}
	$name = $clm[0];
	undef @array;
	push (@array, $clm[2]);	
	$num=1;
	$numuniq++;
    }else{
	push (@array, $clm[2]);
	$num++;
    }
    $numall++;
}
close IN;

foreach $str (@array){
    if(exists($Hash{$str})){
	$Hash{$str} += 1/$num;
    }else{
	$Hash{$str} = 1/$num;
    }
}

print "#num: $numall uniq: $numuniq\n";
foreach $name (keys(%Hash)){
    print "$name\t$Hash{$name}\n";
}
