package GAL::Parser::venter_snp;

use strict;
use vars qw($VERSION);


$VERSION = '0.01';
use base qw(GAL::Parser);

=head1 NAME

GAL::Parser::venter_snp - <One line description of module's purpose here>

=head1 VERSION

This document describes GAL::Parser::venter_snp version 0.01

=head1 SYNOPSIS

     use GAL::Parser::venter_snp;

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
     Usage   : GAL::Parser::venter_snp->new();
     Function: Creates a venter_snp object;
     Returns : A venter_snp object
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
                          orientation seqs processing)]);
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

# 1.  Chromosome (NCBI 36)
#
# 2.  Variant identifier (unique to each variant)
#
# 3.  Variant Type
#         There are 7 different variant types in this file.  See  Fig. 4
#         in Levy, et al. for a description of the variant types.
#         "heterozygous_mixed_sequence_variant" in this file corresponds
#         to "complex" in the figure.
#
# 4.  Chromosome start position (NCBI 36, in space-based coordinates)
#
# 5.  Chromosome end position (NCBI 36, space-based coordinates)
#
# 6.  Not used.
#
# 7.  Orientation with respect to NCBI.  The sequence is give in column.
#     If the value in column 7 is "+" or "-", this means that the sequence
#     corresponds to the positive or negative strand of NCBI, respectively.
#     A "." is given for variants that had ambiguous mapping.
#
# 8.  This field is delimited by semicolons. In the first field, the
#     alleles of the variant are given (e.g. A/B).  For homozygous
#     variants, the first allele A matches NCBI 36, the second allele B
#     matches HuRef.  There can be more than 2 alleles, which may occur
#     when reads may pile up in repititive regions.
#
#     The second field "RMR" indicates RepeatMasker status.   RMR=1
#     indicates that the variant occurs in a region identified by
#     RepeatMasker; RMR=0 indicates that the variant does not.
#
#     The third field "TR" indicates TandemRepeat status. TR=1 indicates
#     that the variant occurs in a tandem repeat, as identified by
#     TandemRepeatFinder.  TR=0 indicates that the variant does not.
#
#
# 9.  This column indicates whether a variant was post-processed.
#     Method1 indicates the variant was kept in its original form and
#     not post-processed.  Method1_MSV_clean corresponds to a modified
#     variant call where heterozygous mixed sequence variants were
#     changed to indels.  Method2 indicates that the variant is composed of a
#     cluster of Method1 variants that were within 10 bp of each other
#     (see paper for procedure).  Method2_AmbiguousMapping indicates
#     that after the clustering, the position of the new variant could
#     not be easily placed on NCBI 36, and there may be some error in
#     the mapping position given.
#
# *Please note that the values provided in Table 4 of Levy, et al. are based on Method1
# variants.

# 1       1103675000194   homozygous_SNP  815416  815417  .       +       A/G;RMR=1;TR=0  Method1
# 1       1103675000195   heterozygous_SNP        817115  817116  .       +       A/C;RMR=1;TR=0  Method1

	# Headers use by parser
	# chromosome variant_id variant_type start end orientation seqs processing

	# Fill in the first 8 columns for GFF3
	my $id         = $record->{variant_id};
	my $seqid      = 'chr' . $record->{chromosome};
	my $source     = 'Celera';
	my $type       = ''; # Assigned below
	my $start      = $record->{start}++;
	my $end        = $record->{end};
	my $score      = '.';
	my $strand     = $record->{orientation};
	my $phase      = '.';


	my ($seq_text) = split /;/, $record->{seqs};
	my ($reference_seq, @variant_seqs) = split m|/|, $seq_text;
	unshift @variant_seqs, $reference_seq
	  if $record->{variant_type} =~ /^heterozygous/;

        my $genotype = scalar @variant_seqs > 1 ? 'heterozygous' : 'homozygous';

	# sort | uniq -c | sort -nr
	# 1624998 heterozygous_SNP
	# 1450860 homozygous_SNP
	#  128111 heterozygous_insertion
	#   92647 heterozygous_deletion
	#   22525 heterozygous_MNP
	#   21480 heterozygous_mixed_sequence_variant
	#   14838 homozygous_MNP

	my ($their_genotype, $variant_type) =
	  $record->{variant_type} =~ /(.*?)_(.*)/;

	my %type_map = (deletion               => 'nucleotide_deletion',
			insertion              => 'nucleotide_insertion',
			mixed_sequence_variant => 'sequence_alteration',
			MNP                    => 'MNP',
			SNP                    => 'SNV',
		       );

	$type = $type_map{$variant_type};

	my $attributes = {Reference_seq => [$reference_seq],
			  Variant_seq   => \@variant_seqs,
			  Genotype      => [$genotype],
			  ID            => [$id],
			 };

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

<GAL::Parser::venter_snp> requires no configuration files or environment variables.

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
