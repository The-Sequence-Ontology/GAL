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

$tool->verbosity('debug');

################################################################################
# Testing that fasta_tool compiles and returns usage statement
################################################################################

ok(! $tool->run(cl_args => '--help'), 'fasta_tool complies');
like($tool->get_stdout, qr/Synopsis/, 'fasta_tool prints usage statement');

################################################################################
# Testing fasta_tool --split data/multi_fasta.fa
################################################################################

my @cl_args = ('--split',
	       "$FindBin::Bin/data/multi_fasta.fa",
	      );

ok(! $tool->run(cl_args => \@cl_args), 'fasta_tool --split');

my %valid_md5 = ('multi_fasta_01.fasta' => 'e6a0135c236c6f7e6ad57c97a58cc594',
		 'multi_fasta_02.fasta' => '60c0ec8808a51774004a30222bd5cf3e',
		 'multi_fasta_03.fasta' => '697801c649d4471d31c5250371bbd8ea'
		);

for my $file (keys %valid_md5) {
  my $md5_sum = `md5sum $file`;
  chomp $md5_sum;
  $md5_sum =~ s/(\S+).*/$1/;
  ok($valid_md5{$file} eq $md5_sum, "fasta_tool --split produces valid output for $file");
  $tool->clean_up($file);
}

$tool->clean_up();

################################################################################
# Testing fasta_tool --eval_code data/test.fa
################################################################################

@cl_args = ('--eval_code "\$seq =~ /[a-z]+/"',
	    "$FindBin::Bin/data/multi_fasta.fa",
	   );

ok(! $tool->run(cl_args => \@cl_args), 'fasta_tool --eval_code');

ok($tool->get_stdout =~ />multi_fasta_0[12]/,
   "fasta_tool --eval_code keeps correct sequences");

ok($tool->get_stdout !~ />multi_fasta_03]/,
   "fasta_tool --eval_code discards correct sequences");

$tool->clean_up();

################################################################################
# Testing fasta_tool --arg data/test.fa
################################################################################
#
# my @cl_args = ('--arg',
#	       "$FindBin::Bin/data/file.fa",
#	      );
#
# ok(! $tool->run(cl_args => \@cl_args), 'fasta_tool --arg');
#
# ok($tool->get_stdout, "fasta_tool --arg produces valid output");
#
# $tool->clean_up();


# Test these options:
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
# uniq
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
