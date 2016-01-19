#!/usr/bin/perl -w

$str="";
$nleft=0;$nright=0;
$mapleft=0;$mapright=0;$mappair=0;
$mapmulti=0;$rmulti=0;
$mapdis=0;$rdis=0;
open(File, $ARGV[0]) ||die "error: can't open $ARGV[0].\n";
while(<File>){
    next if($_ eq "\n");
    chomp;
    if($_ eq "Left reads:"){
	$str = "left";
    }elsif($_ eq "Right reads:"){
	$str = "right";
    }elsif($_ =~ /\s+Input\s+:\s+(.+)/){
	if($str eq "left"){
	    $nleft=$1;
	}elsif($str eq "right"){
	    $nright=$1;	    
	}
    }elsif($_ =~ /\s+Mapped\s+:\s+(.+) \((.+)% of input\)/){
	if($str eq "left"){
	    $mapleft=$1;
	    $rl = $2;
	}elsif($str eq "right"){
	    $mapright=$1;	    
	    $rr = $2;
	}
    }elsif($_ =~ /Aligned pairs:\s+(.+)/){
	$mappair=$1;
	my $line = <File>;
	if($line =~ /\s+of these:\s+(.+) \((.+)%\) have multiple alignments/){
	    $mapmulti=$1;
	    $rmulti=$2;
	}
	$line = <File>;
	if($line =~ /\s+(.+) \((.+)%\) are discordant alignments/){
	    $mapdis=$1;
	    $rdis=$2;
	}
    }
}
close (File);

print STDERR "Left reads\t\t\tRight reads\t\t\tPair\n";
print STDERR "Sequenced\tmapped\t(%)\tSequenced\tmapped\t(%)\tAligned\tmultiple\t(%)\tdiscordant\t(%)\n";
print "$nleft\t$mapleft\t$rl\t$nright\t$mapright\t$rr\t$mappair\t$mapmulti\t$rmulti\t$mapdis\t$rdis\n";
