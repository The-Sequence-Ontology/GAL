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
			 command => 'gff_tool');

################################################################################
# Testing that add_reference_seq compiles and returns usage statement
################################################################################

ok(! $tool->run(cl_args => '--help'), 'add_reference_seq complies');
like($tool->get_stdout, qr/Synopsis/, 'add_reference_seq prints usage statement');

################################################################################
# Testing that add_reference_seq does something else
################################################################################

#my $gvf_file = "$FindBin::Bin/data/Dmel_genes_4.gff";
#
#my @cl_args = ('--arg1',
#	       '--arg2 value',
#	       $gvf_file,
#	      );
#
#ok($tool->run(cl_args => \@cl_args), 'add_reference_seq does something');
#ok($tool->get_stdout =~ /match something/,
#   'add_reference_seq has the correct output');
#$tool->clean_up;

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
