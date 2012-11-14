#!/usr/bin/perl

use strict;
use warnings;

use GAL::Run;
use Test::More;
use FindBin;

chdir $FindBin::Bin;
my $path = "$FindBin::Bin/..";

my $tool = GAL::Run->new(path    => $path,
			 command => 'gff_tool');

################################################################################
# Testing that gff_tool compiles and returns usage statement
################################################################################

ok(! $tool->run(cl_args => '--help'), 'gff_tool complies');
like($tool->get_stdout, qr/Synopsis/, 'gff_tool prints usage statement');

################################################################################
# Testing that gff_tool runs --filter
################################################################################

my @cl_args = ('--filter --code \'$f->{type} eq "gene"\'',
	       'data/dmel-4-r5.46.genes.gff',
	      );

ok(! $tool->run(cl_args => \@cl_args), 'gff_tool runs ');
ok($tool->get_stdout =~ /ID=FBgn0053653;Name=Caps;Alias=CG18026,FBgn0027577,FBgn0040042/,
   'gff_tool has the correct output');

$tool->clean_up;

################################################################################
# Testing that gff_tool runs --alter
################################################################################

@cl_args = ('--alter',
	    '--code \'$f->{seqid} =~ s/^chr//\',',
	    'data/dmel-4-r5.46.genes.gff',
	   );

ok(! $tool->run(cl_args => \@cl_args), 'gff_tool runs ');
ok($tool->get_stdout =~ /4\s+FlyBase\s+three_prime_UTR\s+1274856/,
   'gff_tool has the correct output');

$tool->clean_up;

################################################################################
# Testing that gff_tool runs --hash_ag
################################################################################

@cl_args = ('--hash_ag \'push @{$h{$f->{type}}}, $f\'',
	    '--code \'my @x = sort {($a->{end} - $a->{start}) <=> ($b->{end} - $b->{start})} @$v;shift @x\'',
	    'data/dmel-4-r5.46.genes.gff',
	   );

ok(! $tool->run(cl_args => \@cl_args), 'gff_tool runs ');
ok($tool->get_stdout =~ /4\s+FlyBase\s+exon\s+906080\s+906088/,
   'gff_tool has the correct output');

$tool->clean_up;

done_testing();

# ../gff_tool --in_place
# ../gff_tool --out_ext
# ../gff_tool --fasta
# ../gff_tool --so_file
# ../gff_tool --ids
# ../gff_tool --seqids
# ../gff_tool --include
# ../gff_tool --exclude
# ../gff_tool --code
# ../gff_tool --overlaps
# ../gff_tool --genes
# ../gff_tool --merge
# ../gff_tool --blend
# ../gff_tool --sort
# ../gff_tool --stats
# ../gff_tool --print
# ../gff_tool --sequence
# ../gff_tool --splice_sequence
# ../gff_tool --features
# ../gff_tool --fasta_only
# ../gff_tool --fasta_no
# ../gff_tool --fasta_add
# ../gff_tool --meta_only
# ../gff_tool --meta_no
# ../gff_tool --meta_add
# ../gff_tool --pragmas
# ../gff_tool --add_ID
# ../gff_tool --union
# ../gff_tool --intersection
# ../gff_tool --l_compliment
# ../gff_tool --s_difference
# ../gff_tool --titv
# ../gff_tool --gvf_stats
# ../gff_tool --effect_stats
# ../gff_tool --gvf_sets
# ../gff_tool --fix_gvf

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
