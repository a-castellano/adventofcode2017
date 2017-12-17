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
my $iterations = 2017;

my @circular_buffer = (0);
my $buffer_size     = scalar @circular_buffer;

my $current_position = 0;
my $next_value       = 1;

for my $i ( 1 .. $iterations ) {
    $buffer_size = scalar @circular_buffer;
    my $next_position = ( $current_position + $step ) % $buffer_size + 1;
    splice @circular_buffer, $next_position, 0, $next_value;
    $current_position = $next_position;
    $next_value++;
}

$buffer_size = scalar @circular_buffer;
my $next = ( $current_position + 1 ) % $buffer_size;

print "Next value after $iterations -> $circular_buffer[$next]\n";

exit 0;
