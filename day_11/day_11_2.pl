#!/usr/bin/perl
# Álvaro Castellano Vela - 11/12/2017

use strict;
use warnings;

sub apply_move
{
  my @coordinates = @{$_[0]};
  my $move = $_[1];

  if ( $move eq "n" )
  {
    $coordinates[1]--;

  }
  elsif ( $move eq "ne"  )
  {
    $coordinates[0]++;
    if ($coordinates[0] % 2 == 1)
    {
      $coordinates[1]--;
    }
  }
  elsif ( $move eq "se"  )
  {
    $coordinates[0]++;
    if ($coordinates[0] % 2 == 0)
    {
      $coordinates[1]++;
    }
  }
  elsif ( $move eq "s"  )
  {
    $coordinates[1]++;
  }
  elsif ( $move eq "sw"  )
  {
    $coordinates[0]--;
    if ($coordinates[0] % 2 == 0)
    {
      $coordinates[1]++;
    }
  }
  elsif ( $move eq "nw"  )
  {
    $coordinates[0]--;
    if ($coordinates[0] % 2 == 1)
    {
      $coordinates[1]--;
    }
  }

  return @coordinates;
}

sub get_steps
{
  my @coordinates = @{$_[0]};
  my @coordinates_until_zero = @coordinates;

  my $steps = 0;

  my $move;

  if ( $coordinates_until_zero[0] > 0 && $coordinates_until_zero[1] > 0 )
  {
    $move = 'nw';
  }
  elsif ( $coordinates_until_zero[0] > 0 && $coordinates_until_zero[1] < 0 )
  {
    $move = 'sw';
  }
  elsif ( $coordinates_until_zero[0] < 0 && $coordinates_until_zero[1] < 0 )
  {
    $move = 'se';
  }
  elsif ( $coordinates_until_zero[0] < 0 && $coordinates_until_zero[1] > 0 )
  {
    $move = 'ne';
  }
  until ( $coordinates_until_zero[0] == 0 || $coordinates_until_zero[1] == 0 )
  {
    @coordinates_until_zero = apply_move(\@coordinates_until_zero, $move);
    $steps++;
  }

  $steps = $steps +  abs($coordinates_until_zero[0]) + abs($coordinates_until_zero[1]);

  return $steps;
}

# Main

my $argssize;
my @args;

$argssize = scalar @ARGV;

if ( $argssize != 1 ){
  print STDERR "This script only accepts one arg.\n";
  exit -1;
}

my $filename = $ARGV[0];

open(my $fh, '<:encoding(UTF-8)', $filename)
  or die "Could not open file '$filename' $!";

# Read the input
my $line = <$fh>;
chomp $line;
close( $fh );

my @array_input = split /,/ , $line;

my @coordinates = (0,0);

my $step;
my $furthest_step = 0;

for my $input (@array_input)
{
  @coordinates = apply_move(\@coordinates, $input);
  # This is no efficient
  $step = get_steps(\@coordinates);
  $furthest_step = $step if ( $step > $furthest_step);
}

print "Furthest -> $furthest_step\n";

exit 0;
