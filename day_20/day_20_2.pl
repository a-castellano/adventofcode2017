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
    }

}

sub destroy_colliders {
    my $particles           = $_[0];
    my $number_of_particles = scalar @{$particles};

    my %colliders;
    my @particles_to_destroy;

    for ( my $i = 0 ; $i < $number_of_particles ; $i++ ) {
        my $hash = join(
            "|",
            (
                $particles->[$i]{px}, $particles->[$i]{py}, $particles->[$i]{pz}
            )
        );
        if ( !exists $colliders{$hash} ) {
            $colliders{$hash} = [];
        }
        push( @{ $colliders{$hash} }, $i );
    }

    # Destroy
    for my $key ( keys %colliders ) {
        if ( scalar @{ $colliders{$key} } > 1 ) {

            for my $particle_to_destroy ( @{ $colliders{$key} } ) {
                push( @particles_to_destroy, $particle_to_destroy );
            }
        }
    }

    for my $particle_to_destroy ( reverse sort { $a <=> $b }
        @particles_to_destroy )
    {
        splice @{$particles}, $particle_to_destroy, 1;
    }

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

    destroy_colliders( \@particles );
    increment( \@particles );
}

my $alive_particles = scalar @particles;
print "alive -> $alive_particles\n";
exit 0;
