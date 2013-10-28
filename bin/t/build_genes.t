#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use FindBin;
use lib "$FindBin::RealBin/../../lib";
use lib "$FindBin::RealBin/../../lib/cpan";
use GAL::Run;

chdir $FindBin::Bin;
my $path = "$FindBin::Bin/..";

my $build_gene = GAL::Run->new(path    => $path,
			       command => 'build_genes');

################################################################################
# Testing that build_genes compiles and returns usage statement
################################################################################

ok(! $build_gene->run(cl_args => '--help'), 'build_genes complies');
like($build_gene->get_stdout, qr/Synopsis/, 'build_genes prints usage statement');

################################################################################
# Testing that build_genes builds genes for refGene.txt
################################################################################

my $ucsc2gff = GAL::Run->new(path    => $path,
			 command => 'ucsc2gff',
			 stdout  => 'data/refGene_hg19_chr22.gff3');

my @cl_args = ('-table refGene',
	       '--pragma data/gvf_pragma_template_hg19.txt',
	       '--fasta  data/hg19_chr22.fa',
	       'data/refGene_hg19_chr22.txt',
	      );

ok(! $ucsc2gff->run(cl_args => \@cl_args), 'ucsc2gff runs on refGene.txt');
ok($ucsc2gff->get_stdout =~ /ID=NM_001135862:exon:14;Parent=NM_001135862;/,
   'ucsc2gff has the correct output');
ok($ucsc2gff->get_stderr =~ /stop_interupted_CDS/,
   'ucsc2gff has the correct error output');

ok(! $build_gene->run(cl_args => ['data/refGene_hg19_chr22.gff3']), 'build_genes runs');
ok($build_gene->get_stdout =~ /gene\t51205920\t51222087\t\.\t\-\t\.\tID=RABL2B/,
   'build_gene has the correct output');
ok($build_gene->get_stderr =~ /WARN\s+:\s+duplicate_gene_id\s+:\s+PANX2/,
   'ucsc2gff has the correct error output');
ok($build_gene->get_stderr =~ /WARN\s+:\s+multiple_aliases_for_clustered_transcripts\s+:\s+TYMP,\s+SCO2/,
   'ucsc2gff has the correct error output');

$ucsc2gff->clean_up;
$build_gene->clean_up;
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
