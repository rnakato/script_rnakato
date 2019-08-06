#############################################################################
# Data: Aug 26, 2009
# Author: Pei Fen Kuan
# This function converts the fa files to 0(if A or T) and 1(if G or C). First
# download the whole sequence for the chromosome from UCSC.  To use, type
# perl convert_fa_file_binary_allNuc.pl chrX.fa X 1
#############################################################################

#!/usr/bin/perl
use strict;
use warnings;

my ($infile, $outfile, $binsize) = @ARGV;
my $outfile_GC = $outfile."_GC_binary.txt";
my $outfile_N = $outfile."_N_binary.txt";

open (IN, "$infile") or die "cannot open $infile in Step 1\n";
open (OUT_tmp,">out_tmp.txt") or die "cannot open out_tmp.txt in Step 1\n";

my $line = <IN>;
while (<IN>) {
  chomp;
  my ($name,@sequence) = split "\n";  # split record into the >id line and several seq lines
  next unless $name =~ /^(\S+)/;      # look for the id at the beginning
  print OUT_tmp $1,@sequence;       # print id, tab, sequence lines and newline
}

close IN;
close OUT_tmp;

open (IN, "out_tmp.txt") or die "cannot open out_tmp.txt in Step 2\n";
open (OUT_GC, ">$outfile_GC") or  die "cannot open $outfile_GC in Step 2\n";
open (OUT_N, ">$outfile_N") or  die "cannot open $outfile_N in Step 2\n";

my $seq;
while (my $seq_tmp = <IN>) {
  chomp $seq_tmp;
  $seq = $seq_tmp;
 }
close IN;
system('rm -rf out_tmp.txt');

my $max = int(length($seq)/$binsize);
gc_content($seq,$binsize,$max);

sub gc_content {
  my $seq = shift;                        # sequence
  my $win = shift;                        # window
  my $maxID = shift;

  for (my $i = 0; $i <= $maxID; $i++) { # slide across sequence one bp at a time
    my $j = $i*$win;
    my $segment = substr($seq,$j,$win);  # fetch out a segment of the sequence $win bp long starting at $i
    my $g_count = $segment =~ tr/Gg/Gg/;
    $segment = substr($seq,$j,$win);
    my $c_count = $segment =~ tr/Cc/Cc/;
    $segment = substr($seq,$j,$win);
    my $t_count = $segment =~ tr/Tt/Tt/;
    $segment = substr($seq,$j,$win);
    my $a_count = $segment =~ tr/Aa/Aa/;
    $segment = substr($seq,$j,$win);
    my $gc_count = $segment =~ tr/GCgc/GCgc/;  # trick alert -- see manual entry for tr////
    $segment = substr($seq,$j,$win);
    my $n_count = $segment =~ tr/Nn/Nn/;  # trick alert -- see manual entry for tr////
    #my $gc_content = 100 * $gc_count/length($segment);
    print OUT_GC "$gc_count ";
    print OUT_N "$n_count ";

  }
}

close OUT_GC;
close OUT_N;
