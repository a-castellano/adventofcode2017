#!/usr/bin/perl
# Álvaro Castellano Vela - 08/12/2017

use strict;
use warnings;
use Data::Dumper;


sub create_node
{
  my $program_name = $_[0];
  my $value = $_[1];
  my $has_children = $_[2];
  my $childs = $_[3] if ($has_children);

  my %program;

  $program_name =~ s/^\s+|\s+$//g;

  $program{'name'} = $program_name;
  $program{'value'} = int($value);
  $program{'has_children'} = $has_children;

  if ($has_children)
  {
    $childs =~ s/^\s+|\s+$//g;
    my @children =split /, /, $childs;
    $program{'children'} = [@children];
  }

  return %program;
}

sub get_parent
{
  my %programs = %{$_[0]};
  my $program_name = $_[1];

  foreach my $program (keys %programs)
  {
    if ($programs{$program}{'has_children'})
    {
      my @children = @{$programs{$program}{'children'}};
      for my $child (@children)
      {
        if ($program_name eq $child)
        {
          return $programs{$program}{'name'};
        }
      }
    }
  }
  return "";
}


# get_weight returns an array with 4 elements
# 0 -> Unbalanced (0,1)
# Name of the unbalanced node if first element == 1
# different weight
# current weight

sub get_weight
{
  my %programs = %{$_[0]};
  my $program_name = $_[1];

  my %node = %{$programs{$program_name}};

  if( ! $node{'has_children'} )
  {
    return ( 0, $node{'name'}, $node{'value'}, $node{'value'});
  }
  else
  {
    my $same = -1;
    my $different = -1;
    my $different_node_name = "";
    my $different_node_name_failover = "";

    my $number_of_childs = scalar @{$node{'children'}};

    foreach my $child (@{$node{'children'}})
    {
      my @weight = get_weight(\%programs, $child);

      if ( $weight[0] ) # Unbalanced
      {
        return @weight;
      }
      else # Node is balanced so far
      {
        if ( $same == -1)
        {
          $same = $weight[3];
          $different_node_name_failover = $child;
        }
        else
        {
          if ( $weight[3] != $same ) #Unbalanced found
          {
            if ( $different == -1 )
            {
              $different = $weight[3];
              $different_node_name = $child;
            }
            else # There is only one different in each recursion
            {
              ($same, $different) = ($different, $same);
              $different_node_name = $different_node_name_failover;
            }
          }
        }
      }
    }# foreach
    if ( $different != -1 ) # return unbalanced info
    {
      return (1, $different_node_name, $same, $different )
    }
    else #Still Balanced
    {
      my $current_weight = $same * $number_of_childs + $node{'value'};
      return (0, $node{'name'}, $current_weight, $current_weight)
    }
  }
}

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

my %programs;
# Read the input
while ( my $line = <$fh> )
{
  chomp $line;

  if( $line =~ m/->/ )
  # program has child(s)
  {
    my ($program_name, $value, $childs) = $line =~ /(.*)? \((\d+)\) -> (.+)$/;
    $programs{$program_name} = {create_node($program_name, $value, 1, $childs)};
  }
  else
  {
    my ($program_name, $value) = $line =~ /(.*)? \((\d+)\)/;
    $programs{$program_name} = {create_node($program_name, $value, 0)};
  }

}

close( $fh );


my $root_program;

foreach my $program ( keys %programs )
{
  my $parent = get_parent(\%programs, $programs{$program}{'name'});
  if (! $parent )
  {
    $root_program = $programs{$program}{'name'};
    last;
  }
}

#print "Root program is $root_program\n";

my @value = get_weight(\%programs, $root_program);

my $right_value;

if($value[0]){
  if ( $value[2] > $value[3] )
  {
    $right_value = $programs{$value[1]}{'value'} + ($value[2] - $value[3]);
  }
  else
  {
    $right_value = $programs{$value[1]}{'value'} - ($value[3] - $value[2]);
  }

  print "There is an unbalanced node in this tree.\n";
  print "Value of node $value[1] should be $right_value instead of $programs{$value[1]}{'value'}\n";
}

exit 0;
