#!/usr/bin/perl
# Álvaro Castellano Vela - 04/12/2017

use strict;
use warnings;

sub get_max_number_from_dimensiom
{
  return ( ( ( 2 * $_[0] ) + 1   ) ** 2 );
}

sub get_index
{
  my @array = @{$_[0]};
  my $value = $_[1];

  my $index = -1;

  for (my $i = 0; $i <=  $#array && $index < 0; $i++)
  {
    if ($array[$i] == $value)
      {
        $index = $i;
      }
  }

  return $index;
}

sub get_next_edge_index
{
  my @array = @{$_[0]};
  my $value = $_[1];

  my $index;

  for (my $i = 0; $i <=  $#array; $i++)
  {
      $index = $i;
      last if($array[$i] > $value)
  }

  return $index;
}



sub get_next_value
{
  my @array = @{$_[0]};
  my @current_edges = @{$_[1]};
  my @previous_edges = @{$_[2]};
  my $current_position = $_[3];
  my $numbers_in_previous_dimension = $_[4];

  my $next_position = $current_position + 1;
  my $next_value = 0;

  my @added_positions;
  push( @added_positions, $current_position ) unless($current_position < 1);

  # Calculate adjacent positions
  #
  # If index is and edge
  my $edge_index = get_index( \@current_edges, $next_position );
  if ( $edge_index >= 0 )
  {
    my $candidate_position = $previous_edges[$edge_index];
    push( @added_positions, $candidate_position); #unless ( $candidate_position ~~ @added_positions );

    if ( $next_position == $current_edges[-1] )
    {
      my $candidate_position = $previous_edges[$edge_index] + 1 ;
      push( @added_positions, $candidate_position); #unless ( $candidate_position ~~ @added_positions );
    }
  }
  else
  {
    my $edge_index = get_index( \@current_edges, $next_position - 1  );
    # position is just next edge, add 2 previous dimiension positions and position behind edge
    if ( $edge_index >= 0  )
      {
        my $candidate_position = $current_position - 1;
        push( @added_positions, $candidate_position); #unless ( $candidate_position ~~ @added_positions );

        my $previous_edge_index = get_next_edge_index(\@current_edges, $next_position - 2 );
        $candidate_position = $next_position - $numbers_in_previous_dimension - 2 *  ( $previous_edge_index + 1 );
        push( @added_positions, $candidate_position); #unless ( $candidate_position ~~ @added_positions );
        $candidate_position--;
        $candidate_position = 2 if($next_position == 8);# Hate this sh**
        push( @added_positions, $candidate_position); #unless ( $candidate_position ~~ @added_positions );
      }
    else
    {

      my $edge_index = get_index( \@current_edges, $next_position + 1 );
      # position is just behind edge, add 2 positions
      if ( $edge_index >= 0 )
      {
        my $next_edge_index = get_next_edge_index(\@current_edges, $next_position);
        my $candidate_position = $next_position - $numbers_in_previous_dimension - 1 - 2 *  $next_edge_index;
        $candidate_position = 1 if($candidate_position < 1);
        push( @added_positions, $candidate_position); #unless ( $candidate_position ~~ @added_positions );
        $candidate_position--;
        $candidate_position = 1 if($candidate_position < 1);
        push( @added_positions, $candidate_position); #unless ( $candidate_position ~~ @added_positions );
        if ($next_edge_index == 3) #This position is viewing last spiral start
        {
          $candidate_position += 2;
          push( @added_positions, $candidate_position ); #unless ( $candidate_position ~~ @added_positions );
        }
      }

      else{
        if ( $edge_index == -1 && get_index( \@previous_edges, $current_position ) == 3)
        #first position of dimension
        {
          my $candidate_position = $next_position - $numbers_in_previous_dimension;
          push( @added_positions, $candidate_position ); #unless ( $candidate_position ~~ @added_positions );
        }
        else
        {
          if ( $edge_index == -1 && get_index( \@previous_edges, $current_position -1 ) == 3)
          #second position of dimension, it has 3 adyacent positions
          {
            my $candidate_position = $next_position - $numbers_in_previous_dimension;
            push( @added_positions, $candidate_position ); #unless ( $candidate_position ~~ @added_positions );
            $candidate_position--;
            $candidate_position = 1 if($candidate_position < 1);
            push( @added_positions, $candidate_position ); #unless ( $candidate_position ~~ @added_positions );
            $candidate_position = $current_position -1;
            $candidate_position = 1 if($candidate_position < 1);
            push( @added_positions, $candidate_position ); #unless ( $candidate_position ~~ @added_positions );
          }
          else
           #position is no special and has 3 adyacent positions in preivous position spiral
           {
             my $next_edge_index = get_next_edge_index(\@current_edges, $next_position);
             my $candidate_position = $next_position - $numbers_in_previous_dimension  - 2 *  $next_edge_index;
             push( @added_positions, $candidate_position); #unless ( $candidate_position ~~ @added_positions );
             $candidate_position--;
             push( @added_positions, $candidate_position); #unless ( $candidate_position ~~ @added_positions );
             $candidate_position--;
             push( @added_positions, $candidate_position); #unless ( $candidate_position ~~ @added_positions );
           }
        }
      }
    }
  }
  #print "Next position $next_position: @added_positions\n";
  if($next_position == 2) #Hate this too
  {
    pop @added_positions;
  }
  for my $pos (@added_positions)
  {
    $next_value += $array[$pos];
  }
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

my $number_to_find = int($ARGV[0]);
my @array = (0, 1);
my $current_value = 1;
my $current_position = 1;

my $current_dimension = 0;
my $numbers_in_previous_dimension = 0;
my $numbers_in_current_dimension = 1;
my $max_number_in_previous_dimension = 1;
my $max_position_in_current_dimension = 1;
my $max_position_in_previous_dimension = 0;

my @previous_edges = (0, 0, 0, 0);
my @current_edges = (1, 1, 1, 1);
my $edge_lenght = 2 * ($current_dimension - 1 );

$array[$current_position] = $current_value;

my $value = 0;

while ( $current_value <= $number_to_find)
{
  $value = get_next_value( \@array,
                                \@current_edges,
                                \@previous_edges,
                                $current_position,
                                $numbers_in_previous_dimension,
                              );
  push( @array, $value);
  $current_position++;

  if ($current_position >= $max_position_in_current_dimension)
  {
    $current_dimension++;
    $numbers_in_previous_dimension = $numbers_in_current_dimension;
    $numbers_in_current_dimension = 8 * $current_dimension;
    $max_position_in_previous_dimension = $max_position_in_current_dimension;
    $max_position_in_current_dimension = get_max_number_from_dimensiom( $current_dimension );

    @previous_edges = @current_edges;
    splice( @current_edges );
    $edge_lenght = (2 * ($current_dimension ));
    for( my $i = 0; $i < 4 ; $i++)
    {
      push @current_edges, ($max_position_in_current_dimension - $edge_lenght * $i);
    }
    @current_edges = reverse @current_edges;

  }
  last if ($value > $number_to_find);
  #last if ($current_position == $number_to_find);
}

print "First value lager than $number_to_find is $value\n";
#print "Value in $current_position is $value\n";

