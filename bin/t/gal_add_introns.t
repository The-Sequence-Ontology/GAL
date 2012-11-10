#!/usr/bin/perl

use strict;
use warnings;

use GAL::Run;
use Test::More;
use FindBin;

chdir $FindBin::Bin;
my $path = "$FindBin::Bin/../examples";
my $command;
my ($sto_text, $ste_text);

my $tool = GAL::Run->new(path => $path,
			 command => 'gal_add_introns');

################################################################################
# Testing that gal_add_introns compiles and returns usage statement
################################################################################

ok(! $tool->run(cl_args => '--help'), 'gal_add_introns complies');
like($tool->get_stdout, qr/Synopsis/, 'gal_add_introns prints usage statement');

################################################################################
# Testing that gal_add_introns does something else
################################################################################

my @cl_args = ('data/dmel-4-r5.46.genes.partial.gff',
	      );

ok(! $tool->run(cl_args => \@cl_args), 'gal_add_introns runs');
ok($tool->get_stdout =~ /ID=FBtr0333704:intron:003;Parent=FBtr0333704/,
   'gal_add_introns has the correct output');

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
