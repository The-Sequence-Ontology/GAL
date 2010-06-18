#!/usr/bin/perl
use strict;
use warnings;
use TAP::Harness;

#-----------------------------------------------------------------------------
#----------------------------------- MAIN ------------------------------------
#-----------------------------------------------------------------------------

my $usage = "

Synopsis:

00_test_all.t

Description:

This script will use TAP::Harness to run all the tests (*.t) in this directory
or whichever tests you pass (e.g. parser_*.t) and report the results.

";

my $harness = TAP::Harness->new({verbosity => 1});
# my @tests = @ARGV ? @ARGV : <*.t>;
my @tests = qw(001_annotation.t
	       001_base.t
	       200_parser.t
               200_parser_gff3.t
	       300_reader.t
               300_reader_delimitedline.t
	       400_storage.t
               400_storage_sqlite.t
	       500_schema.t
	       600_list.t
	     );

# 500_schema_result_attribute.t
# 500_schema_result_feature.t
# 500_schema_result_feature_transcript.t
# 600_list_categorical.t
# 600_list_numeric.t
# 600_list_span.t


my %skip_test = ($0		                     => 1,
		 '001_test_template.t'		     => 1,
		 '100_feature.t'		     => 1,
		 '100_feature_sequence_alteration.t' => 1,
		 '100_feature_sequence_feature.t'    => 1,
	     );
@tests = grep {! $skip_test{$_}} @tests;
$harness->runtests(@tests);


