#!/usr/bin/perl -w

use Class::Struct;

struct Peak => {
    chr   => '$',
    start => '$',
    end   => '$',
    val   => '$'
};

%chrname_human = (1=>1, 2=>1, 3=>1, 4=>1, 5=>1, 6=>1, 7=>1, 8=>1, 9=>1, 10=>1, 11=>1, 12=>1, 13=>1, 14=>1, 15=>1, 16=>1, 17=>1, 18=>1, 19=>1, 20=>1, 21=>1, 22=>1, X=>1, Y=>1, M=>1);

$reffile = $ARGV[0];
$datafile = $ARGV[1];
#$format = $ARGV[2];

undef @array_ref;
undef @array_data;

$num_ref = &input_peak($reffile, \@array_ref, 0, 1, 2, 3, "\t");
$num_data = &input_peak($datafile, \@array_data, 0, 1, 2, 4, "\t");
#$num_data = &input_peak($datafile, \@array_data, 0, 2, 3, 5, " ");

#for($i=0; $i<$num_ref; $i++){
#    printf("%s\t%d\t%d\t%f\n", $array_ref[$i]->chr, $array_ref[$i]->start, $array_ref[$i]->end, $array_ref[$i]->val);
#}
#for($i=0; $i<$num_data; $i++){
#    printf("%s\t%d\t%d\t%f\n", $array_data[$i]->chr, $array_data[$i]->start, $array_data[$i]->end, $array_data[$i]->val);
#}

$sn = &calc_sn(\@array_ref, $num_ref, \@array_data, $num_data);
$sp = &calc_sp(\@array_ref, $num_ref, \@array_data, $num_data);

print "sensitivity: $sn \%\n";
print "specificity: $sp \%\n";

sub input_peak{
    my ($filename, $array, $c, $s, $e, $v, $token) = @_;
    open(ListFile, $filename) ||die("error: can't open file: %s\n", $filename);
    my $num=0;
    while(my $line = <ListFile>){
	if($line eq "\n"){next;}
	chomp($line);
	my @clm = split(/$token/, $line);
	my $p = new Peak();
	my $chr = 0; 
	if($clm[$c] =~ /chr(.+)/){
	    $chr = $1;
	}else{
	    $chr = $clm[$c];
	}
	if(exists($chrname_human{$chr})){
	    $p->chr($chr);
	    $p->start($clm[$s]);
	    $p->end($clm[$e]);
	    $p->val($clm[$v]);
	    $$array[$num++] = $p;
	}
    }
    close (ListFile);
    return $num;
}


sub calc_sn{
    my ($a_ref, $num_ref, $a_data, $num_data) = @_;
    $num_hit=0;
    for(my $i=0; $i<$num_ref; $i++){
	for(my $j=0; $j<$num_data; $j++){
	    if($$a_ref[$i]->chr eq $$a_data[$j]->chr &&
	       $$a_ref[$i]->start < $$a_data[$j]->end &&
	       $$a_ref[$i]->end > $$a_data[$j]->start){
		$num_hit++;
		last;
	    }
	}
    }
    print "$num_hit, $num_ref\n";
    my $sn = $num_hit*100/$num_ref;
    return $sn;
}

sub calc_sp{
    my ($a_ref, $num_ref, $a_data, $num_data) = @_;
    $num_hit=0;
    
    for(my $i=0; $i<$num_data; $i++){
	my $on=0;
	for(my $j=0; $j<$num_ref; $j++){
	    if($$a_ref[$j]->chr eq $$a_data[$i]->chr &&
	       $$a_ref[$j]->start < $$a_data[$i]->end &&
	       $$a_ref[$j]->end > $$a_data[$i]->start){
		$on=1;
		last;
	    }
	}
	if($on){ $num_hit++; }
    }
    print "$num_hit, $num_data\n";
    my $sn = $num_hit*100/$num_data;
    return $sn;
}
