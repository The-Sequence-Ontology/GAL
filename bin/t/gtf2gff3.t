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
like($tool->get_stdout, qr/Synopsis/, 'gtf2gff3 prints usage statement');

# ~/GAL/bin/gtf2gff3  data/augustus_short.gtf           >  augustus_short.gff3           2>  augustus_short.err           &
# ~/GAL/bin/gtf2gff3  data/cufflinks_short.gtf          >  cufflinks_short.gff3          2>  cufflinks_short.err          &
# ~/GAL/bin/gtf2gff3  data/Danio.short.gtf              >  Danio.short.gff3              2>  Danio.short.err              &
# ~/GAL/bin/gtf2gff3  data/ensemble_01_short.gtf        >  ensemble_01_short.gff3        2>  ensemble_01_short.err        &
# ~/GAL/bin/gtf2gff3  data/exon_hunter.short.gtf        >  exon_hunter.short.gff3        2>  exon_hunter.short.err        &
# ~/GAL/bin/gtf2gff3  data/gencode_short.gtf            >  gencode_short.gff3            2>  gencode_short.err            &
# ~/GAL/bin/gtf2gff3  data/Homo_sapiens_1005.short.gtf  >  Homo_sapiens_1005.short.gff3  2>  Homo_sapiens_1005.short.err  &
# ~/GAL/bin/gtf2gff3  data/hsap_hg18.short.gtf          >  hsap_hg18.short.gff3          2>  hsap_hg18.short.err          &
# ~/GAL/bin/gtf2gff3  data/refgene_short.gtf            >  refgene_short.gff3            2>  refgene_short.err            &
# ~/GAL/bin/gtf2gff3  data/twinscan_chr1.short.gtf      >  twinscan_chr1.short.gff3      2>  twinscan_chr1.short.err      &
# ~/GAL/bin/gtf2gff3  data/unknown_01_short.gtf         >  unknown_01_short.gff3         2>  unknown_01_short.err         &

my $file;
################################################################################
# Testing gtf2gff3
################################################################################

$file = "$FindBin::Bin/data/data/augustus_short.gtf";
my @cl_args = ($file,
	      );

ok(! $tool->run(cl_args => \@cl_args), 'gtf2gff3 augustus_short.gtf');

my $md5_sum = `md5sum $file`;
chomp $md5_sum;
$md5_sum =~ s/(\S+).*/$1/;
ok($valid_md5{$file} eq $md5_sum, "gtf2gff3 --split produces valid output for $file");
$tool->clean_up($file);

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
