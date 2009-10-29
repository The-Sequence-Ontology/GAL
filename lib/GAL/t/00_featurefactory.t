#!/usr/bin/perl
use strict;

use Test::More 'no_plan'; # tests => 10;

BEGIN {
	use lib '../../';
	#TEST 1
	use_ok('GAL::FeatureFactory');
}

my $path = $0;
$path =~ s/[^\/]+$//;
$path ||= '.';
chdir($path);

# TEST 2
my $factory = GAL::FeatureFactory->new();
isa_ok($factory, 'GAL::FeatureFactory');

# TEST 3
my $obj = $factory->create(seqid   => 'chr1',
			   source  => 'SOAP',
			   type    => 'SNP',
			   start   => 1234,
			   end     => 5678,
			   score   => '.',
			   strand  => '+',
			   phase   => '.',
			   attributes => {variant_allele    	  => ['A'],
					  reference_allele 	  => ['G'],
					  variant_reads    	  => ['7'],
					  reference_reads  	  => ['8'],
					  total_reads      	  => ['15'],
					  genotype         	  => ['heterozygous'],
					  genotype_probability    => ['0.667'],
					  intersected_type 	  => ['intron', 'splice_site'],
					  intersected_xref 	  => ['RefSeq:NM_123456'],
					  variant_effect   	  => ['sequence_variant_affecting_splice_acceptor'],
					 }
			  );
isa_ok($obj, 'GAL::Feature::sequence_alteration');

#TEST 4
ok($obj->seqid eq 'chr1', '$obj->seqid');

#TEST 5
ok($obj->source eq 'SOAP', '$obj->source');

#TEST 6
ok($obj->type eq 'SNP', '$obj->type');

#TEST 7
ok($obj->start == 1234, '$obj->start');

#TEST 8
ok($obj->end == 5678, '$obj->end');

#TEST 9
ok($obj->score eq '.', '$obj->score');

#TEST 10
ok($obj->strand eq '+', '$obj->strand');

#TEST 11
ok($obj->phase eq '.', '$obj->phase');

#TEST 12
ok(ref($obj->attributes) eq 'HASH', '$obj->attributes');

#TEST 13
ok($obj->variant_allele eq 'A', '$obj->variant_allele');

#TEST 14
ok($obj->reference_allele eq 'G', '$obj->reference_allele');

#TEST 15
ok($obj->variant_reads == 7, '$obj->variant_reads');

#TEST 16
ok($obj->reference_reads == 8, '$obj->reference_reads');

#TEST 17
ok($obj->total_reads == 15, '$obj->total_reads');

#TEST 18
ok($obj->genotype eq 'heterozygous', '$obj->genotype');

#TEST 19
ok($obj->genotype_probability eq '0.667', '$obj->genotype_prob');

#TEST 20
ok(ref($obj->intersected_types) eq 'ARRAY', '$obj->intersected_types');

#TEST 21
ok(ref($obj->intersected_xrefs) eq 'ARRAY', '$obj->intersected_xrefs');

#TEST 22
ok(ref($obj->variant_effects) eq 'ARRAY', '$obj->variant_effects');

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
