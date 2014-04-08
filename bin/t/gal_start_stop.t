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
			 command => 'gal_start_stop');

################################################################################
# Testing that gal_start_stop compiles and returns usage statement
################################################################################

ok(! $tool->run(cl_args => '--help'), 'gal_start_stop complies');
like($tool->get_stdout, qr/Synopsis/, 'gal_start_stop prints usage statement');

################################################################################
# Testing that gal_start_stop does something else
################################################################################

my @cl_args = ('data/Homo_sapiens.GRCh37.73.chr22.short.gff3',
	       'data/hg19_chr22.fa',
	      );

ok(! $tool->run(cl_args => \@cl_args), 'gal_start_stop runs');
ok($tool->get_stdout =~ /ENST00000400585\tATG\tTAG/x, 'gal_start_stop has correct output');

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
