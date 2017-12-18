#!/usr/bin/perl
# Álvaro Castellano Vela - 18/12/2017

use strict;
use warnings;

sub process_instruction {
    my $registers        = $_[0];
    my $queue            = $_[1];
    my $instructions     = $_[2];
    my $deadlock         = $_[3];
    my $current_position = $_[4];
    my $id               = $_[5];
    my $other            = $_[6];

    my $command   = $instructions->[$current_position]{'command'};
    my $first_arg = $instructions->[$current_position]{'first_arg'};

    my $second_arg;

    if ( $command ne "snd" && $command ne "rcv" ) {
        $second_arg = $instructions->[$current_position]{'second_arg'};
        if ( $second_arg =~ /[a-z]/ ) {
            if ( !exists $registers->{$id}{$second_arg} ) {

                $registers->{$id}{$second_arg} = 0;
            }
            $second_arg = $registers->{$id}{$second_arg};
        }
    }

    # Second arg is now a number in any case
    if ( $command eq "set" ) {
        if ( !exists $registers->{$id}{$first_arg} ) {
            $registers->{$id}{$first_arg} = 0;
        }
        $registers->{$id}{$first_arg} = $second_arg;
        $current_position++;
    }
    elsif ( $command eq "add" ) {
        if ( !exists $registers->{$id}{$first_arg} ) {
            $registers->{$id}{$first_arg} = 0;
        }
        $registers->{$id}{$first_arg} += $second_arg;
        $current_position++;
    }
    elsif ( $command eq "mul" ) {
        if ( !exists $registers->{$id}{$first_arg} ) {
            $registers->{$id}{$first_arg} = 0;
        }
        $registers->{$id}{$first_arg} *= $second_arg;
        $current_position++;
    }
    elsif ( $command eq "mod" ) {
        if ( !exists $registers->{$id}{$first_arg} ) {
            $registers->{$id}{$first_arg} = 0;
        }
        if ( $registers->{$id}{$first_arg} >= $second_arg ) {
            $registers->{$id}{$first_arg} = $registers->{$id}{$first_arg} % $second_arg;
        }
        $current_position++;
    }
    elsif ( $command eq "snd" ) {
        if ( !exists $registers->{$id}{$first_arg} ) {
            $registers->{$id}{$first_arg} = 0;
        }
        push @{$queue->{$other}}, $registers->{$id}{$first_arg};
        $registers->{$id}{'send_times'}++;
        $current_position++;
    }
    elsif ( $command eq "rcv" ) {
        if ( !exists $registers->{$id}{$first_arg} ) {
            $registers->{$id}{$first_arg} = 0;
        }
        if (  @{$queue->{$id}} !=0 ) {
            $registers->{$id}{$first_arg} = shift @{$queue->{$id}};
            $current_position++;
            $deadlock = 0;
        }
        else{
            $deadlock = 1;
        }
    }
    elsif ( $command eq "jgz" ) {
        if ( $first_arg =~ /[a-z]/ ) {
            if ( !exists $registers->{$id}{$first_arg} ) {
                $registers->{$id}{$first_arg} = 0;
            }
            $first_arg = $registers->{$id}{$first_arg};
        }

        if ( $first_arg > 0 ) {
            $current_position += $second_arg;
        }
        else {

            $current_position++;
        }
    }

    return ($current_position, $deadlock);
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

        my ($second_arg) = $line =~ /[a-z]+ [a-z0-9]+ (-?[0-9]+)$/;
        if ( !defined $second_arg ) {
            my ($second_arg) = $line =~ /[a-z]+ [a-z0-9]+ ([a-z])$/;
            $instruction{'second_arg'} = $second_arg;
        }
        else {
            $instruction{'second_arg'} = $second_arg;
        }
    }

    push( @instructions, \%instruction );

}

my $end_position = scalar @instructions;

my $current_position_0 = 0;
my $current_position_1 = 0;
my %registers;
my %queue;
$queue{0} = [];
$queue{1} = [];
$registers{0}      = {};
$registers{0}{'p'} = 0;
$registers{0}{'send_times'} = 0;
$registers{1}      = {};
$registers{1}{'p'} = 1;
$registers{1}{'send_times'} = 0;
my $deadlock_0 = 0;
my $deadlock_1 = 0;

while ($current_position_0 < $end_position
    && $current_position_1 < $end_position
    && ( $deadlock_0 == 0 || $deadlock_1 == 0 ) )
{
    ($current_position_0, $deadlock_0) =
      process_instruction( \%registers, \%queue, \@instructions, $deadlock_0,
        $current_position_0, 0, 1 );
    ($current_position_1, $deadlock_1) =
      process_instruction( \%registers, \%queue, \@instructions, $deadlock_1,
        $current_position_1, 1, 0);
}

close($fh);

print "How many times did program 1 send a value? -> $registers{1}{'send_times'}\n";

exit 0;
