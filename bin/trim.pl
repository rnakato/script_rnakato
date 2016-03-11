#! /usr/bin/perl -w

open(IN, $ARGV[0]) || die;
while(<IN>) {
    next if($_ eq "\n");
    chomp;
    @clm= split(/\t/, $_);
    for($i=0; $i<=$#clm; $i++){
	$clm[$i] = trim($clm[$i]);
	if($i<$#clm){
	    print "$clm[$i]\t";
	}else{
	    print "$clm[$i]\n";
	}
    }
}
close IN;

$val = '  foo  ';
$val = trim($val);

sub trim {
	my $val = shift;
	$val =~ s/^ *(.*?) *$/$1/;
	return $val;
}
