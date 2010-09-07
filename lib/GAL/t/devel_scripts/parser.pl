#!/usr/bin/perl
use strict;
use warnings;

my ($file, $parser) = @ARGV;

$file ||= '../data/soap_snp.gff';
$parser ||= 'chinese_snp';
my $class = 'GAL::Parser::' . $parser;
eval "require $class";

$parser = $class->new(file  => $file);

while (my $feature = $parser->next_feature_hash) {
  my $id = $feature->{feature_id};
  my $type = $feature->{type};
  print "$id\t$type\n";
}
