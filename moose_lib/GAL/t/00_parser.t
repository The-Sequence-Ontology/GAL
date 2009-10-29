#!/usr/bin/perl
use strict;

use Test::More tests => 14;

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
ok($parser->next_feature, '$parser->next_feature');

# TEST 4
ok($parser->get_next_feature, '$parser->get_next_feature');

# TEST 5
my @ids;
while (my $f = $parser->parse_next_feature) {
	push @ids, $f->id;
}
ok(scalar @ids > 2, '$parser->parse_next_feature');
$parser = undef;

my $parser = GAL::Parser->new(file => 'data/soap_snp.gff');

# TEST 6
ok($parser->get_all_features, '$parser->parse->get_features');

# TEST 7
ok($parser->get_features, '$parser->parse->get_features');

# TEST 8
ok($parser->file, '$parser->file');

# TEST 9
ok($parser->record_separator, '$parser->record_separator');

# TEST 10
ok($parser->field_separator, '$parser->field_separator');

# TEST 11
ok($parser->comment_delimiter, '$parser->comment_delimiter');

# TEST 12
ok($parser->fields, '$parser->fields');

# TEST 13
ok($parser->feature_factory, '$parser->feature_factory');

# TEST 14
ok($parser->parser, '$parser->parser');

#BAIL_OUT('Tests below here have not been written');

# TEST 16
#ok($parser->_read_next_record, '$parser->_read_next_record');

# TEST 17
#ok($parser->parse, '$parser->parse');

# TEST 18
#ok($parser->_parse_all_features, '$parser->_parse_all_features');

# TEST 19
#ok($parser->parse_record, '$parser->parse_record');

# TEST 20
#ok($parser->parse_attributes, '$parser->parse_attributes');

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
