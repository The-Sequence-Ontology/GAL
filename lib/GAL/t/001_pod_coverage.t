#!/usr/bin/perl

use strict;
use warnings;

#use Test::More;

use Test::Pod::Coverage tests=>31;

# Select an empty line and use C-u M-| to update the list of tests;
# find ../../ -name '*.pm' | sort | perl -ane 'chomp;s/^[\.|\/]*//;s/\.pm$//;s/\//::/g;print "pod_coverage_ok(\"$_\", \"$_ POD is covered.\");\n"' | wc

# Use M-! to count the number of tests
#find ../../ -name '*.pm' | sort | perl -ane 'chomp;s/^[\.|\/]*//;s/\.pm$//;s/\//::/g;print "pod_coverage_ok(\"$_\", \"$_ POD is covered.\");\n"' | wc

pod_coverage_ok("GAL::Annotation", "GAL::Annotation POD is covered.");
pod_coverage_ok("GAL::Base", "GAL::Base POD is covered.");
pod_coverage_ok("GAL::DB", "GAL::DB POD is covered.");
pod_coverage_ok("GAL::FeatureFactory", "GAL::FeatureFactory POD is covered.");
pod_coverage_ok("GAL::Feature", "GAL::Feature POD is covered.");
pod_coverage_ok("GAL::Feature::sequence_alteration", "GAL::Feature::sequence_alteration POD is covered.");
pod_coverage_ok("GAL::Parser::basic_snp", "GAL::Parser::basic_snp POD is covered.");
pod_coverage_ok("GAL::Parser::baylor", "GAL::Parser::baylor POD is covered.");
pod_coverage_ok("GAL::Parser::celera_indel", "GAL::Parser::celera_indel POD is covered.");
pod_coverage_ok("GAL::Parser::celera", "GAL::Parser::celera POD is covered.");
pod_coverage_ok("GAL::Parser::clcbio", "GAL::Parser::clcbio POD is covered.");
pod_coverage_ok("GAL::Parser::complete_genomics", "GAL::Parser::complete_genomics POD is covered.");
pod_coverage_ok("GAL::Parser::cosmic", "GAL::Parser::cosmic POD is covered.");
pod_coverage_ok("GAL::Parser::generic", "GAL::Parser::generic POD is covered.");
pod_coverage_ok("GAL::Parser::gigabayes", "GAL::Parser::gigabayes POD is covered.");
pod_coverage_ok("GAL::Parser::illumina_indel", "GAL::Parser::illumina_indel POD is covered.");
pod_coverage_ok("GAL::Parser::illumina_sanger_indel", "GAL::Parser::illumina_sanger_indel POD is covered.");
pod_coverage_ok("GAL::Parser::illumina_sanger", "GAL::Parser::illumina_sanger POD is covered.");
pod_coverage_ok("GAL::Parser::illumina_snp", "GAL::Parser::illumina_snp POD is covered.");
pod_coverage_ok("GAL::Parser::maq", "GAL::Parser::maq POD is covered.");
pod_coverage_ok("GAL::Parser", "GAL::Parser POD is covered.");
pod_coverage_ok("GAL::Parser::quake", "GAL::Parser::quake POD is covered.");
pod_coverage_ok("GAL::Parser::soap_indel", "GAL::Parser::soap_indel POD is covered.");
pod_coverage_ok("GAL::Parser::soap_snp", "GAL::Parser::soap_snp POD is covered.");
pod_coverage_ok("GAL::Parser::solid", "GAL::Parser::solid POD is covered.");
pod_coverage_ok("GAL::Parser::template", "GAL::Parser::template POD is covered.");
pod_coverage_ok("GAL::Parser::template_sequence_alteration", "GAL::Parser::template_sequence_alteration POD is covered.");
pod_coverage_ok("GAL::Schema", "GAL::Schema POD is covered.");
pod_coverage_ok("GAL::Schema::Result::Attribute", "GAL::Schema::Result::Attribute POD is covered.");
pod_coverage_ok("GAL::Schema::Result::Feature", "GAL::Schema::Result::Feature POD is covered.");
pod_coverage_ok("GAL::Schema::Result::Feature::sequence_alteration", "GAL::Schema::Result::Feature::sequence_alteration POD is covered.");

