#!/usr/bin/perl
# Álvaro Castellano Vela - 29/12/2017

use strict;
use warnings;
use experimental 'smartmatch';

sub get_components_from_file {
    my $filename           = $_[0];
    my $components         = $_[1];
    my $list_of_components = $_[2];
    my $bridges            = $_[3];

    open( my $fh, '<:encoding(UTF-8)', $filename )
      or die "Could not open file '$filename' $!";

    my $component_counter = 0;
    my $bridge_counter    = 0;
    while ( my $line = <$fh> ) {
        chomp $line;
        my ( $port_type_a, $port_type_b ) = $line =~ /([0-9]+)\/([0-9]+)/;

        push( @$list_of_components, [ $port_type_a, $port_type_b ] );

        if ( $port_type_a == 0 || $port_type_b == 0 ) {
            my %bridge;
            if ( $port_type_a == 0 ) {
                $bridge{'unplugged'} = $port_type_b;
            }
            else {
                $bridge{'unplugged'} = $port_type_a;
            }
            $bridge{'components'} = [$component_counter];
            $bridges->[$bridge_counter] = {%bridge};
            $bridge_counter++;
        }
        if ( !exists $components->{$port_type_a} ) {
            $components->{$port_type_a} = [];
        }
        if ( !( $component_counter ~~ @{ $components->{$port_type_a} } ) ) {
            push( @{ $components->{$port_type_a} }, $component_counter );
        }
        if ( !exists $components->{$port_type_b} ) {
            $components->{$port_type_b} = [];
        }
        if ( !( $component_counter ~~ @{ $components->{$port_type_b} } ) ) {
            push( @{ $components->{$port_type_b} }, $component_counter );
        }

        $component_counter++;
    }

    close($fh);
}

sub get_compatible_components {
    my $bridge             = $_[0];
    my $components         = $_[1];
    my $list_of_components = $_[2];

    my @compatible_components;

    my $unplugged_component = $bridge->{'unplugged'};
    for my $candidate_component ( @{ $components->{$unplugged_component} } ) {
        if ( !( $candidate_component ~~ @compatible_components ) ) {
            if ( !( $candidate_component ~~ @{ $bridge->{'components'} } ) ) {
                push( @compatible_components, $candidate_component );
            }
        }

    }

    @compatible_components = sort { $a <=> $b } @compatible_components;
    return @compatible_components;
}

sub get_strength {
    my $bridge             = $_[0];
    my $list_of_components = $_[1];
    my $strength           = 0;

    for my $component_id ( @{ $bridge->{'components'} } ) {

        my @component = @{ $list_of_components->[$component_id] };
        $strength += $component[0];
        $strength += $component[1];
    }

    return $strength;
}

sub get_length {
    my $bridge = $_[0];
    return scalar( @{ $bridge->{'components'} } );
}

sub get_strongest_bridge {
    my %bridge             = %{ $_[0] };
    my $components         = $_[1];
    my $list_of_components = $_[2];

    my @available_components =
      get_compatible_components( \%bridge, $components, $list_of_components );

    my $strongest = 0;
    my $strength;
    my $longest = 0;
    my $length;

    if ( ( scalar @available_components ) == 0 ) {
        $length = get_length( \%bridge );
        if ( $length > $longest ) {
            $longest = $length;
            $strongest = get_strength( \%bridge, $list_of_components );
        }
        elsif ( $length == $longest ) {
            $strength = get_strength( \%bridge, $list_of_components );
            $strongest = $strength if ( $strength > $strongest );
        }
    }
    else {
        for my $component_id (@available_components) {
            my %bridge_copy;
            @{ $bridge_copy{'components'} } = @{ $bridge{'components'} };
            $bridge_copy{'unplugged'} = $bridge{'unplugged'};
            push( @{ $bridge_copy{'components'} }, $component_id );

            my @component = @{ $list_of_components->[$component_id] };

            if ( $component[0] == $bridge_copy{'unplugged'} ) {
                $bridge_copy{'unplugged'} = $component[1];
            }
            else {
                $bridge_copy{'unplugged'} = $component[0];
            }

            ( $strength, $length ) =
              get_strongest_bridge( \%bridge_copy, $components,
                $list_of_components );
            if ( $length > $longest ) {
                $longest   = $length;
                $strongest = $strength;
            }
            elsif ( $length == $longest ) {
                $strongest = $strength if ( $strength > $strongest );
            }
        }
    }
    return ( $strongest, $longest );
}

#Main

my $argssize;
my @args;

$argssize = scalar @ARGV;

if ( $argssize != 1 ) {
    print STDERR ")This script only accepts one arg.\n";
    exit -1;
}

my $filename = $ARGV[0];
my %components;
my @list_of_components;
my @bridges;

get_components_from_file( $filename, \%components, \@list_of_components,
    \@bridges );

my $number_of_components = scalar @list_of_components;

my $strongest = 0;
my $strength;
my $longest = 0;
my $length;

for my $bridge (@bridges) {
    ( $strength, $length ) =
      get_strongest_bridge( \%{$bridge}, \%components, \@list_of_components );
    if ( $length > $longest ) {
        $longest   = $length;
        $strongest = $strength;
    }
    elsif ( $length == $longest ) {
        $strongest = $strength if ( $strength > $strongest );
    }
}

print "Longest bridge has $strongest points of strength\n";

exit 0;
