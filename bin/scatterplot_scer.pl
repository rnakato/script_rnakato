#! /usr/bin/perl -w

$teromere="/home/rnakato/DataBase/S_cerevisiae/teromere.xls";
$centromere="/home/rnakato/DataBase/S_cerevisiae/centromere-Kristian-extend20k.csv";

use Getopt::Long;

$prefix_x = $ARGV[0];
$prefix_y = $ARGV[1];
$bin=$ARGV[2];

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

$tagnum_x=0;
$tagnum_y=0;
print "X\tY\ttype\n";
foreach $chr (keys(%chrlen_scer)){
    undef @array_x;
    undef @array_y;
    &read_data(\@array_x, \@array_y, $chr);
}

sub read_data_each{
    my ($refarray, $filename, $refnum) = @_;
    open(FILE, "$filename") || die "cannot open $filename.";
#    open(FILE, "zcat $filename |") || die "cannot open $filename.";
    my $line = <FILE>;
    $line = <FILE>;
    while(<FILE>){
	chomp;
	@c= split(/\t/, $_);
	$$refarray[($c[0]-1)/$bin]=$c[1];
	$$refnum += $num;
    }
    close(FILE);
}

sub read_data{
    my ($refarray_x, $refarray_y, $chr) = @_;
    $num = int($chrlen_scer{$chr}/$bin)+1;

    for($i=0; $i<$num; $i++){
	$$refarray_x[$i]=0;
	$$refarray_y[$i]=0;
    }
#    my $xname="$prefix_x\_chr$chr.$bin.wig.gz";
 #   my $yname="$prefix_y\_chr$chr.$bin.wig.gz";
    my $xname="$prefix_x\_chr$chr.wig";
    my $yname="$prefix_y\_chr$chr.wig";
    if(!(-e $xname)){
	print "$xname does not exist.\n";
	exit;
    }
    if(!(-e $yname)){
	print "$yname does not exist.\n";
	exit;
    }
    &read_data_each($refarray_x, $xname, \$tagnum_x);
    &read_data_each($refarray_y, $yname, \$tagnum_y);
    for($i=0; $i<$num; $i++){
	my $on = 0;
	my $type = "arm";
	$posi = $i*$bin;
	for($j=0;$j<$num_teromere;$j++){
#	    $on=1 if($chr eq $teromere_chr[$j] && $teromere_s[$j] <= $posi && $posi <= $teromere_e[$j]);
	    $type = "teromere" if($chr eq $teromere_chr[$j] && $teromere_s[$j] <= $posi && $posi <= $teromere_e[$j]);
	}
#	next if($on);
	for($j=0;$j<$num_centromere;$j++){
	    $type = "centromere" if($chr eq $centromere_chr[$j] && $centromere_s[$j] <= $posi && $posi <= $centromere_e[$j]);
	}
	print "$$refarray_x[$i]\t$$refarray_y[$i]\t$type\n";
    }
}
