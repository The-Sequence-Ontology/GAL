package GAL::Parser::watson_cshl;

use strict;
use vars qw($VERSION);


$VERSION = '0.01';
use base qw(GAL::Parser);

=head1 NAME

GAL::Parser::watson_cshl - <One line description of module's purpose here>

=head1 VERSION

This document describes GAL::Parser::watson_cshl version 0.01

=head1 SYNOPSIS

     use GAL::Parser::watson_cshl;

=for author to fill in:
     Brief code example(s) here showing commonest usage(s).
     This section will be as far as many users bother reading
     so make it as educational and exemplary as possible.

=head1 DESCRIPTION

=for author to fill in:
     Write a full description of the module and its features here.
     Use subsections (=head2, =head3) as appropriate.

=head1 METHODS

=cut

#-----------------------------------------------------------------------------

=head2 new

     Title   : new
     Usage   : GAL::Parser::watson_cshl->new();
     Function: Creates a GAL::Parser::watson_cshl object;
     Returns : A GAL::Parser::watson_cshl object
     Args    :

=cut

sub new {
	my ($class, @args) = @_;
	my $self = $class->SUPER::new(@args);
	return $self;
}

#-----------------------------------------------------------------------------

sub _initialize_args {
	my ($self, @args) = @_;

	######################################################################
	# This block of code handels class attributes.  Use the
	# @valid_attributes below to define the valid attributes for
	# this class.  You must have identically named get/set methods
	# for each attribute.  Leave the rest of this block alone!
	######################################################################
	my $args = $self->SUPER::_initialize_args(@args);
	my @valid_attributes = qw(); # Set valid class attributes here.
	$self->set_attributes($args, @valid_attributes);
	######################################################################

	# The columns are:
	#
	# BCM_local_SNP_ID -- unique ID for referring to the SNPs ahead of
	# submission to dbSNP (we can talk about what and when to submit to
	# dbSNP).
	#
	# chromosome --  (self explanatory)
	#
	# coordinate -- (self explanatory)
	#
	# reference_allele -- plus strand reference base
	#
	# variant_allele -- plus strand variant base
	#
	# match_status -- a Y, N or "." if a dbSNP allele, Y if the variant
	# matches the dbSNP allele, or N if it doesn't; a "." if it's a novel
	# SNP.
	#
	# rs# -- the rsid if dbSNP, "novel" otherwise.
	#
	# alternate_allele -- usually a "." (surrogate for null). A, C, T or G
	# if a third allele is seen in the reads at the given position, it's
	# listed here.  I'm don't expect you to dis play 3d allele
	# information.
	#
	# variant_count -- number of reads in which variant allele was
	# seen. Can be 1 variants matching dbSNP alleles ("Y" in match_status
	# column), must be 2 for novel alleles, for dbSNP positions that don't
	# match the dbSNP alleles ("N" in match_status column) or for dbSNP
	# positions where there is an alternate allele.
	#
	# alternate_allele_count -- number of reads in which an
	# alternate_allele is seen. Generally these are seen in only one read
	# and are probably errors, and should not be mentioned. I n some rare
	# instances (134 times), both the variant allele and the alternate
	# allele are seen multiple times.
	#
	# total_coverage -- the total number of reads at a given SNP position.
	#
	# "genotype" -- "het" if the reference allele is seen at least
	# once. "." (null) if not. These are the sites that are confidently
	# heterozygotes. The others provisionally homozygote s, and in cases
	# where the coverage is deep enough probably they are.

	$self->fields([qw(id chromosome coordinate reference_seq
			  variant_seq match_status rsid alternate_seq
			  variant_count alternate_seq_count
			  total_coverage genotype)]);
}

#-----------------------------------------------------------------------------

=head2 parse_record

 Title   : parse_record
 Usage   : $a = $self->parse_record();
 Function: Parse the data from a record.
 Returns : A hash ref needed by Feature.pm to create a Feature object
 Args    : A hash ref of fields that this sub can understand (In this case GFF3).

=cut

sub parse_record {
	my ($self, $record) = @_;

	# id chromosome coordinate reference_seq variant_seq
	# match_status rsid alternate_seq variant_count
	# alternate_seq_count total_coverage genotype

	my $id         = $record->{id};
	my $seqid      = $record->{chromosome};
	my $source     = 'JDW_CSHL';

	my $type       = 'SNP';
	my $start      = $record->{coordinate};
	my $end        = $record->{coordinate};
	my $score      = '.';
	my $strand     = '+';
	my $phase      = '.';

	my $reference_seq = $record->{reference_seq};
	my @variant_seqs;
	push @variant_seqs, $record->{variant_seq};

	my @variant_reads;
	push @variant_reads, $record->{variant_count};

	if ($record->{alternate_seq} ne '.') {
		push @variant_seqs, $record->{alternate_seq};
		push @variant_reads,   $record->{alternate_seq_count};
	}

	# If we have reference_reads then push that seq to the variants
	my $reference_reads = $record->{total_coverage} - $record->{variant_count}  -
	  $record->{alternate_count};
	if ($reference_reads > 0) {
		push @variant_reads, $reference_reads;
		push @variant_seqs, $reference_seq;
	}

	my $total_reads = $record->{total_coverage};

	my $genotype = scalar @variant_seqs > 1 ? 'heterozygous' : 'homozygous';
	my $their_genotype = $record->{genotype} eq 'het' ? 'heterozygous' : undef;

	my $intersected_snp = $record->{rs} =~ /rs\d+/ ? 'dbSNP:' . $record->{rs} : undef;

	my $attributes = {Reference_seq => [$reference_seq],
			  Variant_seq   => \@variant_seqs,
			  ID            => [$id],
			  Variant_reads => \@variant_reads,
			  Total_reads   => [$total_reads],
			  Genotype      => [$genotype],
			 };

	push @{$attributes->{Intersected_feature}}, $intersected_snp
	  if $intersected_snp;

	my $feature_data = {feature_id => $id,
			    seqid      => $seqid,
			    source     => $source,
			    type       => $type,
			    start      => $start,
			    end        => $end,
			    score      => $score,
			    strand     => $strand,
			    phase      => $phase,
			    attributes => $attributes,
			   };

	return $feature_data;
}

#-----------------------------------------------------------------------------

=head2 foo

 Title   : foo
 Usage   : $a = $self->foo();
 Function: Get/Set the value of foo.
 Returns : The value of foo.
 Args    : A value to set foo to.

=cut

sub foo {
	my ($self, $value) = @_;
	$self->{foo} = $value if defined $value;
	return $self->{foo};
}

#-----------------------------------------------------------------------------

=head1 DIAGNOSTICS

=for author to fill in:
     List every single error and warning message that the module can
     generate (even the ones that will "never happen"), with a full
     explanation of each problem, one or more likely causes, and any
     suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::Parser::watson_cshl> requires no configuration files or environment variables.

=head1 DEPENDENCIES

None.

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to:
barry.moore@genetics.utah.edu

=head1 AUTHOR

Barry Moore <barry.moore@genetics.utah.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009, Barry Moore <barry.moore@genetics.utah.edu>.  All rights reserved.

    This module is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut

1;
