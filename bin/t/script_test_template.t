#!/usr/bin/perl

use strict;
use warnings;

use GAL::Run;
use Test::More tests => 6;
use FindBin;

chdir $FindBin::Bin;
my $path = "$FindBin::Bin/../";
my $command;
my ($sto_text, $ste_text);

my $tool = GAL::Run->new(path => $path,
			 command => 'gff_tool');

################################################################################
# Testing that gff_tool compiles and returns usage statement
################################################################################

ok(! $vat->run(cl_args => '--help'), 'gff_tool complies');
like($vat->get_stdout, qr/Synopsis/, 'gff_tool prints usage statement');

################################################################################
# Testing that gff_tool filters
################################################################################

# Test these
#  in_place
#  out_ext
#  fasta
#  so_file
#  ids
#  seqids
#  include
#  exclude
#  code
#  filter
#  overlaps
#  genes
#  merge
#  blend
#  sort
#  alter
#  hash_ag
#  validate
#  stats
#  print
#  sequence
#  features
#  fasta_only
#  fasta_no
#  fasta_add
#  meta_only
#  meta_no
#  meta_add
#  pragmas
#  add_ID
#  union
#  intersection
#  l_compliment
#  s_difference
#  titv
#  gvf_stats
#  effect_stats
#  gvf_sets
#  fix_gvf

my $gff_file = "$FindBin::Bin/data/Dmel_genes_4.gff";

my @cl_args = ('--filter',
	       "--code '\$f->{type} eq \"gene\"",
	       $gff_file
	      );

ok($tool->run(cl_args => \@cl_args), 'gff_tool filters for type gene');
ok($vat->get_stdout =~ /match something/,
   'gff_tool has the correct output');
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
