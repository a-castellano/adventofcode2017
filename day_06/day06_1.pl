#!/usr/bin/perl
# Álvaro Castellano Vela - 07/12/2017

use strict;
use warnings;

sub get_max
{
  my @array = @{$_[0]};
  my $max = -1;
  my $index = -1;
  foreach (my $i = 0; $i <= $#array; $i++)
  {
    if($array[$i] > $max){
      $max = $array[$i];
      $index = $i;
    }
  }

  return $max, $index;
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


my @banks;

# Read the input
my $banks_input = <$fh>;
if (! defined($banks_input))
{
  die "Could not process file '$filename' $!";
}

chomp $banks_input;
foreach my $bank(split /\s+/, $banks_input)
{
  push(@banks, $bank);
}

close( $fh );

my $number_of_banks = scalar @banks;
my $redistributions = 0;

my %seen;

do
{

  $seen{join("|", @banks)} = 1;

  my ($max, $index) = get_max( \@banks );
  die "Fatal error there banks with negative values, check your code\n $!" if ($max < 0);

  $banks[$index] = 0;
  #Spread blocks
  for (my $i = $max ; $i !=  0 ; $i--)
  {
    $index = ($index + 1) % $number_of_banks;
    $banks[$index]++;
  }

  $redistributions++;

}while(! $seen{join("|", @banks)});

print "Number of redistributions = $redistributions\n";
exit 0;

#my $number_of_steps = 0;
#my $current_position = 0;
#my $offsets_exit_position = scalar @offsets ;
#
#while ($current_position < $offsets_exit_position)
#{
#  my $jump_offset = $offsets[$current_position];
#  $offsets[$current_position]++;
#  $current_position += $jump_offset;
#
#  $number_of_steps++;
#}
#
#print "Program exited in $number_of_steps steps\n";
#
#exit 0;
