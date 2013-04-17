#!/usr/bin/perl

use strict;
use warnings;

use GAL::Run;
use Test::More;
use FindBin;

chdir $FindBin::Bin;
my $path = "$FindBin::Bin/../";
my $command;
my ($sto_text, $ste_text);

my $tool = GAL::Run->new(path => $path,
			 command => 'feature2gff');

################################################################################
# Testing that feature2gff compiles and returns usage statement
################################################################################

ok(! $tool->run(cl_args => '--help'), 'feature2gff complies');
like($tool->get_stdout, qr/Synopsis/, 'feature2gff prints usage statement');

################################################################################
# Testing that feature2gff does something else
################################################################################

#../feature2gff

my @cl_args = ('--parser venter_snp',
	       '--fasta data/fasta_hg18/chr22_hg18.fasta',
	       'data/celera_short.gff',
	      );

ok(! $tool->run(cl_args => \@cl_args), 'feature2gff runs');
ok($tool->get_stdout =~ /ID=1103675014765;Variant_seq=G;Reference_seq=;Zygosity=homozygous;/,
   'feature2gff has the correct output');

$tool->clean_up;

################################################################################
# Testing feature2gff --parser VCFv4_0
################################################################################

#../feature2gff

my @cl_args = ('--parser VCFv4_0',
	       'data/test.vcf',
	      );

ok(! $tool->run(cl_args => \@cl_args), 'feature2gff runs');
ok($tool->get_stdout =~ /ID=22:HG00096:16052513;Variant_seq=C,G;Reference_seq=G;/,
   'feature2gff has the correct output');

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
