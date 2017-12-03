#!/usr/bin/perl
# Álvaro Castellano Vela - 03/12/2017

use strict;
use warnings;

my $argssize;
my @args;

$argssize = scalar @ARGV;

if ( $argssize != 1 ){
  print STDERR "This script only accepts one arg.\n";
  exit -1;
}

my $filename = $ARGV[0];

open(my $fh, '<:encoding(UTF-8)', $filename)
  or die "Could not open file '$filename' $!";

my $checksum = 0;

while (my $row = <$fh>) {

  chomp $row;
  my @numbers = split /\s+/, $row;
  my $max = $numbers[0];
  my $min = $numbers[0];

  foreach my $number ( @numbers[ 1 .. @numbers - 1 ] )
  {
    $max = $number if ( $max < $number );
    $min = $number if ( $min > $number );
  }
  $checksum += $max - $min;
}

close( $fh );
print "Checksum => $checksum\n";

exit 0;
