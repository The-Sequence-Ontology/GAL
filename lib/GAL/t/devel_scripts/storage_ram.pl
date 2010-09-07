#!/usr/bin/perl
use strict;
use warnings;

use GAL::Storage::RAM;

my $storage = GAL::Storage::RAM->new();

my ($file, $parser) = @ARGV;

$file ||= '../data/soap_snp.gff';
$parser ||= 'chinese_snp';

$storage->load_files({files => $file,
		      parser => $parser,
		     });

while (my $feature = $storage->next_feature) {
  my $id = $feature->feature_id;
  my $type = $feature->type;
  print "$id\t$type\n";
  my $parents = $feature->parents;
  print "\tPARENTS:\n" if scalar @$parents;
  for my $parent (@{$parents}) {
    my $id = $parent->feature_id;
    my $type = $parent->type;
    print "\t$id\t$type\n";
  }
  my $children = $feature->children;
  print "\tCHILDREN:\n" if scalar @$children;
  for my $child (@{$children}) {
    my $id = $child->feature_id;
    my $type = $child->type;
    print "\t$id\t$type\n";
  }
}
