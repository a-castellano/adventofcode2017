#!/usr/bin/perl
# Álvaro Castellano Vela - 03/12/2017

use strict;
use warnings;
use Math::Complex;
use POSIX qw/ceil/;

sub get_max_number_from_dimensiom {
    return ( ( ( 2 * $_[0] ) + 1 )**2 );
}

my $argssize;
my @args;

$argssize = scalar @ARGV;

if ( $argssize != 1 ) {
    print STDERR "This script only accepts one arg.\n";
    exit -1;
}

if ( $ARGV[0] =~ /[[:alpha:]]/ ) {
    print STDERR "Input must contain only numbers.\n";
    exit -1;
}

my $number    = $ARGV[0];
my $dimension = int( sqrt($number) / 2 );

if ( get_max_number_from_dimensiom($dimension) < $number ) {
    $dimension++;
}

my $numbers_in_previous_dimension =
  get_max_number_from_dimensiom( $dimension - 1 );

print "Number -> $number\n";
print "Dimension -> $dimension\n";

#numbers_between_dimensions = 8 * dimension

#my $numbers_between_dimensions = get_max_number_from_dimensiom( $dimension ) - get_max_number_from_dimensiom( $dimension -1 );
my $numbers_between_dimensions = 8 * $dimension;
print "Numbers btween dimensions -> $numbers_between_dimensions\n";

my $max_steps_in_this_dimension = $dimension * 2;
my $min_steps_in_this_dimension = $dimension;

print "Max steps in this dimension -> $max_steps_in_this_dimension\n";
print "Min steps in this dimension -> $min_steps_in_this_dimension\n";

#my $numbers_by_octet = $numbers_between_dimensions / 8;
my $numbers_by_octet = $min_steps_in_this_dimension;

print "Numbers by octet -> $numbers_by_octet\n";

my $octet_where_number_is_in =
  ceil( ( $number - $numbers_in_previous_dimension ) / $numbers_by_octet );

print "$number is placed in $octet_where_number_is_in th octet\n";

my $previous_octet_value =
  ( $octet_where_number_is_in - 1 ) * $numbers_by_octet +
  $numbers_in_previous_dimension;

print "Previous octet value -> $previous_octet_value\n";

my $numbers_from_previous_octet_value_to_number =
  $number - $previous_octet_value;

print
"Numbers from previous octet value to number -> $numbers_from_previous_octet_value_to_number\n";

my $steps;

if ( $octet_where_number_is_in % 2 ) {
    $steps =
      $max_steps_in_this_dimension -
      $numbers_from_previous_octet_value_to_number;
}
else {
    $steps =
      $min_steps_in_this_dimension +
      $numbers_from_previous_octet_value_to_number;
}

print "Steps -> $steps";
