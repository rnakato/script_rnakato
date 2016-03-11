#! /usr/bin/perl -w

if($#ARGV != 2){
    print "  extractbin.pl <bedfile> <prefix of wigfile> <binsize>\n";
    exit;
}
$bedfile=$ARGV[0];
$prefixIP=$ARGV[1];
$bin=$ARGV[2];

$chr="";
undef @arrayIP;
open(File, $bedfile) ||die "error: can't open $bedfile.\n";
while($line = <File>){
    next if($line eq "\n" || $line =~ /#/|| $line =~ /chromosome/);
    chomp($line);
    my @clm = split(/\t/, $line);
    if($chr ne $clm[0]){
	$chr = $clm[0];
	$chr = "chr$chr" if(!($chr =~ /chr/));
	undef @arrayIP;
	my $num = int(200000000/$bin)+1;
	for($i=0; $i<$num; $i++){$arrayIP[$i]=0;}
	my $IPname="$prefixIP\_$chr.10.wig.gz";
	if(!(-e $IPname)){
	    print "$IPname does not exist.\n";
	    exit;
	}
	&read_data_each(\@arrayIP, $IPname);
    }
    my $posi = $clm[3];
    print "$posi\t$arrayIP[int($posi/$bin)]\n";
}
close (File);

sub read_data_each{
    my ($refarrayIP, $filename) = @_;
    open(FILE, "zcat $filename |") || die "cannot open $filename.";
    my $line = <FILE>;
    $line = <FILE>;
    while(<FILE>){
	chomp;
	@c= split(/\t/, $_);
	$$refarrayIP[($c[0]-1)/$bin]=$c[1];
    }
    close(FILE);
}
