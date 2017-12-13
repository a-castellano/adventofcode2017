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

my @suffix = ( 17, 31, 73, 47, 23 );

open( my $fh, '<:encoding(UTF-8)', $filename )
  or die "Could not open file '$filename' $!";

# Read the input
my $line = <$fh>;

chomp $line;

close($fh);

my @list = ( 0 .. $numbers );
my @input_lengths_non_ascii = split //, $line;
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

my $hex_dense_hash = "";

for my $dec (@dense_hash) {
    my $hex = sprintf( "%x", $dec );

    $hex_dense_hash .= "0" if ( ( length $hex ) == 1 );
    $hex_dense_hash .= $hex;
}

print "Knot Hash -> $hex_dense_hash\n";
exit 0;
