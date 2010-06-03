#!/usr/bin/perl
use strict;

use Test::More tests => 3;

BEGIN {
	use lib '../../';
	#TEST 1
	use_ok('GAL::Base');
}

my $path = $0;
$path =~ s/[^\/]+$//;
$path ||= '.';
chdir($path);

# TEST 2
my $base = GAL::Base->new();
isa_ok($base, 'GAL::Base');

my @nts;
for my $code (qw(A C G T U M R W S Y K V H D B N)) {
	push @nts, $base->expand_iupac_nt_codes($code);
}
# TEST 3
my $nts_string = join '', @nts;
is($nts_string,
   'ACGTTACAGATCGCTGTACGACTAGTCGTGATC',
   '$base->expand_iupac_nt_codes($code)');

# TEST 3
# ok($base->throw, '$base->throw');

# TEST 3
# ok($base->warn, '$base->warn');

# TEST 3
# ok($base->wrap_text, '$base->wrap_text');

# TEST 3
# ok($base->trim_whitespace, '$base->trim_whitespace');

# TEST 3
# ok($base->first_word, '$base->first_word');

# TEST 3
# ok($base->prepare_args, '$base->prepare_args');

# TEST 3
# ok($base->set_attributes, '$base->set_attributes');

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
