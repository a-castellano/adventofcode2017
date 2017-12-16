#!/usr/bin/perl
# Álvaro Castellano Vela - 16/12/2017

use strict;
use warnings;

sub spin {
    my $spin     = $_[0];
    my @programs = @{ $_[1] };

    my $length  = scalar @programs;
    my @spinned = @programs;

    for ( my $i = 0 ; $i < $length ; $i++ ) {
        $spinned[ ( $i + $spin ) % $length ] = $programs[$i];
    }
    return @spinned;
}

sub exchange {
    my $first_position = $_[0];
    my $second_positon = $_[1];
    my @programs       = @{ $_[2] };

    ( $programs[$first_position], $programs[$second_positon] ) =
      ( $programs[$second_positon], $programs[$first_position] );

    return @programs;
}

sub partner {
    my $first_character  = $_[0];
    my $second_character = $_[1];
    my @programs         = @{ $_[2] };

    my $first_position = 0;
    while ( $programs[$first_position] ne $first_character ) {
        $first_position++;
    }

    my $second_position = 0;
    while ( $programs[$second_position] ne $second_character ) {
        $second_position++;
    }

    return exchange( $first_position++, $second_position, \@programs );
}

sub perform_dance {
    my @programs = @{ $_[0] };
    my @dance    = @{ $_[1] };

    for my $move (@dance) {
        my ( $move_type, $first_part, $second_part ) =
          $move =~ /(s|p|x)(\d+|[a-p])\/?(\d+|[a-p])?$/;
        if ( $move_type eq "s" ) {
            @programs = spin( $first_part, \@programs );
        }
        elsif ( $move_type eq "x" ) {
            @programs = exchange( $first_part, $second_part, \@programs );
        }
        elsif ( $move_type eq "p" ) {
            @programs = partner( $first_part, $second_part, \@programs );
        }
    }
    return @programs;

}

#Main

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

my @programs = ( "a" .. "p" );

my $line = <$fh>;
close($fh);
chomp $line;

my %unique;
my $duplicate_iteration;
my $start_loop;

my @dance = split /,/, $line;

my $string_programs;
$string_programs = join( "", @programs );
$unique{$string_programs} = 0;
for my $iteration ( 1 .. 1000000000 ) {
    @programs = perform_dance( \@programs, \@dance );
    $string_programs = join( "", @programs );
    if ( !exists $unique{$string_programs} ) {
        $unique{$string_programs} = $iteration;
    }
    else {
        $duplicate_iteration = $iteration - $unique{$string_programs};
        last;
    }
}
my $extra_iterations =
  ( 1000000000 - $unique{$string_programs} ) % $duplicate_iteration;

for my $iteration ( 1 .. $extra_iterations ) {
    @programs = perform_dance( \@programs, \@dance );
    $string_programs = join( "", @programs );
}

print "Programs after 1000000000 dances -> $string_programs\n";

exit 0;
