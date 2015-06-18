#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use FindBin;
use lib "$FindBin::RealBin/../../lib";
use lib "$FindBin::RealBin/../../lib/cpan";
use GAL::Run;

chdir $FindBin::Bin;
my $path = "$FindBin::Bin/..";

my $tool = GAL::Run->new(path => $path,
			 command => 'merge_data');

################################################################################
# Testing that merge_data compiles and returns usage statement
################################################################################

ok(! $tool->run(cl_args => ['--help']), 'merge_data complies');
like($tool->get_stdout, qr/Synopsis/, 'merge_data prints usage statement');

################################################################################
# Testing that merge_data does something else
################################################################################

my $file1 = "$FindBin::Bin/data/file1.txt";
my $file2 = "$FindBin::Bin/data/file2.txt";

my @cl_args = ('--pcol1 0',
	       '--pcol2 1',
	       '--uniq',
	       $file1,
	       $file2,
	      );

ok(! $tool->run(cl_args => \@cl_args), 'merge_data does something');
my @lines = split /\n/, $tool->get_stdout;
my $lc = scalar @lines;
ok($lc == 8,
   'merge_data has the correct line count');

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
