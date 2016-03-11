#!/usr/bin/perl -w

use Class::Struct;

struct Peak => {
    chr   => '$',
    start => '$',
    end   => '$',
    val   => '$'
};

%chrname_human = (1=>1, 2=>1, 3=>1, 4=>1, 5=>1, 6=>1, 7=>1, 8=>1, 9=>1, 10=>1, 11=>1, 12=>1, 13=>1, 14=>1, 15=>1, 16=>1, 17=>1, 18=>1, 19=>1, 20=>1, 21=>1, 22=>1, X=>1, Y=>1, M=>1);

$datafile = $ARGV[0];
$num_data = &input_peak($datafile, \@array_data, 0, 1, 2, 4, "\t");

$sum=0;
for($i=0;$i<$num_data;$i++){
    $sum += $array_data[$i]->end - $array_data[$i]->start;
}

$ave = $sum / $num_data;

printf("length average: %.2f\n",$ave);

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

