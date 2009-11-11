#!/usr/bin/perl
use strict;
use warnings;

use GAL::Annotation;

my $annotation = GAL::Annotation->new(dsn => 'DBI:mysql:gal_annotation_test');

#$annotation->schema->storage->debug(1);

$annotation->load_file(class => 'soap_snp',
		       file  => './data/soap_snp.gff',
		      );

my $feature_rs = $annotation->schema->resultset('Feature');

while (my $feature = $feature_rs->next) {
        my $id         = $feature->id;
        my $ref_allele = $feature->attributes->find({tag => 'reference_allele'})->value;
        print "$id\t$ref_allele\n";
}

