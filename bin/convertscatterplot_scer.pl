#! /usr/bin/perl -w

$teromere="/home/rnakato/DataBase/S_cerevisiae/teromere.xls";
$centromere="/home/rnakato/DataBase/S_cerevisiae/centromere-Kristian-extend20k.csv";

use Getopt::Long;

$filename = $ARGV[0];

%chrlen_scer=(
    I=>230208,
    II=>813178,
    III=>316617,
    IV=>1531919,
    V=>576869,
    VI=>270148,
    VII=>1090947,
    VIII=>562643,
    IX=>439885,
    X=>745741,
    XI=>666454,
    XII=>1078175,
    XIII=>924429,
    XIV=>784334,
    XV=>1091289,
    XVI=>948062
#    M=>85779,
#    "2micron"=>6318
);

@teromere_chr = ();
@teromere_s = ();
@teromere_e = ();
$num_teromere=0;
open(ListFile, $teromere) ||die "error: can't open file.\n";
while($line = <ListFile>){
    next if($line eq "\n");
    chomp($line);
    my @clm = split(/\t/, $line);
    push(@teromere_chr, $clm[0]);
    push(@teromere_s, $clm[1]);
    push(@teromere_e, $clm[2]);
    $num_teromere++;
}
close (ListFile);
#for($i=0;$i<$num_teromere;$i++){ print "$teromere_chr[$i]\t$teromere_s[$i]\t$teromere_e[$i]\n";}

@centromere_chr = ();
@centromere_s = ();
@centromere_e = ();
$num_centromere=0;
open(ListFile, $centromere) ||die "error: can't open file.\n";
while($line = <ListFile>){
    next if($line eq "\n");
    chomp($line);
    my @clm = split(/\t/, $line);
    push(@centromere_chr, $clm[0]);
    push(@centromere_s, $clm[1]);
    push(@centromere_e, $clm[2]);
    $num_centromere++;
}
close (ListFile);
#for($i=0;$i<$num_centromere;$i++){ print "$centromere_chr[$i]\t$centromere_s[$i]\t$centromere_e[$i]\n";}

print "X\tY\ttype\n";
open(ListFile, $filename) ||die "error: can't open file.\n";
while($line = <ListFile>){
    next if($line eq "\n");
    chomp($line);
    my @clm = split(/\t/, $line);
    next if(!exists($chrlen_scer{$clm[0]}));
    my $chr = $clm[0];
    my $posi = $clm[1];
    my $x = $clm[2];
    my $y = $clm[3];
    
    my $on = 0;
    for($j=0;$j<$num_teromere;$j++){
	$on=1 if($chr eq $teromere_chr[$j] && $teromere_s[$j] <= $posi && $posi <= $teromere_e[$j]);
    }
    next if($on);
    my $type = "arm";
    for($j=0;$j<$num_centromere;$j++){
	$type = "centromere" if($chr eq $centromere_chr[$j] && $centromere_s[$j] <= $posi && $posi <= $centromere_e[$j]);
    }
    print "$x\t$y\t$type\n";
}
