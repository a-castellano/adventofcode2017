#!/usr/bin/perl
# Álvaro Castellano Vela - 09/12/2017

use strict;
use warnings;

sub get_score
{
  my @array_input = @{$_[0]};
  my $parent_group_score = $_[1];

  $parent_group_score++;#Inside one group

  my $pos = 1;
  my $last_position = scalar @array_input - 1;

  if ( $last_position == 1 ) # array_input -> {}
  {
    return $parent_group_score;
  }

  else
  {
    my @end_positions;

    while( $pos < $last_position - 1) # from 1 to $last_position - 1 -> do not count parent {}
    {
      my $open_brackets = 0;
      do
      {
        if( $array_input[$pos] eq "{" )
        {
          $open_brackets++;
        }
        elsif ( $array_input[$pos] eq "}" )
        {
          $open_brackets--;
        }

        $pos++;

      }while( $open_brackets != 0 );

      push(@end_positions, $pos - 1 );

    } #while( $pos < $last_position )

    my $score = 0;

    # first slice
    my @slice = @array_input[ 1 .. $end_positions[0] ];
    $score += get_score(\@slice, $parent_group_score);

    for ( my $i = 1; $i < scalar @end_positions; $i++)
    {
       my @slice = @array_input[ $end_positions[ $i - 1 ] + 1 .. $end_positions[ $i ] ];
       $score += get_score(\@slice, $parent_group_score);
    }
    return $parent_group_score + $score;
  } #else
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

# Remove !'s'
$line = $line =~ s/!(.)//gr;
# Remove garabage
$line = $line =~ s/<[^\>]*>//gr;
# Remove unused commas
$line = $line =~ s/,//gr;

my @array_input = split // , $line;
my $score = 0;
my $group_score =0;

$score = get_score(\@array_input, $group_score);

print "Score -> $score\n";

exit 0;
