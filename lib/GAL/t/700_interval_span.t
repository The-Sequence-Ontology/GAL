#!/usr/bin/perl
use strict;

use Test::More;

BEGIN {
	use lib '../../';
	use_ok('GAL::Annotation');
	use_ok('GAL::Interval::Span');
}

my $path = $0;
$path =~ s/[^\/]+$//;
$path ||= '.';
chdir($path);

my $span_obj = GAL::Interval::Span->new();
isa_ok($span_obj, 'GAL::Interval::Span');

ok(my $schema = GAL::Annotation->new('data/dmel-4-r5.46.genes.gff',
				     'data/dmel-4-chromosome-r5.46.fasta'),
   '$schema = GAL::Annotation->new("dmel.gff", "dmel.fasta"');

ok(my $features = $schema->features, '$features = $schema->features');

ok(my $exons = $features->search({type => 'exon'}),
   '$features->search({type => \'exon\'});');

my %annotated_UTRs;
while (my $exon = $exons->next) {
  $span_obj->add_feature($exon);
}

ok(my $span_count    = $span_obj->span_count,    '$span_obj->span_count');
ok(my $length_min    = $span_obj->length_min,	 '$span_obj->length_min');
ok(my $length_max    = $span_obj->length_max,	 '$span_obj->length_max');
ok(my $length_sum    = $span_obj->length_sum,	 '$span_obj->length_sum');
ok(my $length_stdev  = $span_obj->length_stdev,	 '$span_obj->length_stdev');
ok(my $length_median = $span_obj->length_median, '$span_obj->length_median');
ok(my $length_mean   = $span_obj->length_mean,	 '$span_obj->length_mean');

done_testing();


# To get a list of all of the subs and throws:
# Select an empty line and then: C-u M-| grep -nP '^sub ' ../Class.pm
# Select an empty line and then: C-u M-| grep -C2 -P '\>throw(' ../Class.pm

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
