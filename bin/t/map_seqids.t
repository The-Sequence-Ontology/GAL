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
			 command => 'map_seqids');

################################################################################
# Testing that map_seqids compiles and returns usage statement
################################################################################

ok(! $tool->run(cl_args => '--help'), 'map_seqids complies');
like($tool->get_stdout, qr/Synopsis/, 'map_seqids prints usage statement');

################################################################################
# Testing that map_seqids does something else
################################################################################

my $map_file = "$FindBin::Bin/data/map_seqids.txt";
my $gff_file = "$FindBin::Bin/data/map_seqids.gff";

my @cl_args = ($map_file,
	       $gff_file,
	      );

ok(! $tool->run(cl_args => \@cl_args), 'map_seqids does something');
ok($tool->get_stdout =~ /^chr22/,
   'map_seqids has the correct output');

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
