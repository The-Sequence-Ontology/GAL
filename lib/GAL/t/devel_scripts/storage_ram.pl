#!/usr/bin/perl
use strict;
use warnings;

use GAL::Storage::RAM;

my $storage = GAL::Storage::RAM->new();

$storage->load_files({files => '../data/soap_snp.gff',
		      parser => 'chinese_snp',
		     });

while (my $feature = $storage->next_feature) {
  my $id = $feature->id;
  print "$id\n";
}
