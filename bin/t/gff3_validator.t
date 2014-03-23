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
			 command => 'gff3_validator');

################################################################################
# Testing that gff3_validator compiles and returns usage statement
################################################################################

ok(! $tool->run(cl_args => '--help'), 'gff3_validator complies');
like($tool->get_stdout, qr/Synopsis/, 'gff3_validator prints usage statement');

################################################################################
# Testing that gff3_validator does something else
################################################################################

my @cl_args = ('data/dmel-4-r5.46.gff',
	        );

ok(! $tool->run(cl_args => \@cl_args), 'gff3_validator does something');
ok($tool->get_stdout =~ /invalid_end_not_contained_within_sequence_region/,
   'gff3_validator has the correct output');
ok($tool->get_stderr =~ /invalid_end_not_contained_within_sequence_region/,
   'gff3_validator has the correct error output');

$tool->clean_up;

################################################################################
# Testing that gff3_validator validates Target attribute
################################################################################

@cl_args = ('data/NM_001033828.1.gff3',
	        );

ok(! $tool->run(cl_args => \@cl_args), 'gff3_validator does something');
ok($tool->get_stdout =~ /invalid_Target_attribute_start_greater_than_end\s+13[^\d]/,
   'invalid_Target_attribute_start_greater_than_end errors caught');
ok($tool->get_stderr =~ /invalid_Target_attribute_start_greater_than_end/,
   'invalid_Target_attribute_start_greater_than_end errors caught');

$tool->clean_up;

################################################################################
# Testing that gff3_validator validates Target Gap and feature lengths
# are in sync for matches that have both Target and Gap attributes
################################################################################

@cl_args = ('data/NR_036541.1.gff3',
	        );

ok(! $tool->run(cl_args => \@cl_args), 'gff3_validator does something');

ok($tool->get_stdout =~ /Target_and_Gap_attribute_lengths_dont_match\s+2[^\d]/,
   'Target_and_Gap_attribute_lengths_dont_match errors caught');
ok($tool->get_stdout =~ /Gap_attribute_length_does_not_match_feature_length\s+2[^\d]/,
   'Gap_attribute_length_does_not_match_feature_length errors caught');

ok($tool->get_stderr =~ /Target_and_Gap_attribute_lengths_dont_match/,
   'Target_and_Gap_attribute_lengths_dont_match errors caught');
ok($tool->get_stderr =~ /Gap_attribute_length_does_not_match_feature_length/,
   'Gap_attribute_length_does_not_match_feature_length errors caught');

$tool->clean_up;

################################################################################
# Testing that gff3_validator validates Target Gap and feature lengths
# are in sync for matches that have both Target and Gap attributes
################################################################################

@cl_args = ('data/NG_027806.1.gff3',
	        );

ok(! $tool->run(cl_args => \@cl_args), 'gff3_validator does something');

ok($tool->get_stdout =~ /Target_and_Gap_attribute_lengths_dont_match\s+1[^\d]/,
   'Target_and_Gap_attribute_lengths_dont_match errors caught');

ok($tool->get_stderr =~ /Target_and_Gap_attribute_lengths_dont_match/,
   'Target_and_Gap_attribute_lengths_dont_match errors caught');

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
