#!/usr/bin/perl
# Álvaro Castellano Vela - 03/12/2017

use strict;
use warnings;

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

my @input = ( split( '', $ARGV[0] ) );
my $inputsize = scalar @input;

#As the imput is a circular list we're going to fake it
$input[$inputsize] = $input[0];

my $result = 0;

for ( my $i = 0 ; $i < $inputsize ; $i++ ) {
    if ( $input[$i] == $input[ $i + 1 ] ) {
        $result += $input[$i];
    }
}

print "Result => $result\n";
exit 0;
