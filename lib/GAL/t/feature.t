#!/usr/bin/perl
use strict;

use Test::More 'no_plan'; # tests => 10;

BEGIN {
	use lib '../../';
	#TEST 1
	use_ok('GAL::Feature');
}

my $path = $0;
$path =~ s/[^\/]+$//;
$path ||= '.';
chdir($path);

my $obj = GAL::Feature->new(seqid   => 'chr1',
			    source  => 'SOAP',
			    type    => 'SNP',
			    start   => 1234,
			    end     => 5678,
			    score   => '.',
			    strand  => '+',
			    phase   => '.',
			    attributes => {variant_allele   => ['A'],
					   reference_allele => ['G'],
					   variant_reads    => ['7'],
					   referenece_reads => ['8'],
					   total_reads      => ['15'],
					   genotype         => ['heterozygous'],
					   genotype_prob    => ['0.667'],
					   intersected_type => ['intron', 'splice_site'],
					   intersected_xref => ['RefSeq:NM_123456'],
					   variant_effect   => ['sequence_variant_affecting_splice_acceptor'],
				     }
		      );

#TEST 2
ok($obj->seqid eq 'chr1', '$obj->seqid');

#TEST 3
ok($obj->source eq 'SOAP', '$obj->source');

#TEST 4
ok($obj->type eq 'SNP', '$obj->type');

#TEST 5
ok($obj->start == 1234, '$obj->start');

#TEST 6
ok($obj->end == 5678, '$obj->end');

#TEST 7
ok($obj->score eq '.', '$obj->score');

#TEST 8
ok($obj->strand eq '+', '$obj->strand');

#TEST 9
ok($obj->phase eq '.', '$obj->phase');

#TEST 10
ok(ref($obj->attributes) eq 'HASH', '$obj->attributes');

#TEST 10
ok($obj->to_gff3, '$obj->to_gff3');

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
