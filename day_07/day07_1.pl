#!/usr/bin/perl
# Álvaro Castellano Vela - 07/12/2017

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

#print Dumper(\%programs);

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

print "$root_program is at the botton\n";

exit 0;
