#!/usr/bin/perl
# Álvaro Castellano Vela - 18/12/2017

use strict;
use warnings;
use Data::Dumper;

#$current_position = process_instruction(\%registers,\@instructions, \$last_played, \$last_recovered, $current_position);

sub process_instruction {
    my $registers        = $_[0];
    my $instructions     = $_[1];
    my $current_position = $_[2];

    my $command   = $instructions->[$current_position]{'command'};
    my $first_arg = $instructions->[$current_position]{'first_arg'};

    my $second_arg;

    if ( $command ne "snd" && $command ne "rcv" ) {
        $second_arg = $instructions->[$current_position]{'second_arg'};
        if ( $second_arg =~ /[a-z]/ ) {
            if ( !exists $registers->{$second_arg} ) {

                $registers->{$second_arg} = 0;
            }
            $second_arg = $registers->{$second_arg};
        }
    }

    # Second arg is now a number in any case

    if ( $command eq "set" ) {
        if ( !exists $registers->{$first_arg} ) {
            $registers->{$first_arg} = 0;
        }
        $registers->{$first_arg} = $second_arg;
        $current_position++;
    }
    elsif ( $command eq "add" ) {
        if ( !exists $registers->{$first_arg} ) {
            $registers->{$first_arg} = 0;
        }
        $registers->{$first_arg} += $second_arg;
        $current_position++;
    }
    elsif ( $command eq "mul" ) {
        if ( !exists $registers->{$first_arg} ) {
            $registers->{$first_arg} = 0;
        }
        $registers->{$first_arg} *= $second_arg;
        $current_position++;
    }
    elsif ( $command eq "mod" ) {
        if ( !exists $registers->{$first_arg} ) {
            $registers->{$first_arg} = 0;
        }
        if ( $registers->{$first_arg} >= $second_arg ) {
            $registers->{$first_arg} = $registers->{$first_arg} % $second_arg;
        }
        $current_position++;
    }
    elsif ( $command eq "snd" ) {
        if ( !exists $registers->{$first_arg} ) {
            $registers->{$first_arg} = 0;
        }
        $registers->{'last_played'} = $registers->{$first_arg};
        $current_position++;
    }
    elsif ( $command eq "rcv" ) {
        if ( !exists $registers->{$first_arg} ) {
            $registers->{$first_arg} = 0;
        }
        $registers->{'last_recovered'} = $registers->{'last_played'};
        $current_position++;
    }
    elsif ( $command eq "jgz" ) {
        if ( $first_arg =~ /[a-z]/ ) {
            if ( !exists $registers->{$first_arg} ) {
                $registers->{$first_arg} = 0;
            }
            $first_arg = $registers->{$first_arg};
        }

        if ( $first_arg > 0 ) {
            $current_position += $second_arg;
        }
        else {

            $current_position++;
        }
    }

    return $current_position;
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

my @instructions;
my $counter = 1;

while ( my $line = <$fh> ) {
    chomp $line;
    my ( $command, $first_arg ) = $line =~ /([a-z]+) ([a-z]|[0-9]+)/;

    my %instruction;
    $instruction{'command'}    = $command;
    $instruction{'first_arg'}  = $first_arg;
    $instruction{'second_arg'} = '';

    if (   $command eq 'set'
        || $command eq 'add'
        || $command eq 'mod'
        || $command eq 'jgz'
        || $command eq 'mul' )
    {

        my ($second_arg) = $line =~ /[a-z]+ [a-z] (-?[0-9]+)$/;
        if ( !defined $second_arg ) {
            my ($second_arg) = $line =~ /[a-z]+ [a-z] ([a-z])$/;
            $instruction{'second_arg'} = $second_arg;
        }
        else {
            $instruction{'second_arg'} = $second_arg;
        }

    }

    push( @instructions, \%instruction );

    $counter++;
}

my $end_position = scalar @instructions;

my $current_position = 0;
my %registers;

while ( $current_position < $end_position
    && !( exists $registers{'last_recovered'} ) )
{
    $current_position =
      process_instruction( \%registers, \@instructions, $current_position );

    #print "Current -> $current_position\n";
}

close($fh);

print "Last recovered -> $registers{'last_recovered'}\n";

exit 0;
