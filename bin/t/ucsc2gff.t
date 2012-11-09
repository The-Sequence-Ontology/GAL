#!/usr/bin/perl

use strict;
use warnings;

use GAL::Run;
use Test::More;
use FindBin;

chdir $FindBin::Bin;
my $path = "$FindBin::Bin/..";

my $tool = GAL::Run->new(path => $path,
			 command => 'ucsc2gff');

################################################################################
# Testing that ucsc2gff compiles and returns usage statement
################################################################################

ok(! $tool->run(cl_args => '--help'), 'ucsc2gff complies');
like($tool->get_stdout, qr/Synopsis/, 'ucsc2gff prints usage statement');

################################################################################
# Testing that ucsc2gff converts refGene
################################################################################

my @cl_args = ('-table refGene',
	       '--pragma data/gvf_pragma_template_hg19.txt',
	       '--fasta  data/hg19_chr22.fa',
	       'data/refGene_hg19_chr22.txt',
	      );

ok(! $tool->run(cl_args => \@cl_args), 'ucsc2gff runs on refGene.txt');
ok($tool->get_stdout =~ /ID=NM_001135862:exon:14;Parent=NM_001135862;/,
   'ucsc2gff has the correct output');
ok($tool->get_stderr =~ /stop_interupted_CDS/,
   'ucsc2gff has the correct error output');

$tool->clean_up;
################################################################################
# Testing that ucsc2gff converts ensGene
################################################################################

@cl_args = ('-table ensGene',
	    '--pragma data/gvf_pragma_template_hg19.txt',
	    '--fasta  data/hg19_chr22.fa',
	    'data/ensGene_hg19_chr22.txt',
	   );

ok(! $tool->run(cl_args => \@cl_args), 'ucsc2gff runs on ensGene.txt');
ok($tool->get_stdout =~ /ID=ENST00000427528:exon:01;Parent=ENST00000427528;/,
   'ucsc2gff has the correct output');
ok($tool->get_stderr =~ /stop_interupted_CDS/,
   'ucsc2gff has the correct error output');

$tool->clean_up;

################################################################################
# Testing that ucsc2gff converts ccdsGene
################################################################################

@cl_args = ('-table ccdsGene',
	    '--pragma data/gvf_pragma_template_hg19.txt',
	    '--fasta  data/hg19_chr22.fa',
	    'data/ccdsGene_hg19_chr22.txt',
	   );

ok(! $tool->run(cl_args => \@cl_args), 'ucsc2gff runs on ccdsGene');
ok($tool->get_stdout =~ /ID=CCDS14102\.1:CDS:08;Parent=CCDS14102\.1;/,
   'ucsc2gff has the correct output');
ok($tool->get_stderr =~ /stop_interupted_CDS/,
   'ucsc2gff has the correct error output');

$tool->clean_up;

################################################################################
# Testing that ucsc2gff converts knownGene
################################################################################

@cl_args = ('-table knownGene',
	    '--pragma data/gvf_pragma_template_hg19.txt',
	    '--fasta  data/hg19_chr22.fa',
	    'data/knownGene_hg19_chr22.txt',
	   );

ok(! $tool->run(cl_args => \@cl_args), 'ucsc2gff runs on knownGene');
ok($tool->get_stdout =~ /ID=uc010hbj\.2:exon:03;Parent=uc010hbj\.2;/,
   'ucsc2gff has the correct output');
ok($tool->get_stderr =~ /stop_interupted_CDS/,
   'ucsc2gff has the correct error output');

$tool->clean_up;

################################################################################
# Testing that ucsc2gff converts vegaGene
################################################################################

@cl_args = ('-table vegaGene',
	    '--pragma data/gvf_pragma_template_hg19.txt',
	    '--fasta  data/hg19_chr22.fa',
	    'data/vegaGene_hg19_chr22.txt',
	   );

ok(! $tool->run(cl_args => \@cl_args), 'ucsc2gff runs on vegaGene');
ok($tool->get_stdout =~ /ID=OTTHUMT00000316616:exon:02;Parent=OTTHUMT00000316616;/,
   'ucsc2gff has the correct output');
ok($tool->get_stderr =~ /stop_interupted_CDS/,
   'ucsc2gff has the correct error output');

$tool->clean_up;

################################################################################
# Testing that ucsc2gff converts GencodeGene
################################################################################

@cl_args = ('-table Gencode',
	    '--pragma data/gvf_pragma_template_hg19.txt',
	    '--fasta  data/hg19_chr22.fa',
	    'data/wgEncodeGencodeManualV4_hg19_chr22.txt',
	   );

ok(! $tool->run(cl_args => \@cl_args), 'ucsc2gff runs on GencodeGene');
ok($tool->get_stdout =~ /ID=ENST00000427528:exon:01;Parent=ENST00000427528;/,
   'ucsc2gff has the correct output');
ok($tool->get_stderr =~ /stop_interupted_CDS/,
   'ucsc2gff has the correct error output');

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
