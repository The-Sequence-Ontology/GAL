package GAL::Parser::celera_indel;

use strict;
use vars qw($VERSION);


$VERSION = '0.01';
use base qw(GAL::Parser);

=head1 NAME

GAL::Parser::celera_indel - <One line description of module's purpose here>

=head1 VERSION

This document describes GAL::Parser::celera_indel version 0.01

=head1 SYNOPSIS

     use GAL::Parser::celera_indel;

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
     Usage   : GAL::Parser::celera_indel->new();
     Function: Creates a celera_indel object;
     Returns : A celera_indel object
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

	$self->fields([qw(chromosome variant_id variant_type start end score
			  strand phase null allele genotype)]);
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

	# 1 1104685014413 homozygous_indel 714051 714051 . + . . tccat Homozygous_Insertion
	# 1 1104685097444 homozygous_indel 747705 747740 . + . . CCTGGCCAGCAGATCCACCCTGTCTATACTACCTG Homozygous_Deletion
	# 1 1104685097445 homozygous_indel 751820 751820 . + . . T Homozygous_Insertion
	# 1 1104685097447 homozygous_indel 758024 758024 . + . . gtttt Homozygous_Insertion
	# 1 1104685097448 homozygous_indel 764762 764804 . + . . CACACACACCTGGACACACACACGTAGACACACACACCTAGA Homozygous_Deletion
	# 1 1104685097449 homozygous_indel 765122 765122 . + . . gaaa Homozygous_Insertion
	# 1 1104685097450 homozygous_indel 765666 765667 . + . . A Homozygous_Deletion
	# 1 1104685097451 homozygous_indel 768169 768169 . + . . CT Homozygous_Insertion
	# 1 1104685097452 homozygous_indel 778884 778933 . + . . AAACTGATGAACCCCGACCCTGATGAACGTGAGATGACCGCCGTGTGGT Homozygous_Deletion


	# Headers use by parser
	# chromosome variant_id variant_type start end orientation alleles processing

	my ($genotype, $type) = split /_/, $record->{genotype};

	# Fill in the first 8 columns for GFF3
	my $id         = $record->{variant_id};
	my $seqid      = 'chr' . $record->{chromosome};
	my $source     = 'Celera';
	my ($start, $end);
	if ($type eq 'Insertion') {
		$start = $record->{start};
		$end   = $record->{end};
	}
	else {
		$start = ++$record->{start};
		$end   = $record->{end};
	}
	my $score      = '.';
	my $strand     = $record->{strand};
	my $phase      = '.';

#	$self->fields([qw(chromosome variant_id variant_type start end score
#                          strand phase null allele genotype)]);

	# Create the attributes hash

	# Assign the reference and variant allele sequences:
	# reference_allele=A
	# variant_allele=G
	my ($reference_allele, $variant_allele);
	if ($type eq 'Deletion') {
		$reference_allele = $record->{allele};
		$variant_allele   = '-';
	}
	else {
		$reference_allele = '-';
		$variant_allele   = $record->{allele};
	}
	# Assign the reference and variant allele read counts:

	# reference_reads=A:7
	# variant_reads=G:8

	# Assign the total number of reads covering this position:
	# total_reads=16

	# Assign the genotype:
	# genotype=homozygous
	$genotype = 'homozygous:no_reference';

	# Assign the probability that the genotype call is correct:
	# genotype_probability=0.667

	# 1624998 heterozygous_SNP
	# 1450860 homozygous_SNP
	#  128111 heterozygous_insertion
	#   92647 heterozygous_deletion
	#   22525 heterozygous_MNP
	#   21480 heterozygous_mixed_sequence_variant
	#   14838 homozygous_MNP

	# The mixed sequence variants above have things like TT/C-
	# where their is a contiguous substiution and deletion or
	# insertion.

	$type = $type eq 'Deletion' ? 'nucleotide_deletion' : 'nucleotide_insertion';

	# Any quality score given for this variant should be assigned
	# to $score above.  Here you can assign a name for the type of
	# score or algorithm used to calculate the sscore.

	# Create the attribute hash reference.  Note that all values
	# are array references - even those that could only ever have
	# one value.  This is for consistency in the interface to
	# Features.pm and it's subclasses.
	# For sequence_alteration features the suggested keys include:
	# reference_allele, variant_allele, reference_reads, variant_reads
	# total_reads, genotype, genotype_probability and score type
	my $attributes = {reference_allele => [$reference_allele],
			  variant_allele   => [$variant_allele],
			  genotype         => [$genotype],
			  ID               => [$id],
			 };

	my $feature_data = {id         => $id,
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

<GAL::Parser::celera_indel> requires no configuration files or environment variables.

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
