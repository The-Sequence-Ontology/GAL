package GAL::Parser::samtools_pileup;

use strict;
use vars qw($VERSION);


$VERSION = '0.01';
use base qw(GAL::Parser);

=head1 NAME

GAL::Parser::samtools_pileup - <One line description of module's purpose here>

=head1 VERSION

This document describes GAL::Parser::samtools_pileup version 0.01

=head1 SYNOPSIS

     use GAL::Parser::samtools_pileup;

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
     Usage   : GAL::Parser::samtools_pileup->new();
     Function: Creates a GAL::Parser::samtools_pileup object;
     Returns : A GAL::Parser::samtools_pileup object
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
	$self->fields([qw(seqid start reference_seq variant_seq
			  consensus_phred_qual snv_phred_qual rms
			  variant_reads read_qual aln_map_qual)]);

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


	# This parser was written to convert variant output created
	# with SAMtools like this:

	# From a sorted BAM alignment, raw SNP and indel calls are acquired by:
	#
	# 1. samtools pileup -vcf ref.fa aln.bam > raw.pileup
	# 
	# samtools pileup -vcf ref.fa aln.bam > raw.pileup The resultant output
	# should be further filtered by:
	# 
	# 1. samtools.pl varFilter raw.pileup | awk '$6>=20' > final.pileup  
	# 
	# samtools.pl varFilter raw.pileup | awk '$6>=20' > final.pileup to rule
	# out error-prone variant calls caused by factors not considered in the
	# statistical model.

	# With output that looks like this

	# chr1  10109  a  W  79  79   60  31  .$...t,.T.t,,tt.,tt..,,ttT,,,t,t  %%%%BB%%%ACC@=BB..%9AB<9>A'B9%7
	# chr1	10177  a  C  18  33   60  3   c,C     		      		53@       
	# chr1	13116  T  G  11  39   60  6   g.GgG,  		      		B39A>1
	# chr1	13118  A  G  8   39   60  6   g.GgG,  		      		B?;AA(
	# chr1	14464  A  W  22  41   60  5   t,Tt.   		      		AA@9A
	# chr1	14653  C  T  28  36   60  4   .TtT    		      		%>%>            
	# chr1	14907  A  R  85  147  60  18  ,,,g,.gGGGGggG.g^~G^~g  		ACB5BB7>@BB3>@<:A%
	# chr1	14930  A  R  27  99   60  19  g,.gGGGGggG.gGg.ggg?    		BB<AB@<5@B6BA=A4=1
	# chr1	15208  G  A  6   27   60  4   ,aa,    		      		>AB%
	# chr1	15211  T  G  39  39   60  4   gggg    		      		>@B@            

	# With columns described as this:

	# http://samtools.sourceforge.net/samtools.shtml  See both main pileup
	# docs and the details for the -c option.
	# 1.  chromosome name
	# 2.  coordinate
	# 3.  reference base
	# 4.  consensus base
	# 5.  Phred-scaled consensus quality
	# 6.  SNP quality (i.e. the Phred-scaled probability of the consensus
	#     being identical to the reference)
	# 7.  root mean square (RMS) mapping quality of the reads covering
	#     the site
	# 8.  read bases
	# 9.  read qualities
	# 10. alignment mapping qualities
	
	# Mapped to record keys:

	# 1.  seqid
	# 2.  start
	# 3.  reference_seq
	# 4.  variant_seq
	# 5.  consensus_phred_qual
	# 6.  snv_phred_qual
	# 7.  rms
	# 8.  variant_reads
	# 9.  read_qual
	# 10. aln_map_qual

	my $seqid      = $record->{seqid};
	my $source     = 'SAMtools';
	my $type       = 'SNV';
	my $start      = $record->{start};
	my $id         = join ':', ($seqid, $source, $type, $start);
	my $end        = $record->{start};
	my $score      = $record->{consensus_phred_qual};
	my $strand     = '+';
	my $phase      = '.';

	# Create the attributes hash
	# See http://www.sequenceontology.org/gvf.html

	my $reference_seq = uc $record->{reference_seq};
	my @variant_seqs  = $self->expand_iupac_nt_codes($record->{variant_seq});

	my $total_reads = $record->{variant_reads};

	my $genotype = scalar @variant_seqs == 1 ? 'homozygous' : 'heterozygous';

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
	# ID, Reference_seq, Variant_seq, Variant_reads Total_reads,
	# Genotype, Intersected_feature, Variant_effect, Copy_number

	my $attributes = {Reference_seq => [$reference_seq],
			  Variant_seq   => \@variant_seqs,
			  Total_reads   => [$total_reads],
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

<GAL::Parser::samtools_pileup> requires no configuration files or environment variables.

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
