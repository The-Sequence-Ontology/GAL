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
			 command => 'gal_feature_overlaps');

$tool->verbosity('debug');

################################################################################
# Testing that gal_feature_overlaps compiles and returns usage statement
################################################################################

ok(! $tool->run(cl_args => '--help'), 'gal_feature_overlaps complies');
like($tool->get_stdout, qr/Synopsis/, 'gal_feature_overlaps prints usage statement');

################################################################################
# Testing that gal_feature_overlaps does something else
################################################################################

ok(! $tool->run(cl_args => ['data/interval_*.gff']), 'gal_feature_overlaps runs');
ok($tool->get_stdout =~ /chr12:3000510:3000658\t3\tdata\/interval_1.gff,data\/interval_2.gff,data\/interval_3.gff/,
   'gal_feature_overlaps has the correct output');

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
