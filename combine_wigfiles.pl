#! /usr/bin/perl

die "scatterplot_wigfile.pl <binsize> <wigfile1> <wigfile2> [<wigfile3> ... ]\n" if($#ARGV ==-1);

$binsize=$ARGV[0];
undef @array;
for($i=1;$i<=$#ARGV;$i++){
    $name = $ARGV[$i];
    $name=$2 if($name =~ /(.+)\/(.+)/);
    print "$name";
    my %Hash;
    &readfile($ARGV[$i], \%Hash);
    push(@array, \%Hash);
    print "\t" if($i!=$#ARGV);
}
print "\n";

for($i=0;$i<$#ARGV;$i++){
    foreach $num (sort keys %{$array[$i]}){
	for($j=0;$j<$#ARGV;$j++){
	    $array[$j]{$num}=0 if(!exists($array[$j]{$num}));
	}
    }
}

foreach $num (sort keys %{$array[0]}){
    printf("%d",$num*$binsize);
    for($i=0;$i<$#ARGV;$i++){   
	print "\t$array[$i]->{$num}";
    }
    print "\n";
}

sub readfile{
    my ($file, $ref_hash) = @_;
    open(ListFile, $file) ||die "error: can't open $file\n";
    while(<ListFile>){
	next if($_ eq "\n");
	next if($_ =~ "variableStep" || $_ =~ "track");
	chomp;
	my @clm = split(/\t/, $_);
	$$ref_hash{int($clm[0]/$binsize)} = $clm[1];
    }
    close (ListFile);
}
