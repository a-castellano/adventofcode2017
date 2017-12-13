#!/usr/bin/perl
# Álvaro Castellano Vela - 03/12/2017

use strict;
use warnings;

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

my $sum_result = 0;

while ( my $row = <$fh> ) {

    chomp $row;
    my @numbers = split /\s+/, $row;
    my @sorted_numbers = reverse sort { $a <=> $b } @numbers;
    my $numbers_size = scalar @sorted_numbers;

    my $found = 0;
    our $current_position = 0;

    foreach my $number (@sorted_numbers) {
        my @subrange =
          @sorted_numbers[ $current_position + 1 .. ( $numbers_size - 1 ) ];
        my $subrange_size = @subrange;

        if ( $subrange_size > 0 ) {
            foreach my $divider (@subrange) {
                if ( $number % $divider == 0 ) {
                    $found = 1;
                    $sum_result += $number / $divider;
                    last;
                }
            }
        }
        $current_position++;
        last if ($found);
    }
}

close($fh);

print "Result => $sum_result\n";

exit 0;
