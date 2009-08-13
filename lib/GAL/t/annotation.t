#!/usr/bin/perl
use strict;

use Test::More 'no_plan'; # tests => 10;

BEGIN {
	use lib '../../';
	#TEST 1
	use_ok('GAL::Annotation');
}

my $path = $0;
$path =~ s/[^\/]+$//;
$path ||= '.';
chdir($path);

my $obj = GAL::Annotation->new();
#TEST 2
ok($obj->parse_file, '$obj->parse_file');

#TEST 3
ok($obj->add_feature, '$obj->add_feature');

#TEST 4
ok($obj->get_all_features, '$obj->get_all_features');

#TEST 5
ok($obj->get_features_by_type, '$obj->get_features_by_type');

#TEST 6
ok($obj->get_recursive_features_by_type, '$obj->get_recursive_features_by_type');

#TEST 7
ok($obj->get_feature_by_id, '$obj->get_feature_by_id');

#TEST 8
ok($obj->filter_features, '$obj->filter_features');


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
