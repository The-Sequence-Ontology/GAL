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

my $tool = GAL::Run->new(path => $path,
			 command => 'gal_remove_transcripts');

$tool->verbosity('debug');

################################################################################
# Testing that gal_remove_transcripts compiles and returns usage statement
################################################################################

ok(! $tool->run(cl_args => '--help'), 'gal_remove_transcripts complies');
like($tool->get_stdout, qr/Synopsis/, 'gal_remove_transcripts prints usage statement');

################################################################################
# Testing that gal_remove_transcripts does something else
################################################################################

my $gff3_file = 'data/Homo_sapiens.GRCh37.73.chr22.short.gff3';

ok(! `gunzip $gff3_file . '.gz'`, "Unzip data file: data/${gff3_file}.gz");


my @cl_args = ('-ids data/remove_ids.txt',
	       $gff3_file,
	      );

ok(! $tool->run(cl_args => \@cl_args), 'gal_remove_transcripts runs');
ok($tool->get_stderr =~ /INFO : total_transcript_skipped : 20/, 'STDERR correct for gal_remove_transcripts');

my $stdout = $tool->stdout;
my $pre_count = `grep -c 'mRNA' $gff3_file`;
my $count     = `grep -c 'mRNA' $stdout`;
ok($pre_count - $count == 20, 'Correct number of transcripts removed');

ok(! `gzip $gff3_file`, 'Zip data file: data/Homo_sapiens.GRCh37.73.final.chr22.gff3');
$tool->clean_up('data/Homo_sapiens.GRCh37.73.chr22.short.sqlite');
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
