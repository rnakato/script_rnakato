#!/usr/bin/env perl

=head1 DESCRIPTION

    describe DESCRIPTION

=head1 SYNOPSIS

    % convert_genename_fromgtf.pl [options] -f file -g gtf

    Options:
    --type=[genes|isoforms]  default is genes
    --outputtype=[all|pc]  default is all
    --nline=(column number of gene ID) default is 0
    --sep=(separator)  default is tab

=cut

use strict;
use warnings;
use autodie;
use Path::Class;
use Getopt::Long qw/:config posix_default no_ignore_case bundling auto_help/;
use Pod::Usage qw/pod2usage/;

my $type="genes";
my $outputtype="all";
my $file="";
my $gtf="";
my $nline=0;
my $sep="\t";

GetOptions(
    "file|f=s" => \$file,
    "gtf|g=s" => \$gtf,
    "type|t=s" => \$type,
    "outputtype|o=s" => \$outputtype,
    "nline|n=i" => \$nline,
    "sep|s=s" => \$sep
) or pod2usage(1);

pod2usage(2) unless $file;
pod2usage(2) unless $gtf;

#print "file=$file, gtf=$gtf, type=$type, outputtype=$outputtype, nline=$nline, sep=$sep\n";

my %Hashgname;
my %Hashtname;
my %Hashgtype;
my %Hashttype;

open(ListFile, $gtf) ||die "error: can't open $gtf.\n";
while(<ListFile>){
    next if($_ eq "\n");
    chomp;
    my @clm = split(/;/, $_);
    my $gene="";
    my $tr="";
    my $genename="";
    my $trname="";
    my $genetype="";
    my $trtype="";
    foreach my $str (@clm){
	$gene = $2 if($str =~ /(.*)gene_id "(.+)"/);
	$tr   = $2 if($str =~ /(.*)transcript_id "(.+)"/);
	$genename = $2 if($str =~ /(.*)gene_name "(.+)"/);
        $trname   = $2 if($str =~ /(.*)transcript_name "(.+)"/);
	$genetype = $2 if($str =~ /(.*)gene_biotype "(.+)"/);
	$trtype = $2 if($str =~ /(.*)transcript_biotype "(.+)"/);
    }
    $Hashgname{$gene}=$genename;
    $Hashtname{$tr}=$trname;
    $Hashgtype{$gene}=$genetype;
    $Hashttype{$tr}=$trtype;
}
close (ListFile);

open(ListFile, $file) ||die "error: can't open $file.\n";
my $line = <ListFile>;
print "\t$line";
while(<ListFile>){
    next if($_ eq "\n");
    chomp;
    my @clm = split(/$sep/, $_);
    my $id = $clm[$nline];
    $id=~ s/"//g;  # "を除去
    my @c= split(/\./, $id); # .10 などのversion番号を除去
    $id=$c[0];
#    print "$id\n";

    if($type eq "genes") {
	next if($outputtype eq "pc" && $Hashgtype{$id} ne "protein_coding" );
	if(exists($Hashgname{$id})){
	    print "$Hashgname{$id}$sep$_\n";
	}else{
	    print "\t$_\n";
	}
    } else {
	next if($outputtype eq "pc" && $Hashttype{$id} ne "protein_coding" );
	if(exists($Hashtname{$id})){
            print "$Hashtname{$id}$sep$_\n";
        }else{
            print "\t$_\n";
        }
    }
}
close (ListFile);
