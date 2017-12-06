#!/usr/bin/perl
# Álvaro Castellano Vela - 06/12/2017

use strict;
use warnings;

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


my $valid_passphrases = 0;

while (my $passphrase = <$fh>) {

  chomp $passphrase;
  my @words = split /\s+/, $passphrase;
  my @sorted_words =  sort @words;
  my %seen;

  my$is_valid = 1;

  foreach my $word (@sorted_words)
  {
    if($seen{$word}){
      $is_valid = 0;
    }
    else{
      $seen{$word} = 1;
    }
    last if(! $is_valid);
  }

  $valid_passphrases++ if ($is_valid);
}

close( $fh );

print "Valid passphrases -> $valid_passphrases\n";

exit 0;
