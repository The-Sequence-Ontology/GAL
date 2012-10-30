#!/usr/bin/perl

use FindBin;
use TAP::Harness;

my %args = (verbosity => -1,
	    lib       => ["$FindBin::Bin/../lib"],
	    timer     => 1,
	    show_count => 1,
	    merge        => 1,
	    );

my $harness = TAP::Harness->new( \%args );

my @tests = (
    '../lib/t/vaast_fasta.t',
    '../bin/t/vaast_sort_cdr.t',
    '../bin/t/vaast_reporter.t',
    '../lib/t/vaast_gff3.t',
    '../bin/t/vaast_pipe.t',
    '../bin/t/vaast_indexer.t',
    '../bin/t/vaast_converter.t',
    '../bin/t/vaast_imager.t',
    '../bin/t/vaast_sort_gff.t',
    '../lib/t/vaast_cdr.t',
    '../lib/t/vaast_out.t',
    '../lib/t/vaast_run.t',
    '../bin/t/script_test_template.t',
    '../bin/t/vat.t',
    '../bin/t/miller_test_short.t',
    '../bin/t/tutorial_tests.t',
    '../bin/t/omim_tests_01.t',
    '../bin/t/omim_tests_02.t',
    '../bin/t/omim_tests_03.t',
    '../bin/t/trio_tests_cystic_fibrosis.t',
    '../bin/t/trio_tests_sickle_cell.t',
    '../bin/t/trio_tests_tay_sachs.t',
    '../bin/t/vat_big.t',
    '../bin/t/vaast_gvf_viewer.t',
    );

$harness->runtests(@tests);
