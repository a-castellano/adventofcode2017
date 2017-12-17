#!/usr/bin/perl
# Álvaro Castellano Vela - 17/12/2017

use strict;
use warnings;

#Main

my $argssize;
my @args;

$argssize = scalar @ARGV;

if ( $argssize != 1 ) {
    print STDERR "This script only accepts one arg.\n";
    exit -1;
}

my $step       = int( $ARGV[0] );
my $iterations = 50000000;

my $circular_buffer_value = 0;
my $buffer_size           = 1;

my $current_position = 0;
my $next_value       = 1;

my $next_position;

for my $i ( 1 .. $iterations ) {
    $next_position         = ( $current_position + $step ) % $buffer_size + 1;
    $circular_buffer_value = $next_value if ( $next_position == 1 );
    $current_position      = $next_position;
    $next_value++;
    $buffer_size++;
}

print "Next value after 0 -> $circular_buffer_value\n";

exit 0;
