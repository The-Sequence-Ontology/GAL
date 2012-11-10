#!/usr/bin/perl

use strict;
use warnings;

use GAL::Run;
use Test::More;
use FindBin;

chdir $FindBin::Bin;
my $path = "$FindBin::Bin/../examples";

my $tool = GAL::Run->new(path => $path,
			 command => 'gal_protein_genes');

################################################################################
# Testing that gal_protein_genes compiles and returns usage statement
################################################################################

ok(! $tool->run(cl_args => '--help'), 'gal_protein_genes complies');
like($tool->get_stdout, qr/Synopsis/, 'gal_protein_genes prints usage statement');

################################################################################
# Testing that gal_protein_genes does something else
################################################################################

my @cl_args = ('data/dmel-4-r5.46.genes.partial.gff',
	       'data/dmel-4-chromosome-r5.46.fasta',
	      );

ok(! $tool->run(cl_args => \@cl_args), 'gal_protein_genes runs');
ok($tool->get_stdout =~ /ID=three_prime_UTR_FBgn0017545:1_1580;Name=RpS3A\-u3;Parent=FBtr0308296;/,
   'gal_protein_genes has the correct output');

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
