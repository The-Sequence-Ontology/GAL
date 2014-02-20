#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use FindBin;
use lib "$FindBin::RealBin/../../lib";
use GAL::Run;

chdir $FindBin::RealBin;
my $path = "$FindBin::RealBin/../";
my $command;

my $tool = GAL::Run->new(path => $path,
			 command => 'gtf2gff3');

$tool->verbosity('debug');

################################################################################
# Testing that gtf2gff3 compiles and returns usage statement
################################################################################

ok(! $tool->run(cl_args => '--help'), 'gtf2gff3 complies');
like($tool->get_stdout, qr/This script will convert GTF formatted files to valid GFF3/, 'gtf2gff3 prints usage statement');

my @gtf_files = qw(
		    augustus_short.gtf
		    cufflinks_short.gtf
		    Danio.short.gtf
		    ensemble_01_short.gtf
		    exon_hunter.short.gtf
		    gencode_short.gtf
		    Homo_sapiens_1005.short.gtf
		    hsap_hg18.short.gtf
		    refgene_short.gtf
		    twinscan_chr1.short.gtf
		    unknown_01_short.gtf
		 );

################################################################################
# Testing gtf2gff3 on GTF files
################################################################################
$path = "$FindBin::Bin/data/";

for my $gtf_file (@gtf_files) {
  $gtf_file = $path . $gtf_file;
  my ($gff_file, $vld_file);
  ($gff_file = $gtf_file) =~ s/gtf$/gff3/;
  ($vld_file = $gff_file) =~ s/\.gff3$/.valid.gff3/;

  my @cl_args = ($gtf_file,
		);

  ok(! $tool->run(cl_args => \@cl_args,
		  stdout => $gff_file), 'gtf2gff3 augustus_short.gtf');

  ok(! `diff $gff_file $vld_file`, "gtf2gff3 produces valid output for $gtf_file");
  $tool->clean_up($gff_file);
}


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
