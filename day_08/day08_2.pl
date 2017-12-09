#!/usr/bin/perl
# Álvaro Castellano Vela - 09/12/2017

use strict;
use warnings;

sub evaluate_logical_expression
{
  my $variable_to_compare = $_[0];
  my $logic_operator = $_[1];
  my $value_to_compare = $_[2];

  if ( $logic_operator eq "==" )
  {
    return $variable_to_compare == $value_to_compare;
  }
  elsif ( $logic_operator eq "!=" )
  {
    return $variable_to_compare != $value_to_compare;
  }
  elsif ( $logic_operator eq "<=" )
  {
    return $variable_to_compare <= $value_to_compare;
  }
  elsif ( $logic_operator eq ">=" )
  {
    return $variable_to_compare >= $value_to_compare;
  }
  elsif ( $logic_operator eq  "<")
  {
    return $variable_to_compare < $value_to_compare;
  }
  elsif ( $logic_operator eq  ">")
  {
    return $variable_to_compare > $value_to_compare;
  }
  die("Fatal error analyzing logical expresion");
}

sub get_largest
{
  my %variables = %{$_[0]};
  my $largest;

  for my $variable ( keys %variables )
  {
    if ( ! defined $largest )
    {
      $largest = $variables{$variable};
    }
    elsif ( $variables{$variable} > $largest )
    {
      $largest = $variables{$variable};
    }
  }
  return $largest;
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

my %variables;
my $largest_value_registered = 0;

# Read the input
while ( my $line = <$fh> )
{
  chomp $line;

  my (
       $variable_to_modify,
       $operator,
       $addend,
       $variable_to_compare,
       $logic_operator,
       $value_to_compare
     ) = $line =~ /([a-z]+) (inc|dec) (\-?[0-9]+) if ([a-z]+) ([=<>!]+) (\-?[0-9]+)$/;

  $addend = int($addend);
  $value_to_compare = int($value_to_compare);
  # Check if variables already exists

  if(! defined $variables{$variable_to_modify}){
    $variables{$variable_to_modify} = 0;
  }

  if(! defined $variables{$variable_to_compare}){
    $variables{$variable_to_compare} = 0;
  }

  if ( evaluate_logical_expression($variables{$variable_to_compare}, $logic_operator, $value_to_compare) )
  {
    if ( $operator eq "inc" )
    {
      $variables{$variable_to_modify} += int($addend);
    }
    else
    {
      $variables{$variable_to_modify} -= int($addend);
    }
  }
  $largest_value_registered = $variables{$variable_to_modify} if ( $variables{$variable_to_modify} > $largest_value_registered );
}

close( $fh );

my $largest = get_largest(\%variables);

print "Largest value -> $largest\n";
print "Largest value registered -> $largest_value_registered\n";

exit 0;
