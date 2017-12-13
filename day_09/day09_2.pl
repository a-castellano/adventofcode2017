#!/usr/bin/perl
# Álvaro Castellano Vela - 10/12/2017

use strict;
use warnings;

# Main

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

# Read the input
my $line = <$fh>;
chomp $line;
close($fh);

# Remove !'s'
$line = $line =~ s/!(.)//gr;

# Extract garabage
my @garabage = $line =~ m/<[^\>]*>/g;

my $garabage_characters = 0;

for my $garabage_slice (@garabage) {
    $garabage_characters += ( length $garabage_slice ) - 2;
}

print "Garabage characters -> $garabage_characters\n";

exit 0;
