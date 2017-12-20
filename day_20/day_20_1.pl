#!/usr/bin/perl
# Álvaro Castellano Vela - 20/12/2017

use strict;
use warnings;

sub process_file {
    my $filename = $_[0];

    open( my $fh, '<:encoding(UTF-8)', $filename )
      or die "Could not open file '$filename' $!";

    my @particles;
    while ( my $line = <$fh> ) {
        chomp $line;

        my ( $px, $py, $pz, $vx, $vy, $vz, $ax, $ay, $az ) =
          $line =~
/p=<(-?\d+),(-?\d+),(-?\d+)>, v=<(-?\d+),(-?\d+),(-?\d+)>, a=<(-?\d+),(-?\d+),(-?\d+)>$/;

        my $particle = {
            px       => $px,
            py       => $py,
            pz       => $pz,
            vx       => $vx,
            vy       => $vy,
            vz       => $vz,
            ax       => $ax,
            ay       => $ay,
            az       => $az,
            distance => abs($px) + abs($py) + abs($pz),
        };
        push( @particles, $particle );
    }
    close($fh);

    return @particles;
}

sub increment {

    my $particles           = $_[0];
    my $number_of_particles = scalar @{$particles};

    for ( my $i = 0 ; $i < $number_of_particles ; $i++ ) {
        $particles->[$i]{vx} += $particles->[$i]{ax};
        $particles->[$i]{vy} += $particles->[$i]{ay};
        $particles->[$i]{vz} += $particles->[$i]{az};

        $particles->[$i]{px} += $particles->[$i]{vx};
        $particles->[$i]{py} += $particles->[$i]{vy};
        $particles->[$i]{pz} += $particles->[$i]{vz};

        $particles->[$i]{distance} =
          abs( $particles->[$i]{px} ) +
          abs( $particles->[$i]{py} ) +
          abs( $particles->[$i]{pz} );
    }

}

sub min_particle {
    my $particles           = $_[0];
    my $number_of_particles = scalar @{$particles};

    my $min = $particles->[0]{distance};
    my $min_particle = 0;
    for ( my $i = 1 ; $i < $number_of_particles ; $i++ ) {
        if ( $min > $particles->[$i]{distance} ) {
            $min = $particles->[$i]{distance};
            $min_particle = $i;
        }
    }
    return $min_particle;
}

#Main

my $argssize;
my @args;

$argssize = scalar @ARGV;

if ( $argssize != 2 ) {
    print STDERR "This script only accepts two args. Filename and iterations\n";
    exit -1;
}

my $filename   = $ARGV[0];
my $iterations = $ARGV[1];

my @particles = process_file($filename);

for ( my $i = 0 ; $i < $iterations ; $i++ ) {
    increment( \@particles );
}

my $min_particle = min_particle(\@particles);

print "Particle closest to <0,0,0> -> $min_particle\n";
exit 0;
