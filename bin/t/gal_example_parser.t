#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use FindBin;
use lib "$FindBin::RealBin/../../lib";
use lib "$FindBin::RealBin/../../lib/cpan";
use GAL::Run;

chdir $FindBin::Bin;
my $path = "$FindBin::Bin/../examples";

my $tool = GAL::Run->new(path => $path,
			 command => 'gal_example_parser');

################################################################################
# Testing that gal_example_parser compiles and returns usage statement
################################################################################

ok(! $tool->run(cl_args => '--help'), 'gal_example_parser complies');
like($tool->get_stdout, qr/Synopsis/, 'gal_example_parser prints usage statement');

################################################################################
# Testing that gal_example_parser does something else
################################################################################

my @cl_args = ('data/dmel-4-r5.46.genes.gff'
	      );

 ok(! $tool->run(cl_args => \@cl_args), 'gal_example_parser runs');
 ok($tool->get_stdout =~ /4\s+three_prime_UTR\s+three_prime_UTR_FBgn0053653:29_1571/,
    'gal_example_parser has the correct output');

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
