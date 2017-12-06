#!/usr/bin/perl
# Álvaro Castellano Vela - 04/12/2017

use strict;
use warnings;
#use Math::Complex;
#use POSIX qw/ceil/;

sub get_max_number_from_dimensiom
{
  return ( ( ( 2 * $_[0] ) + 1   ) ** 2 );
}

sub get_next_value
{
  my @array = @{$_[0]};
  my @edges = @{$_[1]};
  my $current_position = $_[2];
  my $numbers_in_current_dimension = $_[3];
  my $numbers_in_previous_dimension = $_[4];
  my $edge_lenght = $_[5];

  my $next_position = $current_position + 1;
  my $next_value = 0;

  my @added_positions;
  push( @added_positions, $current_position );

  print "Next position -> $next_position\n";
  #  print "Edges -> @edges\n";
  #calculate adjacent positions
  if ( $next_position == $edges[-1] )
  {
    my $candidate_position = $next_position - $numbers_in_current_dimension + 1;
    print "$next_position is last edge\n";
    push( @added_positions, $candidate_position) unless ($candidate_position ~~ @added_positions );
  }
  else{#Not an edge
    if( $current_position ~~ @edges)
    {
      print "$next_position is last edge\n";
      my $previous_position = $current_position - 1;
      push( @added_positions, $previous_position ) unless ( $previous_position ~~ @added_positions );
    }
  }
  #if current(previous) position is an edge
  for(my $i = 0; $i < $next_position % $edge_lenght || $i < 3 ; $i++ )
  {
    #print "i -> si\n";
    #my $pos = $numbers_in_previous_dimension + $i * ($edge_lenght+1);
    my $pos = $next_position - $numbers_in_current_dimension - $i ;
    $pos = 1 if ($pos < 1);
    #print "pos -> $pos\n";
    push( @added_positions, $pos  ) unless ( $pos ~~ @added_positions );
  }
  print "Positions to add -> @added_positions\n";
  for my $pos (@added_positions)
  {
    $next_value += $array[$pos];
  }
  #print "Next Value ->  $next_value\n\n";
  return $next_value;
}


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


my $number_to_find = $ARGV[0];

print "Number to find -> $number_to_find\n";

my @array = (0, 1);
my $current_value = 1;
my $current_position = 1;
my $relative_position = 1; # We are not going to store the entire array in memory for gGod's sake

#my $numbers_in_previous_dimension = get_max_number_from_dimensiom( $dimension -1 );
my $current_dimension = 0;
my $numbers_in_previous_dimension = 0;
my $numbers_in_current_dimension = 1;
my $max_number_in_previous_dimension = 1;
my $max_position_in_current_dimension = 1;
my $max_position_in_previous_dimension = 0;

my @edges = (1, 1, 1, 1);
my $edge_lenght = 2 * ($current_dimension - 1 );

$array[$relative_position] = $current_value;

while ( $current_value <= $number_to_find)
{
  push( @array, get_next_value( \@array,
                                \@edges,
                                $current_position,
                                $numbers_in_current_dimension,
                                $numbers_in_previous_dimension,
                                $edge_lenght
                              )
      );
  $current_position++;
  $relative_position++;

  if ($current_position >= $max_position_in_current_dimension)
  {
    $current_dimension++;
    $numbers_in_previous_dimension = $numbers_in_current_dimension;
    $numbers_in_current_dimension = 8 * $current_dimension;
    $max_position_in_previous_dimension = $max_position_in_current_dimension;
    $max_position_in_current_dimension = get_max_number_from_dimensiom( $current_dimension );

    #print "Current Dimension -> $current_dimension\n";
    #print "Max position in dimension $current_dimension -> $max_position_in_current_dimension\n";
    #print "Numbers in dimension $current_dimension -> $numbers_in_current_dimension\n";
    #print "Numbers in previous dimension -> $numbers_in_previous_dimension\n";

    splice( @edges );
    $edge_lenght = (2 * ($current_dimension ));
    #print "edge_lenght -> $edge_lenght\n";
    for( my $i = 0; $i < 4 ; $i++)
    {
      push @edges, ($max_position_in_current_dimension - $edge_lenght * $i);
    }
    @edges = reverse @edges;

  }
  #print "Array -> @array\n";
  last if ($current_position > 16);
}

#print "End Array -> @array\n";

