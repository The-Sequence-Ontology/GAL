#!/usr/bin/perl
use strict;

use Test::More tests => 3;

BEGIN {
	use lib '../../';
	#TEST 1
	use_ok('GAL::Storage');
}

my $path = $0;
$path =~ s/[^\/]+$//;
$path ||= '.';
chdir($path);

# TEST 2
my $object = GAL::Storage->new();
isa_ok($object, 'GAL::Storage');

# To get a list of all of the subs and throws:
# Select an empty line and then: C-u M-| grep -nP '^sub ' ../Storage.pm
# Select an empty line and then: C-u M-| grep -C2 -P '\>throw(' ../Storage.pm

# TEST 3
ok($storage->dsn(), '$storage->dsn()');

# TEST 4
ok($storage->user(), '$storage->user()');

# TEST 5
ok($storage->password(), '$storage->password()');

# TEST 6
ok($storage->db_name(), '$storage->db_name()');

# TEST 7
ok($storage->driver(), '$storage->driver()');

# TEST 8
ok($storage->load_file(), '$storage->load_file()');

# TEST 9
ok($storage->add_features_to_buffer(), '$storage->add_features_to_buffer()');

# TEST 10
ok($storage->flush_feature_buffer(), '$storage->flush_feature_buffer()');

# TEST 11
ok($storage->prepare_features(), '$storage->prepare_features()');

# TEST 12
ok($storage->_normalize_feature(), '$storage->_normalize_feature()');

# TEST 13
ok($storage->add_feature(), '$storage->add_feature()');

# TEST 14
ok($storage->create_database(), '$storage->create_database()');

# TEST 15
ok($storage->get_children(), '$storage->get_children()');

# TEST 16
ok($storage->get_children_recursively(), '$storage->get_children_recursively()');

# TEST 17
ok($storage->get_parents(), '$storage->get_parents()');

# TEST 18
ok($storage->get_parents_recursively(), '$storage->get_parents_recursively()');

# TEST 19
ok($storage->get_all_features(), '$storage->get_all_features()');

# TEST 20
ok($storage->get_features_by_type(), '$storage->get_features_by_type()');

# TEST 21
ok($storage->get_recursive_features_by_type(), '$storage->get_recursive_features_by_type()');

# TEST 22
ok($storage->get_feature_by_id(), '$storage->get_feature_by_id()');

# TEST 23
ok($storage->filter_features(), '$storage->filter_features()');

################################################################################
################################# Ways to Test #################################
################################################################################

__END__



=head3
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
=cut
