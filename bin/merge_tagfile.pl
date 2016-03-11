#! /usr/bin/perl -w

use Getopt::Long;

$outputdesc=0; $outputRPKM=0; $outputRPM=0; $outputbygene=0; $human=0; $mouse=0; $drosophila=0; $log=0;
GetOptions('od' => \$outputdesc, 'rpkm' => \$outputRPKM, 'rpm' => \$outputRPM, 'gene' => \$outputbygene, 'human' => \$human, 'mouse' => \$mouse, 'drosophila' => \$drosophila, 'log' => \$log);
$num_elem=@ARGV;
if(!$human && !$mouse && !$drosophila){
    print "please specify --human or --mouse or --drosophila\n";
    exit;
}
if($human){ $file_RNA="/home/rnakato/DataBase/H_sapiens/RNAlist.txt";}
elsif($mouse){ $file_RNA="/home/rnakato/DataBase/M_musculus/RNAlist.txt";}
elsif($drosophila){ $file_RNA="/home/rnakato/DataBase/D_melanogaster/RNAlist.txt";}

open(ListFile, $file_RNA) ||die "error: can't open $file_RNA\n";
while($line = <ListFile>){
    next if($line eq "\n");
    chomp($line);
    my @clm = split(/\t/, $line);
 
    if($drosophila){
	$gene = $clm[6];
	$len = $clm[5];
	$desc = $clm[2];
	$rna = $clm[0];
	$variant = $clm[4];
    }else{
	$gene = $clm[4];
	$len = $clm[2];
	$desc = $clm[1];
	$rna = $clm[0];
	$variant = $clm[5];
    }

    if($outputbygene){
	# gene
	if(!exists($Hash_len{$gene})){$Hash_len{$gene} = $len;}
	else{
	    if($Hash_len{$gene} < $len){$Hash_len{$gene} = $len;}
	}
	$Hash_desc{$gene} = $desc;
	$Hash_ID{$rna} = $gene;
    }else{
	# RNA
	$Hash_len{$rna} = $len;
	$Hash_desc{$rna} = $desc;
	$Hash_ID{$rna} = $gene;
	$Hash_tv{$rna} = $variant;
    }
}
close (ListFile);

for($i=0; $i<$num_elem; $i++){
    open(IN, "$ARGV[$i]") || die "error: can't open $ARGV[$i]\n";
    while(<IN>) {
	next if($_ eq "\n");
	chomp;
	if($_ =~/#.+uniq:(.+)/){
	    $tagnum_all[$i] = $1;
	    next;
	}
	@clm= split(/\t/, $_);
	if($outputbygene){
	    if(!exists($Hash->{$ARGV[$i]}{$Hash_ID{$clm[0]}})){
		$Hash->{$ARGV[$i]}{$Hash_ID{$clm[0]}} = $clm[1];
	    }else{
		$Hash->{$ARGV[$i]}{$Hash_ID{$clm[0]}} += $clm[1];
	    }
	    $Hashname{$Hash_ID{$clm[0]}} = 1;
	}else{
	    $Hash->{$ARGV[$i]}{$clm[0]}=$clm[1];
	    $Hashname{$clm[0]} = 1;
	}
    }
    close IN;
}


if($outputRPKM || $outputRPM){
    foreach $name (keys(%Hashname)){
	for($i=0; $i<$num_elem; $i++){
	    if(!exists($Hash->{$ARGV[$i]}{$name})){$Hash->{$ARGV[$i]}{$name} = 0;}
	    if($outputRPKM){ $RPKM->{$i}{$name} = 1e+9 * $Hash->{$ARGV[$i]}{$name} / ($tagnum_all[$i] * $Hash_len{$name});}
	    else{ $RPM->{$i}{$name} = 1e+6 * $Hash->{$ARGV[$i]}{$name} / ($tagnum_all[$i]);}
	}
    }
}

if($outputbygene){
    if($outputdesc){print "gene name\tdescription\tgene length\t";}
    else{print "gene name\tgene length\t";}
}else{
    if($outputdesc){print "Accession Number\tgene name\tvariant\tdescription\tgene length\t";}
    else{print "Accession Number\tgene name\tvariant\tgene length\t";}
}

for($i=0;$i<$num_elem-1; $i++){
    print "$ARGV[$i]\t";
}
print "$ARGV[$num_elem-1]\n";

foreach $name (keys(%Hashname)){
    if($outputbygene){
	if($outputdesc){ print "$name\t$Hash_desc{$name}\t$Hash_len{$name}\t";}
	else{ print "$name\t$Hash_len{$name}\t";}
    }else{
	if($outputdesc){ print "$name\t$Hash_ID{$name}\t$Hash_tv{$name}\t$Hash_desc{$name}\t$Hash_len{$name}\t";}
	else{ print "$name\t$Hash_ID{$name}\t$Hash_tv{$name}\t$Hash_len{$name}\t";}
    }
    for($i=0;$i<$num_elem;$i++){
	if(!exists($Hash->{$ARGV[$i]}{$name})){$Hash->{$ARGV[$i]}{$name} = 0;}

	if($outputRPKM){
	    if($log){printf("%.2f",log($RPKM->{$i}{$name}+1)/log(2));}
	    else{printf("%.2f",$RPKM->{$i}{$name});}
	}elsif($outputRPM){
	    if($log){printf("%.2f",log($RPM->{$i}{$name}+1)/log(2));}
	    else{printf("%.2f",$RPM->{$i}{$name});}
	}else{
	    if($log){printf("%.2f",log($Hash->{$ARGV[$i]}{$name}+1)/log(2));}
	    else{printf("%.2f",$Hash->{$ARGV[$i]}{$name});}
	}
	if ($i!=$num_elem-1){print "\t";}
	else{print "\n";}
    }
}
