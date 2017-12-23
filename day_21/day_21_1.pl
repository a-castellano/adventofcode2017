#!/usr/bin/perl
# Álvaro Castellano Vela - 21/12/2017

use strict;
use warnings;
use experimental 'smartmatch';

sub process_rules_file {
    my $filename = $_[0];

    open( my $fh, '<:encoding(UTF-8)', $filename )
      or die "Could not open file '$filename' $!";

    my %rules;

    $rules{'2'} = {};
    $rules{'3'} = {};

    while ( my $line = <$fh> ) {
        chomp $line;
        my ( $pattern, $result ) = $line =~ /([.#\/]+) => ([.#\/]+)$/;
        my $pattern_lengh = $pattern =~ tr/\//\//;
        $pattern_lengh++;
        $rules{$pattern_lengh}{$pattern}{'result'} = $result;
    }
    close($fh);
    return %rules;
}

sub get_flips {
    my @parts = @{ $_[0] };

    my $number_of_parts = scalar @parts;
    my @variations;

    my $variation;
    if ( $number_of_parts == 2 ) {

        # Flip 1
        $variation =
          join( "/", ( ( reverse $parts[0] ), ( reverse $parts[1] ), ) );

        push( @variations, $variation )
          unless ( $variation ~~ @variations );

        # Flip 2
        $variation =
          join( "/", ( ( $parts[1] ), ( $parts[0] ) ) );

        push( @variations, $variation )
          unless ( $variation ~~ @variations );

        # Flip 3
        $variation =
          join( "/", ( ( reverse $parts[1] ), ( reverse $parts[0] ) ) );

        push( @variations, $variation )
          unless ( $variation ~~ @variations );

    }

    elsif ( $number_of_parts == 3 ) {

        # Flip 1
        $variation = join(
            "/",
            (
                ( reverse $parts[0] ),
                ( reverse $parts[1] ),
                ( reverse $parts[2] )
            )
        );

        push( @variations, $variation )
          unless ( $variation ~~ @variations );

        # Flip 2
        $variation =
          join( "/", ( ( $parts[2] ), ( $parts[1] ), ( $parts[0] ) ) );

        push( @variations, $variation )
          unless ( $variation ~~ @variations );

        # Flip 3
        $variation = join(
            "/",
            (
                ( reverse $parts[2] ),
                ( reverse $parts[1] ),
                ( reverse $parts[0] )
            )
        );

        push( @variations, $variation )
          unless ( $variation ~~ @variations );

    }
    return @variations;
}

sub calculate_flips_and_rotation {
    my $pattern = $_[0];

    my $pattern_lengh = $pattern =~ tr/\//\//;
    $pattern_lengh++;

    my $re            = qr/([.#]+)/;
    my @pattern_parts = $pattern =~ /$re/g;

    my @pattern_variations;

    push( @pattern_variations, $pattern );

    my $variation;

    my @matrix;
    for ( my $i = 0 ; $i < $pattern_lengh ; $i++ ) {
        my @row = split //, $pattern_parts[$i];
        for ( my $j = 0 ; $j < scalar @row ; $j++ ) {
            $matrix[$i][$j] = $row[$j];
        }
    }

    if ( $pattern_lengh == 2 ) {

        for my $flip_variation ( get_flips( \@pattern_parts ) ) {
            push( @pattern_variations, $flip_variation )
              unless ( $flip_variation ~~ @pattern_variations );
        }

        my @part;

        #Rotation 1
        $part[0] = join( "", ( $matrix[1][0], $matrix[0][0] ) );
        $part[1] = join( "", ( $matrix[1][1], $matrix[0][1] ) );
        $variation = join( "/", ( $part[0], $part[1], ) );

        push( @pattern_variations, $variation )
          unless ( $variation ~~ @pattern_variations );

        for my $flip_variation ( get_flips( \@part ) ) {
            push( @pattern_variations, $flip_variation )
              unless ( $flip_variation ~~ @pattern_variations );
        }

        #Rotation 2
        $part[0] = join( "", ( $matrix[1][1], $matrix[1][0] ) );
        $part[1] = join( "", ( $matrix[0][1], $matrix[0][0] ) );
        $variation = join( "/", ( $part[0], $part[1], ) );

        push( @pattern_variations, $variation )
          unless ( $variation ~~ @pattern_variations );

        for my $flip_variation ( get_flips( \@part ) ) {
            push( @pattern_variations, $flip_variation )
              unless ( $flip_variation ~~ @pattern_variations );
        }

        #Rotation 3
        $part[0] = join( "", ( $matrix[0][1], $matrix[1][1] ) );
        $part[1] = join( "", ( $matrix[0][0], $matrix[1][0] ) );
        $variation = join( "/", ( $part[0], $part[1], ) );

        push( @pattern_variations, $variation )
          unless ( $variation ~~ @pattern_variations );

        for my $flip_variation ( get_flips( \@part ) ) {
            push( @pattern_variations, $flip_variation )
              unless ( $flip_variation ~~ @pattern_variations );
        }

    }
    elsif ( $pattern_lengh == 3 ) {

        for my $flip_variation ( get_flips( \@pattern_parts ) ) {
            push( @pattern_variations, $flip_variation )
              unless ( $flip_variation ~~ @pattern_variations );
        }

        my @part;

        #Rotation 1
        $part[0] = join( "", ( $matrix[2][0], $matrix[1][0], $matrix[0][0] ) );
        $part[1] = join( "", ( $matrix[2][1], $matrix[1][1], $matrix[0][1] ) );
        $part[2] = join( "", ( $matrix[2][2], $matrix[1][2], $matrix[0][2] ) );
        $variation = join( "/", ( $part[0], $part[1], $part[2], ) );

        push( @pattern_variations, $variation )
          unless ( $variation ~~ @pattern_variations );

        for my $flip_variation ( get_flips( \@part ) ) {
            push( @pattern_variations, $flip_variation )
              unless ( $flip_variation ~~ @pattern_variations );
        }

        #Rotation 2
        $part[0] = join( "", ( $matrix[0][2], $matrix[1][2], $matrix[2][2] ) );
        $part[1] = join( "", ( $matrix[0][1], $matrix[1][1], $matrix[2][1] ) );
        $part[2] = join( "", ( $matrix[0][0], $matrix[1][0], $matrix[2][0] ) );
        $variation = join( "/", ( $part[0], $part[1], $part[2], ) );

        push( @pattern_variations, $variation )
          unless ( $variation ~~ @pattern_variations );

        for my $flip_variation ( get_flips( \@part ) ) {
            push( @pattern_variations, $flip_variation )
              unless ( $flip_variation ~~ @pattern_variations );
        }

    }
    return @pattern_variations;
}

sub process_pattern {
    my $rules   = $_[0];
    my $pattern = $_[1];

    my $size;
    $size = $pattern =~ tr/\//\//;
    $size++;

    my $patten_without_slashes = $pattern;
    $patten_without_slashes =~ s/\///g;
    my $row_lenght = $pattern =~ /([.#])+/;

    my $number_of_parts;
    my $step;
    my $new_size;

    if ( $size % 2 == 0 ) {
        $number_of_parts = $size / 2;
        $step            = 2;
        $new_size        = 3 * $number_of_parts;
    }
    elsif ( $size % 3 == 0 ) {
        $number_of_parts = $size / 3;
        $step            = 3;
        $new_size        = 4 * $number_of_parts;
    }

    my @array_pattern = split //, $patten_without_slashes;

    my $new_pattern;
    my @new_pattern_array;

    for ( my $i = 0 ; $i < $size ; $i += $step ) {
        for ( my $j = 0 ; $j < $size ; $j += $step ) {
            my $subpattern = '';
            for ( my $k = 0 ; $k < $step ; $k++ ) {

                for ( my $l = 0 ; $l < $step ; $l++ ) {
                    my $pos_x          = $i + $k;
                    my $pos_y          = $j + $l;
                    my $array_position = $size * $pos_x + $pos_y;

                    $subpattern .= $array_pattern[$array_position];
                }
                $subpattern .= '/';

            }
            $subpattern = substr( $subpattern, 0, ( length $subpattern ) - 1 );
            my @variations = calculate_flips_and_rotation($subpattern);
            my $found      = 0;
            for my $variation (@variations) {
                if ( exists $rules->{$step}{$variation} ) {
                    $found = 1;
                    my $result = $rules->{$step}{$variation}{'result'};
                    push( @new_pattern_array, $result );
                }
            }
            if ( !$found ) {
                die("Not found");
            }
        }
    }

    my @rows;
    for ( my $i = 0 ; $i < $new_size ; $i++ ) {
        $rows[$i] = "";
    }
    for ( my $i = 0 ; $i < scalar @new_pattern_array ; $i++ ) {
        my @rows_in_pattern = split /\//, $new_pattern_array[$i];
        for ( my $j = 0 ; $j < scalar @rows_in_pattern ; $j++ ) {
            my $pos = $j + int( $i / $number_of_parts ) * ( $step + 1 );
            $rows[$pos] .= $rows_in_pattern[$j];
        }
    }
    $new_pattern = join( "", @rows );
    $new_pattern =~ s/(.{$new_size})/$1\//g;
    $new_pattern = substr( $new_pattern, 0, ( length $new_pattern ) - 1 );
    return $new_pattern;
}

#Main

my $argssize;
my @args;

$argssize = scalar @ARGV;

if ( $argssize != 2 ) {
    print STDERR
"This script only accepts one two args, a filename and the number of rotations.\n";
    exit -1;
}

my $filename   = $ARGV[0];
my $iterations = int( $ARGV[1] );

my $start_pattern = '.#./..#/###';

my $pattern = $start_pattern;
my %rules   = process_rules_file($filename);

for ( my $i = 0 ; $i < $iterations ; $i++ ) {
    $pattern = process_pattern( \%rules, $pattern );
}

my $number_of_hashses = $pattern =~ tr/#/#/;

print "There are $number_of_hashses pixels on.\n";
exit 0;
