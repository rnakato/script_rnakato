#!/usr/bin/perl -w

for($i=0;$i<@ARGV;$i++){
    open(File, $ARGV[$i]) ||die "error: can't open $ARGV[$i].\n";
    while(<File>){
	next if($_ eq "\n");
	chomp;
	my @clm = split(/\t/, $_);
	$Hash[$i]{$clm[0]} = $clm[1];
    }
    close(File);
}

print "num\t";
for($i=0;$i<@ARGV;$i++){
    print "$ARGV[$i]";
    if($i==@ARGV-1){
	print "\n";
    }else{
	print "\t";
    }
}
foreach my $num (sort {$a <=> $b} keys %{$Hash[0]}){
    print "$num\t";
    for($i=0;$i<@ARGV;$i++){
	print "$Hash[$i]{$num}";
	if($i==@ARGV-1){
	    print "\n";
	}else{
	    print "\t";
	}
    }
}
