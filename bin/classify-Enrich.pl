#! /usr/bin/perl -w

use Getopt::Long;

$genome_len="2861343702";
$prefixIP = $ARGV[0];
$prefixWCE = $ARGV[1];
$inputfile=$ARGV[2];
$bin=10;
$flagment_len=150;
$buildhg18=0;
$outputreads=0;
GetOptions('hg18' => \$buildhg18, 'outputread' => \$outputreads);

%chrlen_hg18=(
    1=>247249719,
    2=>242951149,
    3=>199501827,
    4=>191273063,
    5=>180857866,
    6=>170899992,
    7=>158821424,
    8=>146274826,
    9=>140273252,
    10=>135374737,
    11=>134452384,
    12=>132349534,
    13=>114142980,
    14=>106368585,
    15=>100338915,
    16=>88827254,
    17=>78774742,
    18=>76117153,
    19=>63811651,
    20=>2435964,
    21=>46944323,
    22=>49691432,
    X=>154913754,
    Y=>57772954,
    M=>16571
);

%chrlen_hg19=(
    1=>249250621,
    2=>243199373,
    3=>198022430,
    4=>191154276,
    5=>180915260,
    6=>171115067,
    7=>159138663,
    8=>146364022,
    9=>141213431,
    10=>135534747,
    11=>135006516,
    12=>133851895,
    13=>115169878,
    14=>107349540,
    15=>102531392,
    16=>90354753,
    17=>81195210,
    18=>78077248,
    19=>59128983,
    20=>63025520,
    21=>48129895,
    22=>51304566,
    X=>155270560,
    Y=>59373566,
    M=>16571
);

%Hash_tags_IP=();
%Hash_tags_WCE=();
%Hash_len=();
$tagnum_IP=0;
$tagnum_WCE=0;

foreach $chr (keys(%chrlen_hg19)){
    undef @arrayIP;
    undef @arrayWCE;
    &read_data(\@arrayIP, \@arrayWCE, $chr);
    my $len=0;
    my $file="$inputfile\_chr$chr.txt";
    if(!(-e $file)){
	print "$file does not exist.\n";
	next;
    }
    open(IN, $file) || die "cannot open $file.";
    my $line = <IN>;
    chomp $line;
    @clm= split(/\t/, $line);
    for($i=0; $i<=$#clm; $i++){$name{$i}=$clm[$i];}
    while(<IN>){
	next if($_ eq "\n");
	chomp;
	@clm= split(/\t/, $_);
	$clmnum = $#clm;
	for($i=8; $i<=$clmnum; $i++){
	    next if($clm[$i] eq "");
	    @sande= split(/,/, $clm[$i]);
	    for($j=0; $j<=$#sande; $j++){
		@c= split(/-/, $sande[$j]);
#		print "$c[0] - $c[1]\n";
		$Hash_len{$name{$i}} += $c[1] - $c[0] +1;
		my $s = int($c[0]/$bin);
		my $e = int($c[1]/$bin);
#		print "$s - $e\n";
		if(!exists($Hash_tags_IP{$name{$i}})){
#		    printf("tags = %.2f\n",&counttags(\@arrayIP,  $chr, $s, $e));
		    $Hash_tags_IP{$name{$i}}  = &counttags(\@arrayIP,  $chr, $s, $e);
		    $Hash_tags_WCE{$name{$i}} = &counttags(\@arrayWCE, $chr, $s, $e);
		}else{
		    $Hash_tags_IP{$name{$i}}  += &counttags(\@arrayIP,  $chr, $s, $e);
		    $Hash_tags_WCE{$name{$i}} += &counttags(\@arrayWCE, $chr, $s, $e);
		}
#		print "\n";
	    }
	}
    }
    close(IN);
}



#### 結果出力
if($outputreads){
    printf("IP tags:%.2f\tWCE tags:%.2f\n", $tagnum_IP, $tagnum_WCE);
    print "\tbp\t\%\tIP reads\t\%\tWCE reads\t\%\n";
}else{
    print "\tbp\t\%\tIP RPKM\tWCE RPKM\tEnrichment\n";
}

for($i=8; $i<=$clmnum; $i++){
    &printresults($name{$i});
}

$IPtag_mapped=0; $WCEtag_mapped=0;
foreach $class (keys (%Hash_tags_IP)){
    $IPtag_mapped += $Hash_tags_IP{$class};
    $WCEtag_mapped += $Hash_tags_WCE{$class};
}
if($outputreads){
    printf("IP\t\t\t%.2f\t%.2f\n", $IPtag_mapped, $IPtag_mapped* 100/$tagnum_IP);
    printf("WCE\t\t\t%.2f\t%.2f\n", $WCEtag_mapped, $WCEtag_mapped* 100/$tagnum_WCE);
}

sub counttags{
    my ($refarray, $chr, $s, $e) = @_;
    my $tags=0;
    for(my $i=$s; $i<=$e; $i++){
#	print"i=$i\ttags=$$refarray[$i]\n";
	$tags += $$refarray[$i];
    }
    return $tags;
}

sub printresults{
    my ($class) = @_;
    return if(!exists($Hash_len{$class}));
    my $per = $Hash_len{$class}* 100/$genome_len;
    if($Hash_len{$class}){
	$rpkm_IP = 1e+10 * $Hash_tags_IP{$class} / ($tagnum_IP * $Hash_len{$class});
	$rpkm_WCE = 1e+10 * $Hash_tags_WCE{$class} / ($tagnum_WCE * $Hash_len{$class});
    }else{
	$rpkm_IP = 0;
	$rpkm_WCE = 0;
    }
    if($rpkm_WCE){
	$ratio = $rpkm_IP/$rpkm_WCE;	
    }else{
	$ratio = 0;
    }
    if($outputreads){
	printf("%s\t%d\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\n", $class, $Hash_len{$class}, $per, $Hash_tags_IP{$class}, $Hash_tags_IP{$class}* 100/$tagnum_IP, $Hash_tags_WCE{$class}, $Hash_tags_WCE{$class}* 100/$tagnum_WCE);
    }else{
	printf("%s\t%d\t%.2f\t%.2f\t%.2f\t%.2f\n", $class, $Hash_len{$class}, $per, $rpkm_IP, $rpkm_WCE, $ratio);
    }
}

sub read_data_each{
    my ($refarrayIP, $filename, $refnum) = @_;
    open(FILE, "zcat $filename |") || die;
    my $line = <FILE>;
    $line = <FILE>;
    while(<FILE>){
	chomp;
	@c= split(/\t/, $_);
	my $num = $c[1] * $bin/$flagment_len;
	$$refarrayIP[($c[0]-1)/$bin]=$num;
	$$refnum += $num;
    }
    close(FILE);
}

sub read_data{
    my ($refarrayIP, $refarrayWCE, $chr) = @_;
    if($buildhg18){$num = int($chrlen_hg18{$chr}/$bin)+1;
    }else{$num = int($chrlen_hg19{$chr}/$bin)+1;}
    for($i=0; $i<$num; $i++){
	$$refarrayIP[$i]=0;
	$$refarrayWCE[$i]=0;
    }
    my $IPname="$prefixIP\_chr$chr.wig.gz";
    my $WCEname="$prefixWCE\_chr$chr.wig.gz";
    if(!(-e $IPname)){
	print "$IPname does not exist.\n";
	exit;
    }
    if(!(-e $WCEname)){
	print "$WCEname does not exist.\n";
	exit;
    }
    &read_data_each($refarrayIP, $IPname, \$tagnum_IP);
    &read_data_each($refarrayWCE, $WCEname, \$tagnum_WCE);
}

