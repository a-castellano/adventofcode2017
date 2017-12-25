#!/usr/bin/perl
# Álvaro Castellano Vela - 25/12/2017

use strict;
use warnings;

sub get_grid_from_file {
    my $filename = $_[0];

    open( my $fh, '<:encoding(UTF-8)', $filename )
      or die "Could not open file '$filename' $!";

    my @grid;
    my $row_counter    = 0;
    my $infected_nodes = 0;
    while ( my $line = <$fh> ) {
        chomp $line;
        my $column_counter = 0;
        for my $node_status ( split //, $line ) {
            $grid[$row_counter][$column_counter] = $node_status;
            $column_counter++;
        }
        $row_counter++;
        $infected_nodes += $line =~ tr/#/#/;
    }
    close($fh);
    return ( $infected_nodes, @grid );
}

sub increase_grid_size {
    my $grid             = $_[0];
    my $current_position = $_[1];
    my $grid_size        = $_[2];

    my @increased_grid;
    my $increased_grid_size = $grid_size + 2;

    for ( my $i = 0 ; $i < $increased_grid_size ; $i++ ) {
        $increased_grid[0][$i]                = '.';
        $increased_grid[$i][0]                = '.';
        $increased_grid[ $grid_size + 1 ][$i] = '.';
        $increased_grid[$i][ $grid_size + 1 ] = '.';
    }
    for ( my $i = 0 ; $i < $grid_size ; $i++ ) {
        for ( my $j = 0 ; $j < $grid_size ; $j++ ) {
            $increased_grid[ $i + 1 ][ $j + 1 ] = $grid->[$i][$j];
        }
    }
    $grid = [];
    $current_position->[0] += 1;
    $current_position->[1] += 1;
    return @increased_grid;
}

sub make_burst {
    my $grid             = $_[0];
    my $current_position = $_[1];
    my $direction        = $_[2];

    my $infected_node = 0;
    my $turn_to;

    if ( $grid->[ $current_position->[0] ][ $current_position->[1] ] eq '.' ) {
        $grid->[ $current_position->[0] ][ $current_position->[1] ] = '#';
        $infected_node                                              = 1;
        $turn_to                                                    = "Left";
    }
    else {    # Is infected
        $grid->[ $current_position->[0] ][ $current_position->[1] ] = '.';
        $turn_to = "Right";
    }

    # Calculate Next Position
    if ( $direction eq "Up" ) {
        if ( $turn_to eq "Right" ) {
            $direction = "Right";
            $current_position->[1] += 1;
        }
        else {    #Left
            $direction = "Left";
            $current_position->[1] -= 1;
        }
    }
    elsif ( $direction eq "Down" ) {
        if ( $turn_to eq "Right" ) {
            $direction = "Left";
            $current_position->[1] -= 1;
        }
        else {    #Left
            $direction = "Right";
            $current_position->[1] += 1;
        }
    }
    elsif ( $direction eq "Right" ) {
        if ( $turn_to eq "Right" ) {
            $direction = "Down";
            $current_position->[0] += 1;
        }
        else {    #Left
            $direction = "Up";
            $current_position->[0] -= 1;
        }
    }
    elsif ( $direction eq "Left" ) {
        if ( $turn_to eq "Right" ) {
            $direction = "Up";
            $current_position->[0] -= 1;
        }
        else {    #Left
            $direction = "Down";
            $current_position->[0] += 1;
        }
    }
    return ( $infected_node, $direction );
}

sub show_grid {
    my $grid      = $_[0];
    my $grid_size = $_[1];

    for ( my $i = 0 ; $i < $grid_size ; $i++ ) {
        for ( my $j = 0 ; $j < $grid_size ; $j++ ) {
            print " $grid->[$i][$j]";
        }

        print "\n";
    }
}

#Main

my $argssize;
my @args;

$argssize = scalar @ARGV;

if ( $argssize != 2 ) {
    print STDERR
"This script only accepts one two args, a filename and the number of bursts.\n";
    exit -1;
}

my $filename = $ARGV[0];
my $bursts   = int( $ARGV[1] );

my ( $infected_nodes, @grid ) = get_grid_from_file($filename);
my $grid_size          = scalar @grid;
my $middle_position    = int( $grid_size / 2 + 0.5 ) - 1;
my @current_position   = ( $middle_position, $middle_position );
my $new_infected_nodes = 0;

my $direction = "Up";
my $infected;

for ( my $i = 0 ; $i < $bursts ; $i++ ) {
    ( $infected, $direction ) =
      make_burst( \@grid, \@current_position, $direction );
    $infected_nodes     += $infected;
    $new_infected_nodes += $infected;
    if (   $current_position[0] == 0
        || $current_position[1] == 0
        || $current_position[0] == $grid_size - 1
        || $current_position[1] == $grid_size - 1 )
    {
        @grid = increase_grid_size( \@grid, \@current_position, $grid_size );
        $grid_size += 2;
    }
}

print "End -> $new_infected_nodes bursts of activity caused an infection\n";
exit 0;
