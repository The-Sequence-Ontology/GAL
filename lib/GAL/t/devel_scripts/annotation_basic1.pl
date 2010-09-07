#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use GAL::Annotation;

#-----------------------------------------------------------------------------
#----------------------------------- MAIN ------------------------------------
#-----------------------------------------------------------------------------

my $usage = "

Synopsis:

annotation_basic1  dbi:SQLite:dbname=feature.sqlite

Description:

A script for benchmarking the speed of GAL annotation feature iteration.

";

my $dsn = shift;

$dsn = 'dbi:SQLite:database=' . $dsn;

my $storage_args = {class    => 'SQLite',
		    dsn	     => $dsn,
		   };

my $feature_store = GAL::Annotation->new(storage => $storage_args,
					);
my $rs = $feature_store->schema->resultset('Feature');

while (my $feature = $rs->next) {
  my $type = $feature->type;
  my $id = $feature->feature_id;
  print "$type\t$id\n";
}

#-----------------------------------------------------------------------------
#-------------------------------- SUBROUTINES --------------------------------
#-----------------------------------------------------------------------------
