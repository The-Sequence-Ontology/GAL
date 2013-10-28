#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use FindBin;
use lib "$FindBin::RealBin/../../lib";
use lib "$FindBin::RealBin/../../lib/cpan";
use GAL::Run;

chdir $FindBin::Bin;
my $path = "$FindBin::Bin/../";
my $command;
my ($sto_text, $ste_text);

my $tool = GAL::Run->new(path => $path,
			 command => 'fasta_tool');

################################################################################
# Testing that fasta_tool compiles and returns usage statement
################################################################################

ok(! $tool->run(cl_args => '--help'), 'fasta_tool complies');
like($tool->get_stdout, qr/Synopsis/, 'fasta_tool prints usage statement');

################################################################################
# Testing that fasta_tool does something else
################################################################################

# Test these options:
# split_fasta
# eval_code
# eval_all
# extract_ids
# grep_header
# grepv_header
# mRNAseq
# EST
# grep_seq
# grepv_seq
# fix_prot
# translate
# trim_maker_utr
# seq_only
# nt_count
# seq_length
# total_length
# n50
# tab
# print_seq
# reverse_order
# rev_comp{
# uniq{
# uniq_sub
# shuffle_order
# shuffle_seq
# shuffle_codon
# shuffle_pick
# remove_ids
# select_ids
# print_this_seq
# wrap_seq
# get_header
# shuffle
# swap_ids
# subseq
# tile_seq

#my $gff_file = "$FindBin::Bin/data/Dmel_genes_4.gff";
#
#my @cl_args = ('--arg1',
#	       '--arg2 value',
#	       $gff_file,
#	      );
#
#ok($tool->run(cl_args => \@cl_args), 'fasta_tool does something');
#ok($tool->get_stdout =~ /match something/,
#   'fasta_tool has the correct output');

$tool->clean_up;
done_testing();

################################################################################
################################# Ways to Test #################################
################################################################################

__END__

# Various other ways to say "ok"
ok($this eq $that, $test_name);

is  ($this, $that,    $test_name);
isnt($this, $that,    $test_name);

# Rather than print STDERR "# here's what went wrong\n"
diag("here's what went wrong");

like  ($this, qr/that/, $test_name);
unlike($this, qr/that/, $test_name);

cmp_ok($this, '==', $that, $test_name);

is_deeply($complex_structure1, $complex_structure2, $test_name);

can_ok($module, @methods);
isa_ok($object, $class);

pass($test_name);
fail($test_name);

BAIL_OUT($why);
