#!/usr/bin/perl
# Álvaro Castellano Vela - 13/12/2017

use strict;
use warnings;

# Main

sub uniq {
    my %seen;
    grep !$seen{$_}++, @_;
}

sub get_sets {
    my %sets    = %{ $_[0] };
    my $program = $_[1];

    my @found;

    for my $key ( keys %sets ) {
        if ( exists $sets{$key}{$program} ) {
            push( @found, $key );
        }
    }
    return @found;
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

my %sets;
my $set_counter = 0;

# Read the input
while ( my $line = <$fh> ) {
    chomp $line;
    my ( $parent_program, $connected_string, ) =
      $line =~ /(\d+) <-> ([\d+,?\s?]+)$/;

    $connected_string = $connected_string =~ s/,//gr;
    my @connected_programs = split / /, $connected_string;

    push( @connected_programs, $parent_program );
    @connected_programs = sort { $a <=> $b } @connected_programs;

    my @sets_found;
    for my $program (@connected_programs) {
        my @found = get_sets( \%sets, $program );

        if ( scalar @found > 0 ) {
            push( @sets_found, @found );
        }
    }

    @sets_found = uniq(@sets_found);
    if ( scalar @sets_found == 0 )

      # Create new set
    {
        $sets{$set_counter} = {};
        for my $program (@connected_programs) {
            $sets{$set_counter}{$program} = 1;
        }
        $set_counter++;
    }
    else {
        if ( scalar @sets_found == 1 )    # All programs go to the same set
        {
            for my $program (@connected_programs) {
                $sets{ $sets_found[0] }{$program} = 1;
            }
        }
        elsif ( scalar @sets_found >= 1 )    # merge found sets into new set
        {
            $sets{$set_counter} = {};

            #print "MERGE! @sets_found\n";
            for my $set (@sets_found) {
                for my $program ( keys %{ $sets{$set} } ) {
                    $sets{$set_counter}{$program} = 1;
                }
                delete $sets{$set};
            }

            for my $program (@connected_programs) {
                $sets{$set_counter}{$program} = 1;
            }
            $set_counter++;
        }
    }

}

close($fh);

my $groups = keys %sets;
print "Groups -> $groups\n";

exit 0;
