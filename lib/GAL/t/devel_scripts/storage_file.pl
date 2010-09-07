#!/usr/bin/perl
use strict;
use warnings;

use GAL::Storage::File;


my ($file, $parser) = @ARGV;

$file ||= '../data/soap_snp.gff';
$parser ||= 'chinese_snp';

my $storage = GAL::Storage::File->new(file  => $file,
				      parser => $parser);

while (my $feature = $storage->next_feature) {
  my $id = $feature->feature_id;
  my $type = $feature->type;
  print "$id\t$type\n";
}
