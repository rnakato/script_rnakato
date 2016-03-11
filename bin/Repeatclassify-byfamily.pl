#! /usr/bin/perl -w

use Getopt::Long;

$genome_len=0;
$prefixIP = $ARGV[0];
$prefixWCE = $ARGV[1];
$dir=$ARGV[2];
$bin=10;
$flagment_len=150;
$buildhg18=0;
$buildhg19=0;
$buildmm9=0;
$outputreads=0;
GetOptions('hg18' => \$buildhg18, 'hg19' => \$buildhg19, 'mm9' => \$buildmm9, 'outputread' => \$outputreads);
if($buildhg18){
    $genome_len="3080419480";
}elsif($buildhg19){
    $genome_len="3095677412";
}elsif($buildmm9){
    $genome_len="2654895218";
}else{
    print "please specify build.\n";
    exit;
}

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

%chrlen_mm9=(
    1=>197195432,
    2=>181748087,
    3=>159599783,
    4=>155630120,
    5=>152537259,
    6=>149517037,
    7=>152524553,
    8=>131738871,
    9=>124076172,
    10=>129993255,
    11=>121843856,
    12=>121257530,
    13=>120284312,
    14=>125194864,
    15=>103494974,
    16=>98319150,
    17=>95272651,
    18=>90772031,
    19=>61342430,
    X=>166650296,
    Y=>15902555,
    M=>16299
);

%Hash_name=();
%Hash_tags_IP=();
%Hash_tags_WCE=();
%Hash_len=();
$tagnum_IP=0;
$tagnum_WCE=0;

undef @arrayIP;
undef @arrayWCE;
if($buildmm9){
    foreach $chr (keys(%chrlen_mm9)){
	&read_data(\@arrayIP, \@arrayWCE, $chr);
	foreach $family (("Alu", "B2","B4", "MIR", "Other")){ &output_class("SINE-$family", \@arrayIP, \@arrayWCE, $chr);}
	foreach $family (("L1", "L2", "CR1", "RTE")){ &output_class("LINE-$family", \@arrayIP, \@arrayWCE, $chr);}
	foreach $family (("ERVK", "ERVL", "ERV1", "Other")){ &output_class("LTR-$family", \@arrayIP, \@arrayWCE, $chr);}
	foreach $family (("MER1_type", "MER2_type", "Other")){ &output_class("DNA-$family", \@arrayIP, \@arrayWCE, $chr);} 
	foreach $family (("Satellite", "centr")){ &output_class("Satellite-$family", \@arrayIP, \@arrayWCE, $chr);}
	&output_class("rRNA", \@arrayIP, \@arrayWCE, $chr);
	&output_class("tRNA", \@arrayIP, \@arrayWCE, $chr);
	&output_class("scRNA", \@arrayIP, \@arrayWCE, $chr);
	&output_class("snRNA", \@arrayIP, \@arrayWCE, $chr);
	&output_class("srpRNA", \@arrayIP, \@arrayWCE, $chr);
	&output_class("RNA", \@arrayIP, \@arrayWCE, $chr);
	&output_class("Low_complexity", \@arrayIP, \@arrayWCE, $chr);
	&output_class("Simple_repeat", \@arrayIP, \@arrayWCE, $chr);
	&output_class("Otherrepeat", \@arrayIP, \@arrayWCE, $chr);
    }
}else{
    foreach $chr (keys(%chrlen_hg19)){
	&read_data(\@arrayIP, \@arrayWCE, $chr);
	foreach $family (("Alu", "MIR", "Other")){&output_class("SINE-$family", \@arrayIP, \@arrayWCE, $chr);}
	foreach $family (("L1", "L2", "CR1", "RTE", "Other")){&output_class("LINE-$family", \@arrayIP, \@arrayWCE, $chr);}
	foreach $family (("ERVL-MaLR", "ERVL", "ERV1", "ERVK", "Gypsy", "ERV")){&output_class("LTR-$family", \@arrayIP, \@arrayWCE, $chr);}
	foreach $family (("TcMar-Tigger", "TcMar-Mariner", "TcMar-Tc2", "TcMar", "hAT-Charlie", "hAT-Blackjack", "hAT-Tip100", "hAT", "Other")){&output_class("DNA-$family", \@arrayIP, \@arrayWCE, $chr);}
	foreach $family (("acro", "centr", "telo")){&output_class("Satellite-$family", \@arrayIP, \@arrayWCE, $chr);}
	&output_class("Satellite", \@arrayIP, \@arrayWCE, $chr);    
	&output_class("rRNA", \@arrayIP, \@arrayWCE, $chr);
	&output_class("tRNA", \@arrayIP, \@arrayWCE, $chr);
	&output_class("scRNA", \@arrayIP, \@arrayWCE, $chr);
	&output_class("snRNA", \@arrayIP, \@arrayWCE, $chr);
	&output_class("srpRNA", \@arrayIP, \@arrayWCE, $chr);
	&output_class("RNA", \@arrayIP, \@arrayWCE, $chr);
	&output_class("Low_complexity", \@arrayIP, \@arrayWCE, $chr);
	&output_class("Simple_repeat", \@arrayIP, \@arrayWCE, $chr);
	&output_class("Otherrepeat", \@arrayIP, \@arrayWCE, $chr);
    }
}

#### 結果出力
if($outputreads){
    printf("all tags:%.2f \n", $tagnum_IP);
    print "class\tname\tbp\t\%\tIP reads\t\%\n";
}else{
    print "class\tname\tbp\t\%\tIP RPKM\tWCE RPKM\tEnrichment\n";
}

if($buildmm9){
    foreach $family (("Alu", "B2","B4", "MIR", "Other")){ &printresults("SINE-$family");}
    foreach $family (("L1", "L2", "CR1", "RTE")){ &printresults("LINE-$family");}
    foreach $family (("ERVK", "ERVL", "ERV1", "Other")){ &printresults("LTR-$family");}
    foreach $family (("MER1_type", "MER2_type", "Other")){ &printresults("DNA-$family");}
    foreach $family (("Satellite", "centr")){ &printresults("Satellite-$family");}
    &printresults("rRNA");
    &printresults("tRNA");
    &printresults("scRNA");
    &printresults("snRNA");
    &printresults("srpRNA");
    &printresults("RNA");
    &printresults("Low_complexity");
    &printresults("Simple_repeat");
    &printresults("Otherrepeat");
}else{
    foreach $family (("Alu", "MIR", "Other")){ &printresults("SINE-$family");}
    foreach $family (("L1", "L2", "CR1", "RTE", "Other")){ &printresults("LINE-$family");}
    foreach $family (("ERVL-MaLR", "ERVL", "ERV1", "ERVK", "Gypsy", "ERV")){ &printresults("LTR-$family");}
    foreach $family (("TcMar-Tigger", "TcMar-Mariner", "TcMar-Tc2", "TcMar", "hAT-Charlie", "hAT-Blackjack", "hAT-Tip100", "hAT", "Other")){ &printresults("DNA-$family");}
    foreach $family (("acro", "centr", "telo")){ &printresults("Satellite-$family");}
    &printresults("Satellite");
    &printresults("rRNA");
    &printresults("tRNA");
    &printresults("scRNA");
    &printresults("snRNA");
    &printresults("srpRNA");
    &printresults("RNA");
    &printresults("Low_complexity");
    &printresults("Simple_repeat");
    &printresults("Otherrepeat");
}

$IPtag_mapped=0; $WCEtag_mapped=0;
foreach $class (keys (%Hash_tags_IP)){
    $IPtag_mapped += $Hash_tags_IP{$class};
    $WCEtag_mapped += $Hash_tags_WCE{$class};
}
if($outputreads){
    printf("all\t\t\t%.2f\t%.2f\n", $IPtag_mapped, $IPtag_mapped* 100/$tagnum_IP);
    printf("WCE\t\t\t%.2f\t%.2f\n", $WCEtag_mapped, $WCEtag_mapped* 100/$tagnum_WCE);
}


sub printresults{
    my ($class) = @_;
    foreach $name (sort{$a cmp $b} keys (%{$Hash_name{$class}})){
#	print "hashlen $Hash_len{$name}\n";
	my$rpkm_IP = 0;
	my $rpkm_WCE = 0;
	my $per = $Hash_len{$name}*100/$genome_len;
	if($Hash_len{$name}!=0){
	    $rpkm_IP = 1e+10 * $Hash_tags_IP{$name} / ($tagnum_IP * $Hash_len{$name});
	    $rpkm_WCE = 1e+10 * $Hash_tags_WCE{$name} / ($tagnum_WCE * $Hash_len{$name});
#	    print "hashlen $Hash_len{$name}, $Hash_tags_IP{$name} $tagnum_IP, $Hash_tags_WCE{$name} $tagnum_WCE $rpkm_IP $rpkm_WCE\n";
	}
	if($rpkm_WCE){
	    $ratio = $rpkm_IP/$rpkm_WCE;	
	}else{
	    $ratio = 0;
	}
	if($outputreads){
	    printf("%s\t%s\t%d\t%.2f\t%.2f\t%.2f\n", $class, $name, $Hash_len{$name}, $per, $Hash_tags_IP{$class}, $Hash_tags_IP{$class}* 100/$tagnum_IP);
	}else{
	    printf("%s\t%s\t%d\t%.3f\t%.2f\t%.2f\t%.2f\n", $class, $name, $Hash_len{$name}, $per, $rpkm_IP, $rpkm_WCE, $ratio);
	}
    }
}

sub read_data_each{
    my ($refarrayIP, $filename, $refnum) = @_;
    open(FILE, "zcat $filename |") || die "cannot open $filename.";
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
    if($buildhg18){$num = int($chrlen_hg18{$chr}/$bin)+1;}
    elsif($buildhg19){$num = int($chrlen_hg19{$chr}/$bin)+1;}
    else{$num = int($chrlen_mm9{$chr}/$bin)+1;}
    for($i=0; $i<$num; $i++){
	$$refarrayIP[$i]=0;
	$$refarrayWCE[$i]=0;
    }
    my $IPname="$prefixIP\_chr$chr.100.wig.gz";
    my $WCEname="$prefixWCE\_chr$chr.100.wig.gz";
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


sub output_class{
    my ($class, $refarrayIP, $refarrayWCE, $chr) = @_;
    my $len=0;
    my $file="$dir/$class-chr$chr.txt";
    if(-e $file){
	open(IN, $file) || die "cannot open $file.";
	while(<IN>){
	    chomp;
	    my $name="";
	    my $start=0, $end=0;
	    @clm= split(/\t/, $_);
	    if($buildmm9){
		$start = $clm[6];
		$end = $clm[7];
		$name = $clm[11];
	    }else{
		$start = $clm[1];
		$end = $clm[2];
		$name = $clm[4];
	    }
	    $Hash_name{$class}{$name}= 1;
	    $Hash_len{$name} += $end - $start;
	    my $s = int($start/$bin);
	    my $e = int($end/$bin);
	    &counttags($name, \%Hash_tags_IP, $refarrayIP, $s, $e);
	    &counttags($name, \%Hash_tags_WCE, $refarrayWCE, $s, $e);
#	    print "$name, $s, $e, $class, $Hash_name{$class}{$name}, $Hash_len{$name}\n";
	}
	close(IN);
    }else{
	print "cannot open $file.\n";
    }
}
    
sub counttags{
    my ($name, $ref_hash, $refarray, $s, $e) = @_;
    my $tags=0;
    for($i=$s; $i<=$e; $i++){ $tags += $$refarray[$i];}
    if(!exists($$ref_hash{$name})){ 
	$$ref_hash{$name} = $tags;
    }else{
	$$ref_hash{$name} += $tags;
    }
}
