#!/usr/bin/perl
use strict;

use Test::More tests => 17;

BEGIN {
	use lib '../../';
	#TEST 1
	use_ok('GAL::Annotation');
}

my $path = $0;
$path =~ s/[^\/]+$//;
$path ||= '.';
chdir($path);

# TEST 2
my $annotation = GAL::Annotation->new();
isa_ok($annotation, 'GAL::Annotation');

# To get a list of all of the subs and throws:
# Select an empty line and then: C-u M-| grep -nP '^sub ' ../Class.pm
# Select an empty line and then: C-u M-| grep -C2 -nP '\>throw(' ../Class.pm

# TEST 3
ok(my $dsn = $annotation->dsn('DBI:mysql:gal_test'), '$annotation->dsn');

# TEST 4
ok(my $storage = $annotation->storage(''), '$annotation->storage');

# TEST 5
ok(my $parser = $annotation->parser(''), '$annotation->parser');

# TEST 6
ok($annotation->load_file(file => './data/soap_snp.gff', class => 'soap_snp'), '$annotation->load_file');

# TEST 7

my $feature_hash = 
  {'source'     => 'SoapSNP',
   'feature_id' => 'YHSNP0128643',
   'phase'      => '.',
   'strand'     => '+',
   'score'      => '25',
   'type'       => 'SNP',
   'attributes' => {'reference_reads'  => ['A:48'],
		    'reference_allele' => ['A'],
		    'variant_allele'   => ['A','G'],
		    'variant_reads'    => ['A:48','G:26'],
		    'genotype'         => ['heterozygous:with_reference_allele'],
		    'total_reads'      => [74]
		   },
   'end'        => '4793',
   'start'      => '4793',
   'seqid'      => 'chr1'
  };

ok($annotation->add_feature($feature_hash), '$annotation->add_feature');

# TEST 8
ok($annotation->get_all_features(), '$annotation->get_all_features');

# TEST 9
ok($annotation->get_features_by_type(), '$annotation->get_features_by_type');

# TEST 10
ok($annotation->get_recursive_features_by_type(), '$annotation->get_recursive_features_by_type');

# TEST 11
ok($annotation->get_feature_by_id(), '$annotation->get_feature_by_id');

# TEST 12
ok($annotation->filter_features(), '$annotation->filter_features');

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
