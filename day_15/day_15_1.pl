#!/usr/bin/perl
# Álvaro Castellano Vela - 15/12/2017

use strict;
use warnings;

sub next_value {
    my $previous = $_[0];
    my $factor   = $_[1];
    my $divider  = $_[2];

    return ( $previous * $factor ) % $divider;
}

#Main

my $argssize;
my @args;

$argssize = scalar @ARGV;

if ( $argssize != 2 ) {
    print STDERR "This script only accepts two args.\n";
    exit -1;
}

my $previous_a = $ARGV[0];
my $previous_b = $ARGV[1];

my $factor_a = 16807;
my $factor_b = 48271;
my $divider  = 2147483647;

my $times = 40000000;

my $final_clount = 0;

for my $i ( 1 .. $times ) {
    my $next_a = next_value( $previous_a, $factor_a, $divider );
    my $next_b = next_value( $previous_b, $factor_b, $divider );

    $previous_a = $next_a;
    $previous_b = $next_b;

    my $binary_a = sprintf( "%b", $previous_a );
    my $binary_b = sprintf( "%b", $previous_b );

    while ( length $binary_a < 16 ) {
        $binary_a = '0' . $binary_a;
    }

    while ( length $binary_b < 16 ) {
        $binary_b = '0' . $binary_b;
    }

    my $sub_binary_a = substr( $binary_a, -16 );
    my $sub_binary_b = substr( $binary_b, -16 );

    $final_clount += 1 if ( $sub_binary_a == $sub_binary_b );

}

print "Final count -> $final_clount\n";

exit 0;
