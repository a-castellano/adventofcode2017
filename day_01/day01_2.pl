#!/usr/bin/perl
# Álvaro Castellano Vela - 03/12/2017

use strict;
use warnings;

# Main

my $argssize;
my @args;

$argssize = scalar @ARGV;

if ( $argssize != 1 ){
  print STDERR "This script only accepts one arg.\n";
  exit -1;
}

if ( $ARGV[0] =~ /[[:alpha:]]/ ){
  print STDERR "Input must contain only numbers.\n";
  exit -1;
}


my @input = ( split( '', $ARGV[0] ) );
my $inputsize = scalar @input;

my $result = 0;

for ( my $i = 0; $i < $inputsize ; $i++)
{
  if ( $input[$i] == $input[ ($i + $inputsize/2) % $inputsize  ] )
  {
    $result += $input[$i];
  }
}

print "Result => $result\n";
exit 0;
