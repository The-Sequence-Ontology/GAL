#!/usr/bin/perl
use strict;

use Test::More 'no_plan'; # tests => 10;

BEGIN {
	use lib '../';
	#TEST 1
	use_ok('GAL::List::Categorical');
}

my $path = $0;
$path =~ s/[^\/]+$//;
$path ||= '.';
chdir($path);

# TEST 2
my $list = List->new([qw(red red red blue blue green yellow orange orange
			 purple purple purple purple)]);
isaok($list, 'GAL::List::Categorical');

# TEST 3
ok($list->count == 13, '$list->count');

# TEST 4



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
