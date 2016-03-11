#!/usr/bin/perl -w

$fasta="";
$seedlen=$ARGV[1];
%Hash=();
$n_window=0;
$n_ef=0;

open(InputFile, $ARGV[0]) ||die "error: can't open file.\n";
while($line = <InputFile>){
    
    if($line =~ ">"){
	&calc_uniq($fasta, \$n_window, \$n_ef);
	$fasta="";
	next;
    }  
    elsif($line eq "\n"){next;}
    else{
	chomp($line);
	$fasta = $fasta . $line;
    }

} 
close (InputFile);
&calc_uniq($fasta, \$n_window, \$n_ef);

sub calc_uniq{
    my ($fasta, $ref_nw, $ref_nef) = @_;
    my $len = length($fasta);
    my $n_window = $len - $seedlen +1;
    my $n_ef = 0;
    return if($fasta eq "");
    for($i=0; $i<$n_window; $i++){
	$seed = substr($fasta, $i, $seedlen);
	if($seed =~ /[^acgtACGT]/){ next;}
	$n_ef++;
    if(!exists($Hash{$seed})){$Hash{$seed} = 1;}
	else{ $Hash{$seed}++;}
    }
    $$ref_nw += $n_window;
    $$ref_nef += $n_ef;
}

$uniqnum=0;
foreach $seed (keys %Hash){
    if($Hash{$seed}==1){
	$uniqnum++;
    }
}

$per=$uniqnum*100/$n_ef;
if($ARGV[2]){
    print "length_whole:$n_window, length_mappable:$n_ef, uniq num:$uniqnum\n";
    printf("uniq ratio = %.2f\n", $per);
}else{
    printf("$seedlen\t%.2f\n", $per);
}
