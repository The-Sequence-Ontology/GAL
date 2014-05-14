#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FindBin;
use lib "$FindBin::RealBin/../../lib";
use GAL::Run;

chdir $FindBin::Bin;
my $path = "$FindBin::Bin/..";

my $tool = GAL::Run->new(path => $path,
			 command => 'gal_CDS_sequence');

$tool->verbosity('debug');

################################################################################
# Testing that gal_CDS_sequence compiles and returns usage statement
################################################################################

ok(! $tool->run(cl_args => '--help'), 'gal_CDS_sequence complies');
like($tool->get_stdout, qr/Synopsis/, 'gal_CDS_sequence prints usage statement');

################################################################################
# Testing that gal_CDS_sequence gets correct CDS sequence
################################################################################

my $gff3_file = 'data/Homo_sapiens.GRCh37.73.chr22.short.gff3';
ok(! `gunzip $gff3_file.gz`, "Unzipping file: $gff3_file.gz");

my @cl_args = ($gff3_file,
	       'data/hg19_chr22.fa',
	      );

ok(! $tool->run(cl_args => \@cl_args), 'gal_CDS_sequence runs');
ok($tool->get_stdout =~ /ATGGCGTCCTCTTCTACTGTGCCTCTGGGATTTCACTATGAAACAAAGTA\n
			 TGTTGTTCTCAGCTACTTGGGACTCCTCTCTCAAGAGAAGCTGCAAGAGC\n
			 AACATCTTTCCTCACCCCAAGGGGTTCAACTAGATATAGCTTCACAATCT\n
			 CTGGATCAAGAAATTTTATTAAAAGTTAAAACTGAAATTGAAGAAGAGCT\n
			 AAAATCTCTGGACAAAGAAATTTCTGAAGCCTTCACCAGCACAGGCTTTG\n
			 ACCGTCACACTTCTCCAGTGTTCAGCCCTGCCAATCCAGAAAGCTCAATG\n
			 GAAGACTGCTTGGCCCATCTTGGAGAAAAAGTGTCCCAGGAACTGAAAGA\n
			 GCCTCTCCATAAAGCATTGCAAATGCTCCTGAGCCAGCCAGTGACATATC\n
			 AGGCATTTCGGGAATGTACACTGGAGACCACAGTTCATGCCAGCGGCTGG\n
			 AATAAGATTTTGGTGCCTCTGGTTTTGCTACGACAAATGCTTTTGGAATT\n
			 GACAAGACGTGGTCAAGAACCTTTGAGCGCACTGCTGCAGTTTGGCGTGA\n
			 CATACCTGGAGGACTATTCGGCAGAGTACATCATTCAGCAAGGTGGCTGG\n
			 GTATGA/x, 'gal_CDS_sequence gets correct CDS sequence');

$tool->clean_up;

################################################################################
# Testing that gal_CDS_sequence gets correct tranlastion
################################################################################

@cl_args = ('--translate',
	    $gff3_file,
	    'data/hg19_chr22.fa',
	   );

ok(! $tool->run(cl_args => \@cl_args), 'gal_CDS_sequence runs');
ok($tool->get_stdout =~ /MALLLSDWCPDGDADTHTGTDPGRTTHRLCARERGVRGTQPCPRIYLRLP\n
			 AQNCEETRFCCASPGSVVLGHGAPRTASPPSALSHPSPLEGLSFSPFPPS\n
			 VLSHPSPPEGLSFSLFHCLCSGKLSESPGCFWNSLGWSFSVLTEPGVWKV\n
			 GEAIWVAENLAQPLTSPCAC\*/x, 'gal_CDS_sequence has correct output');

ok(! `gzip $gff3_file`, "Zipping file: $gff3_file.gz");

$tool->clean_up;
done_testing();

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
