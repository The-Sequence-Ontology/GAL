package GAL::Parser::soap_snp;

use strict;
use vars qw($VERSION);


$VERSION = '0.01';
use base qw(GAL::Parser);

=head1 NAME

GAL::Parser::soap_snp - <One line description of module's purpose here>

=head1 VERSION

This document describes GAL::Parser::soap_snp version 0.01

=head1 SYNOPSIS

     use GAL::Parser::soap_snp;

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
     Usage   : GAL::Parser::soap_snp->new();
     Function: Creates a GAL::Parser::soap_snp object;
     Returns : A GAL::Parser::soap_snp object
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
	my @valid_attributes = qw(); # Set valid class attributes here
	$self->set_attributes($args, @valid_attributes);
	######################################################################

	# Set the column headers from your incoming data file here
	# These will become the keys in your $record hash reference below.
	$self->fields([qw(seqid source type start end score strand phase attributes)]);
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

	# $record is a hash reference that contains the keys assigned
	# in the $self->fields call in _initialize_args above

	# Fill in the first 8 columns for GFF3
	# See http://www.sequenceontology.org/resources/gff3.html for details.
	my $original_atts = $self->parse_attributes($record->{attributes});

	my $id         = $original_atts->{ID}[0];
	my $seqid      = $record->{seqid};
	my $source     = $record->{source};
	my $type       = $record->{type};
	my $start      = $record->{start};
	my $end        = $record->{end};
	my $score      = $record->{score};
	my $strand     = $record->{strand};
	my $phase      = $record->{phase};

	$type = $type eq 'SNP' ? 'SNV' : $type;

	# chr1SoapSnpSNPSNP4793479325+.ID=YHSNP0128643; status=novel; ref=A; allele=A/G; support1=48; support2=26;
	# chr1SoapSNPSNP6434643448+.ID=YHSNP0128644; status=novel; ref=G; allele=A/G; support1=10; support2=11;
	# chr1SoapSNPSNP938969389651+.ID=rs4287120; status=dbSNP; ref=T; allele=C/T; support1=5; support2=4; location=MSTB1:LTR/MaLR;
	# chr1SoapSNPSNP22570722570743+.ID=rs6603780; status=dbSNP; ref=C; allele=C/G; support1=23; support2=12;
	# chr1SoapSNPSNP22583922583931+.ID=rs6422503; status=dbSNP; ref=C; allele=A/C; support1=13; support2=5; location=L1P2:LINE/L1;
	# chr1SoapSNPSNP52684952684976+.ID=YHSNP0128645; status=novel; ref=G; allele=G/T; support1=14; support2=12; location=L1MD3:LINE/L1;
	# chr1SoapSNPSNP55473155473130+.ID=rs1832728; status=dbSNP; ref=T; allele=C/T; support1=37; support2=12; location=Mitochondrial:Mt-tRNA;
	# chr1SoapSNPSNP55535355535328+.ID=rs7349153; status=dbSNP; ref=T; allele=C/T; support1=37; support2=9;
	# chr1SoapSNPSNP55537155537122+.ID=rs9283150; status=dbSNP; ref=G; allele=A/G; support1=46; support2=27;
	# chr1SoapSNPSNP55677955677945+.ID=rs3949348; status=dbSNP; ref=A; allele=A/G; support1=37; support2=13;
	# chr1    SoapSNP SNP     774913  774913  74      +       .       ID=rs2905062; status=dbSNP; ref=G; allele=A/A; support1=26; location=MSTD:LTR/MaLR;
	# chr1    SoapSNP SNP     775852  775852  93      +       .       ID=rs2980300; status=dbSNP; ref=T; allele=C/C; support1=29;
	# chr1    SoapSNP SNP     777262  777262  43      +       .       ID=rs2905055; status=dbSNP; ref=G; allele=T/T; support1=12;
	# Create the attributes hash

	# Assign the reference and variant sequences:
	# reference_sequence=A
	# variant_sequence=G
	my $reference_sequence = $original_atts->{ref}[0];
	my @variant_sequences  = split m|/|, $original_atts->{allele}[0];

	shift @variant_sequences if $variant_sequences[0] eq $variant_sequences[1];

	# Assign the reference and variant sequence read counts:
	# reference_reads=A:7
	# variant_reads=G:8

	my $support1 = (ref $original_atts->{support1} eq 'ARRAY' ?
			$original_atts->{support1}[0]             :
			0
		       );
	my $support2 = (ref $original_atts->{support2} eq 'ARRAY' ?
			$original_atts->{support2}[0]             :
			0
		       );

	my @variant_reads = ($support_1, $support_2);

	# Assign the total number of reads covering this position:
	# total_reads=16

	my $total_reads = $support1 + $support2;

	# Assign the genotype:
	# genotype=homozygous

	my $genotype = scalar @variant_sequences > 1 ? 'heterozygous' : 'homozygous';

	# Assign the probability that the genotype call is correct:
	# genotype_probability=0.667

	# Any quality score given for this variant should be assigned
	# to $score above (column 6 in GFF3).  Here you can assign a
	# name for the type of score or algorithm used to calculate
	# the sscore (e.g. phred_like, clcbio, illumina).
	# score_type=soap

	# Create the attribute hash reference.  Note that all values
	# are array references - even those that could only ever have
	# one value.  This is for consistency in the interface to
	# Features.pm and it's subclasses.  Suggested keys include
	# (from the GFF3 spec), but are not limited to: ID, Name,
	# Alias, Parent, Target, Gap, Derives_from, Note, Dbxref and
	# Ontology_term. Note that attribute names are case
	# sensitive. "Parent" is not the same as "parent". All
	# attributes that begin with an uppercase letter are reserved
	# for later use. Attributes that begin with a lowercase letter
	# can be used freely by applications.

	# For sequence_alteration features the suggested keys include:
	# reference_sequence, variant_sequence, reference_reads, variant_reads
	# total_reads, genotype, genotype_probability and score type.
	my $attributes = {Reference_seq => [$reference_sequence],
			  Variant_seq   => \@variant_sequences,
			  Variant_reads => \@variant_reads,
			  Total_reads      => [$total_reads],
			  Genotype         => [$genotype],
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

<GAL::Parser::soap_snp> requires no configuration files or environment variables.

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
