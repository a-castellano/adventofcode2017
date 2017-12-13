#!/usr/bin/perl
# Álvaro Castellano Vela - 07/12/2017

use strict;
use warnings;

my $argssize;
my @args;

$argssize = scalar @ARGV;

if ( $argssize != 1 ) {
    print STDERR "This script only accepts one arg.\n";
    exit -1;
}

my $filename = $ARGV[0];

open( my $fh, '<:encoding(UTF-8)', $filename )
  or die "Could not open file '$filename' $!";

my @offsets;

# Read the input
while ( my $jump_offset = <$fh> ) {

    chomp $jump_offset;
    push( @offsets, $jump_offset );
}

close($fh);

my $number_of_steps       = 0;
my $current_position      = 0;
my $offsets_exit_position = scalar @offsets;

while ( $current_position < $offsets_exit_position ) {
    my $jump_offset = $offsets[$current_position];
    $offsets[$current_position]++;
    $current_position += $jump_offset;

    $number_of_steps++;
}

print "Program exited in $number_of_steps steps\n";

exit 0;
