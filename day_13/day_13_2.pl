#!/usr/bin/perl
# Álvaro Castellano Vela - 13/12/2017

use strict;
use warnings;

sub caught {
    my @depths     = @{ $_[0] };
    my $picosecond = $_[1];
    my $firewall   = $_[2];

    if ( $depths[$firewall] > 0 ) {
        return ( $firewall + $picosecond ) % $depths[$firewall];
    }
    else {
        return -1;
    }
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

my @depths;

my $current_position = 0;

# Read the input
while ( my $line = <$fh> ) {
    chomp $line;
    my ( $position, $depth, ) = $line =~ /(\d+): (\d+)$/;

    if ( $position > $current_position ) {
        for ( my $i = $current_position + 1 ; $i < $position ; $i++ ) {
            $depths[$i] = 0;
        }
    }
    $depths[$position] = ( $depth * 2 ) - 2;
    $current_position = $position;
}

close($fh);

my $length      = scalar @depths;
my $picosecond  = 0;
my $severity    = 0;
my $passthrough = 0;

if ( $picosecond == 0 and $depths[$picosecond] > 0 ) {
    $picosecond++;
}

while ( $passthrough == 0 ) {
    my $firewall = 0;
    while ( $firewall < scalar @depths ) {
        last if ( caught( \@depths, $picosecond, $firewall ) == 0 );
        $firewall++;
    }
    if ( $firewall == scalar @depths ) {
        $passthrough = 1;
    }
    else {
        $picosecond++;
    }
}
print "Picoseconds until passthrough -> $picosecond\n";

exit 0;
