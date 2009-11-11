#!/usr/bin/perl
use strict;

use Test::More tests => 12;

BEGIN {
	use lib '../../';
	# TEST 1
	use_ok('GAL::Parser');
}

my $path = $0;
$path =~ s/[^\/]+$//;
$path ||= '.';
chdir($path);

my $parser = GAL::Parser->new(file => 'data/soap_snp.gff');

# TEST 2
isa_ok($parser, 'GAL::Parser');

# TEST 3
ok($parser->file, '$parser->file');

# TEST 4
ok($parser->parser, '$parser->parser');

# TEST 5
ok(my $record = $parser->_read_next_record, '$parser->_read_next_record');

# TEST 6
ok($parser->record_separator, '$parser->record_separator');

# TEST 7
ok($parser->field_separator, '$parser->field_separator');

# TEST 8
ok($parser->comment_delimiter, '$parser->comment_delimiter');

# TEST 9
ok($parser->fields, '$parser->fields');

# TEST 10
ok($parser->parse_record($record), '$parser->parse_record');

# TEST 11
my $attribute_text = 'ID=12345; name=Gene1; Parent=6789,9876;';
ok(my $att_hash = $parser->parse_attributes($attribute_text), '$parser->parse_attributes');

# TEST 12
ok(my $genotype = $parser->get_genotype('A', ['A', 'T']), '$parser->get_genotype');

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
