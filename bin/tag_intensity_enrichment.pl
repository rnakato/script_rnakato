#! /usr/bin/perl -w

use Getopt::Long;

$prefixIP = $ARGV[0];
$prefixWCE = $ARGV[1];
$regionfile=$ARGV[2];
$bin=$ARGV[3];

$chrlen_longest=250000000;
$tagsum=0;
GetOptions('tagsum' => \$tagsum);

$chr=0;
open(IN, $regionfile) || die "cannot open $regionfile.\n";
print "IP: $prefixIP\n";
print "WCE: $prefixWCE\n";
print "chromosome\tstart\tendt\tsummit\tlength\tIP tags\tWCE tags\tEnrichment\n";
while(<IN>){
    @clm= split(/\t/, $_);
    next if($clm[0] =~ /chromosome/ || $clm[0] =~ /#/);
    if($chr ne $clm[0]){
	undef @arrayIP;
	undef @arrayWCE;
	$chr = $clm[0];
	&read_data(\@arrayIP, \@arrayWCE, $chr);
    }
    my $len = $clm[2] - $clm[1];
    my $s = int($clm[1]/$bin);
    my $e = int($clm[2]/$bin);
    my $IPtags = &extracttags(\@arrayIP,  $chr, $s, $e);
    my $WCEtags = &extracttags(\@arrayWCE, $chr, $s, $e);
    my $ratio = 0;
    if($WCEtags>0){$ratio = $IPtags/$WCEtags;}else{$ratio = 0;}
    printf("%s\t%s\t%d\t%d\t%d\t%.2f\t%.2f\t%.2f\n", $chr, $clm[1], $clm[2], $clm[3], $len, $IPtags, $WCEtags, $ratio);
}

sub extracttags{
    my ($refarray, $chr, $s, $e) = @_;
    my $tags=0;
    if($tagsum){
	for($i=$s; $i<=$e; $i++){
	    $tags += $$refarray[$i];
	}
    }else{
	for($i=$s; $i<=$e; $i++){
	    $tags = $$refarray[$i] if($tags < $$refarray[$i]);
	}
    }
    return $tags;
}

sub read_data_each{
    my ($refarrayIP, $filename) = @_;
    open(FILE, "zcat $filename |") || die;
    my $line = <FILE>;
    $line = <FILE>;
    while(<FILE>){
	chomp;
	my @c= split(/\t/, $_);
	$$refarrayIP[($c[0]-1)/$bin]=$c[1];
    }
    close(FILE);
}

sub read_data{
    my ($refarrayIP, $refarrayWCE, $chr) = @_;
    my $num = int($chrlen_longest/$bin)+1;
    for($i=0; $i<$num; $i++){
	$$refarrayIP[$i]=0;
	$$refarrayWCE[$i]=0;
    }
    &read_data_each($refarrayIP, "$prefixIP\_chr$chr.wig.gz");
    &read_data_each($refarrayWCE, "$prefixWCE\_chr$chr.wig.gz");
}

