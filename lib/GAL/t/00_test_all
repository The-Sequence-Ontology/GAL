#!/usr/bin/perl
use strict;
use warnings;
use TAP::Harness;

#-----------------------------------------------------------------------------
#----------------------------------- MAIN ------------------------------------
#-----------------------------------------------------------------------------

my $usage = "

Synopsis:

00_test_all

Description:

This script will use TAP::Harness to run all the tests (*.t) in this directory
or whichever tests you pass (e.g. parser_*.t) and report the results.

";

my $harness = TAP::Harness->new({verbosity => 1});
my @tests = @ARGV ? @ARGV : <*.t>;
my %skip_test = ('00_test_template.t' => 1,
	     );
@tests = grep {! $skip_test{$_}} @tests;
$harness->runtests(@tests);
