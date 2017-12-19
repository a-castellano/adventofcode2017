#!/usr/bin/perl
# Álvaro Castellano Vela - 19/12/2017

use strict;
use warnings;

sub process_file {
    my $filename = $_[0];

    open( my $fh, '<:encoding(UTF-8)', $filename )
      or die "Could not open file '$filename' $!";

    my @tubes;
    my $row_id = 0;
    while ( my $line = <$fh> ) {
        chomp $line;
        if ( length $line ) {
            my @row = split //, $line;
            my $column_id = 0;
            for my $column (@row) {
                $tubes[$row_id][$column_id] = $column;
                $column_id++;
            }
            $row_id++;

        }
    }
    close($fh);
    return @tubes;
}

sub find_column {
    my $tube = $_[0];

    my $column_id = 0;
    for my $column ( @{ $tube->[0] } ) {
        last if ( $column eq '|' );
        $column_id++;
    }
    return $column_id;
}

sub follow_path {
    my $tube         = $_[0];
    my $first_column = $_[1];

    my @position  = ( 0, $first_column );
    my $direction = "down";
    my $column_id = 0;

    my $max_row    = scalar @{$tube};
    my $max_column = scalar @{ $tube->[0] };

    my $letters = '';
    my $end     = 0;

    my @next_position = ( 0, 0 );
    while ( !$end ) {

        if ( $direction eq "down" ) {
            if ( $position[0] + 1 < $max_row ) {
                @next_position = ( $position[0] + 1, $position[1] );
            }
            else { $end = 1; }
        }
        elsif ( $direction eq "up" ) {
            if ( $position[0] - 1 >= 0 ) {
                @next_position = ( $position[0] - 1, $position[1] );
            }
            else { $end = 1; }
        }
        elsif ( $direction eq "left" ) {
            if ( $position[1] - 1 >= 0 ) {
                @next_position = ( $position[0], $position[1] - 1 );
            }
            else { $end = 1; }
        }
        elsif ( $direction eq "right" ) {
            if ( $position[0] + 1 < $max_column ) {
                @next_position = ( $position[0], $position[1] + 1 );
            }
            else { $end = 1; }
        }

        @position = @next_position;

        #Check next step
        if ( $tube->[ $position[0] ][ $position[1] ] =~ /[A-Z]/ ) {
            $letters .= $tube->[ $position[0] ][ $position[1] ];
        }
        elsif ( $tube->[ $position[0] ][ $position[1] ] eq ' ' ) {
            $end = 1;
        }
        elsif ( $tube->[ $position[0] ][ $position[1] ] eq '+' ) {

            # Change direction
            if ( $direction eq "up" || $direction eq "down" ) {
                if (   $position[1] + 1 < $max_column
                    && $tube->[ $position[0] ][ $position[1] + 1 ] =~
                    /[A-Z]|\+|-/ )
                {
                    $direction = "right";
                }
                elsif ($position[1] - 1 >= 0
                    && $tube->[ $position[0] ][ $position[1] - 1 ] =~
                    /[A-Z]|\+|-/ )
                {
                    $direction = "left";
                }
                else {
                    $end = 1;
                }
            }
            elsif ( $direction eq "right" || $direction eq "left" ) {
                if (   $position[0] + 1 < $max_row
                    && $tube->[ $position[0] + 1 ][ $position[1] ] =~
                    /[A-Z]|\||-/ )
                {
                    $direction = "down";
                }
                elsif ($position[0] - 1 >= 0
                    && $tube->[ $position[0] - 1 ][ $position[1] ] =~
                    /[A-Z]|\||-/ )
                {
                    $direction = "up";
                }
                else {
                    $end = 1;
                }
            }
        }

    }

    return $letters;
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

my @tubes = process_file($filename);

my $first_column = find_column( \@tubes );

my $letters = follow_path( \@tubes, $first_column );

print "Letters -> $letters\n";
exit 0;
