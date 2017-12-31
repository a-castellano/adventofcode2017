#!/usr/bin/perl
# Álvaro Castellano Vela - 30/12/2017

use strict;
use warnings;
use experimental 'smartmatch';

sub process_blueprint {
    my $filename = $_[0];

    open( my $fh, '<:encoding(UTF-8)', $filename )
      or die "Could not open file '$filename' $!";

    my %states;
    my $initial_state = '';
    my $steps;

    my $line;
    my $state;
    my $value_to_write;

    $line = <$fh>;
    chomp $line;
    $line =~ /Begin in state ([A-Z])\./;
    $initial_state = $1;

    $line = <$fh>;
    chomp $line;
    $line =~ /Perform a diagnostic checksum after ([0-9]+) steps\./;
    $steps = $1;

    while ( $line = <$fh> ) {
        chomp $line;

        #Empty line
        $line = <$fh>;
        chomp $line;
        $line =~ /In state ([A-Z]):/;
        $state                                = $1;
        $states{$state}                       = {};
        $states{$state}{'current_value_is_0'} = {};
        $states{$state}{'current_value_is_1'} = {};

        for my $i ( 0, 1 ) {
            $line = <$fh>;    # If the current value is $
            $line = <$fh>;
            chomp $line;
            $line =~ /- Write the value (0|1)\./;
            $states{$state}{"current_value_is_$i"}{'value_to_write'} = $1;
            $line = <$fh>;
            chomp $line;
            $line =~ /- Move one slot to the (right|left)\./;

            if ( $1 eq "right" ) {
                $states{$state}{"current_value_is_$i"}{'tape_increment'} = 1;
            }
            else {
                $states{$state}{"current_value_is_$i"}{'tape_increment'} = -1;
            }
            $line = <$fh>;
            chomp $line;
            $line =~ /- Continue with state ([A-Z])\./;
            $states{$state}{"current_value_is_$i"}{'next_state'} = $1;
        }

    }
    close($fh);
    return ( $steps, $initial_state, %states );
}

sub check_tape_size {
    my $tape          = $_[0];
    my $tape_size     = $_[1];
    my $tape_position = $_[2];

    if ( $$tape_position == 0 ) {
        unshift @$tape, 0;
        $$tape_size++;
        $$tape_position++;
    }
    elsif ( $$tape_position == $$tape_size - 1 ) {
        push @$tape, 0;
        $$tape_size++;
    }
}

sub make_step {
    my $states        = $_[0];
    my $tape          = $_[1];
    my $current_state = $_[2];
    my $tape_size     = $_[3];
    my $tape_position = $_[4];

    my $current_value = @$tape[$$tape_position];
    @$tape[$$tape_position] =
      $states->{$$current_state}{"current_value_is_$current_value"}
      {'value_to_write'};
    $$tape_position +=
      $states->{$$current_state}{"current_value_is_$current_value"}
      {'tape_increment'};
    $$current_state =
      $states->{$$current_state}{"current_value_is_$current_value"}
      {'next_state'};

    check_tape_size( $tape, $tape_size, $tape_position );
}

sub get_diagnostic_checksum {
    my $tape = $_[0];
    my $ones = 0;
    map { $ones += $_ } @$tape;
    return $ones;
}

#Main

my $argssize;
my @args;

$argssize = scalar @ARGV;

if ( $argssize != 1 ) {
    print STDERR ")This script only accepts one arg.\n";
    exit -1;
}

my $filename      = $ARGV[0];
my @tape          = ( 0, 0, 0 );
my $tape_size     = 3;
my $tape_position = 1;
my ( $steps, $current_state, %states ) = process_blueprint($filename);

for ( my $step = 0 ; $step < $steps ; $step++ ) {
    make_step( \%states, \@tape, \$current_state, \$tape_size,
        \$tape_position );
}

my $diagnostic_checksum = get_diagnostic_checksum( \@tape );

print "Diagnostic checksum -> $diagnostic_checksum\n";

exit 0;
