#!/usr/bin/perl
# Álvaro Castellano Vela - 10/12/2017

use strict;
use warnings;

# Main

my $argssize;
my @args;

$argssize = scalar @ARGV;

if ( $argssize != 2 ) {
    print STDERR "This script only accepts two args.\n";
    exit -1;
}

my $numbers  = $ARGV[0];
my $filename = $ARGV[1];

open( my $fh, '<:encoding(UTF-8)', $filename )
  or die "Could not open file '$filename' $!";

# Read the input
my $line = <$fh>;

chomp $line;

close($fh);

my @list = ( 0 .. $numbers );
my @input_lengths = split /,/, $line;

my $array_length     = $numbers + 1;
my $skip_size        = 0;
my $current_position = 0;

for my $length (@input_lengths) {
    my @positions_to_select = ( 0 .. $length - 1 );

    for ( my $i = 0 ; $i < scalar @positions_to_select ; $i++ ) {
        $positions_to_select[$i] =
          ( $positions_to_select[$i] + $current_position ) % $array_length;
    }

    my @slice = @list[@positions_to_select];

    # Reverse the slice
    @slice = reverse @slice;

    # Modify list content
    for ( my $i = 0 ; $i < scalar @positions_to_select ; $i++ ) {
        $list[ $positions_to_select[$i] ] = $slice[$i];
    }

    $current_position += $length + $skip_size;
    $skip_size++;
}

my $result = $list[0] * $list[1];

print
  "The result of multiplying the first two numbers in the list is $result\n";

exit 0;
