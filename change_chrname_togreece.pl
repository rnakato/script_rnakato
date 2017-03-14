#! /usr/bin/perl -w 

open(IN, $ARGV[0]) || die;
while(<IN>) {
    next if($_ eq "\n");
    chomp;
    my @clm = split(/\t/, $_);
    my $head="";
    if($clm[0] =~ /chr[.+]/) {
	$head="chr";
	$clm[0] = $1;
    }
    if($clm[0] == "1"){ $clm[0] = "I"; }
    elsif($clm[0] == "2"){ $clm[0] = "II"; }
    elsif($clm[0] == "3"){ $clm[0] = "III"; }
    elsif($clm[0] == "4"){ $clm[0] = "IV"; }
    elsif($clm[0] == "5"){ $clm[0] = "V"; }
    elsif($clm[0] == "6"){ $clm[0] = "VI"; }
    elsif($clm[0] == "7"){ $clm[0] = "VII"; }
    elsif($clm[0] == "8"){ $clm[0] = "VIII"; }
    elsif($clm[0] == "9"){ $clm[0] = "IX"; }
    elsif($clm[0] == "10"){ $clm[0] = "X"; }
    elsif($clm[0] == "11"){ $clm[0] = "XI"; }
    elsif($clm[0] == "12"){ $clm[0] = "XII"; }
    elsif($clm[0] == "13"){ $clm[0] = "XIII"; }
    elsif($clm[0] == "14"){ $clm[0] = "XIV"; }
    elsif($clm[0] == "15"){ $clm[0] = "XV"; }
    elsif($clm[0] == "16"){ $clm[0] = "XVI"; }
    
    print "$head";
    for($i=0;$i<=$#clm;$i++) {
	print "$clm[$i]";
	if($i!=$#clm) {print"\t";}
	else {print"\n";}
    }
}
close IN;
