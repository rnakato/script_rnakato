#!/usr/bin/env perl

use Excel::Writer::XLSX;

my $input = $ARGV[0];
my $output = $ARGV[1];

# Create a new Excel workbook
my $workbook = Excel::Writer::XLSX->new($output);
 
# Add a worksheet
my $worksheet = $workbook->add_worksheet();
 
#  Add and define a format
my $format = $workbook->add_format();
$format->set_bold();
$format->set_color( 'red' );
$format->set_align( 'center' );
 
# Write a formatted and unformatted string, row and column notation.
my $col = 0;
my $row = 0;
$worksheet->write( $row, $col, 'Hi Excel!', $format );
$worksheet->write( 1, $col, 'Hi Excel!' );
 
# Write a number and a formula using A1 notation
$worksheet->write( 'A3', 1.2345 );
$worksheet->write( 'A4', '=SIN(PI()/4)' );
