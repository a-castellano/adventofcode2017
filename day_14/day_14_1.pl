#!/usr/bin/perl
# Álvaro Castellano Vela - 14/12/2017

use strict;
use warnings;

sub knot_hash {
    my $input = $_[0];

    my @suffix = ( 17, 31, 73, 47, 23 );
    my $numbers = 255;

    my @list = ( 0 .. $numbers );
    my @input_lengths_non_ascii = split //, $input;
    my @input_lengths;

    for my $char (@input_lengths_non_ascii) {
        push( @input_lengths, ord($char) );
    }

    for my $f (@suffix) {
        push( @input_lengths, $f );
    }

    my $array_length     = $numbers + 1;
    my $skip_size        = 0;
    my $current_position = 0;

    for my $round ( 0 .. 63 ) {
        for my $length (@input_lengths) {
            my @positions_to_select = ( 0 .. $length - 1 );

            for ( my $i = 0 ; $i < scalar @positions_to_select ; $i++ ) {
                $positions_to_select[$i] =
                  ( $positions_to_select[$i] + $current_position )
                  % $array_length;
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
    }

    my @dense_hash;
    for my $block_index ( 0 .. 15 ) {
        my $offset = $block_index * 16;
        my @slice  = @list[ $offset .. $offset + 15 ];

        my $xorresult = 0;

        for my $xor_index (@slice) {
            $xorresult = $xorresult ^ $xor_index;
        }
        push( @dense_hash, $xorresult );
    }

    my @xor_hash;
    for my $block_index ( 0 .. 15 ) {
        my $offset = $block_index * 16;
        my @slice  = @list[ $offset .. $offset + 15 ];

        my $xorresult = 0;

        for my $xor_index (@slice) {
            $xorresult = $xorresult ^ $xor_index;
        }
        push( @xor_hash, $xorresult );
    }

    my @hex_dense_hash;
    my $binary_dense_hash = "";

    for my $dec (@xor_hash) {
        my $hex = sprintf( "%x", $dec );

        $binary_dense_hash .= "0000" if ( ( length $hex ) == 1 );
        for my $h ( split //, $hex ) {
            my $binary = sprintf( "%b", hex($h) );
            for ( my $b = 0 ; $b < 4 - ( length $binary ) ; $b++ ) {
                $binary_dense_hash .= "0";
            }
            $binary_dense_hash .= $binary;
        }
    }

    return $binary_dense_hash;

}

#Main

my $argssize;
my @args;

$argssize = scalar @ARGV;

if ( $argssize != 1 ) {
    print STDERR "This script only accepts one arg.\n";
    exit -1;
}

my $input = $ARGV[0];
my $squares = 0;

for my $row (0..127)
{
  my $string = $input.'-'."$row";
  my $hash  = knot_hash($string);
  my $processed_hash = $hash;
  $processed_hash =~ s/0//g ;
  my $row_squares = length $processed_hash;
  $squares += $row_squares;
}

print "Total squares -> $squares\n";

exit 0;
