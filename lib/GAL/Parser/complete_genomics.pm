package GAL::Parser::complete_genomics;

use strict;
use vars qw($VERSION);

$VERSION = '0.01';
use base qw(GAL::Parser);

=head1 NAME

GAL::Parser::complete_genomics - <One line description of module's purpose here>

=head1 VERSION

This document describes GAL::Parser::complete_genomics version 0.01

=head1 SYNOPSIS

     use GAL::Parser::complete_genomics;

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

=head2

     Title   : new
     Usage   : GAL::Parser::complete_genomics->new();
     Function: Creates a GAL::Parser::complete_genomics object;
     Returns : A GAL::Parser::complete_genomics object
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

	$self->SUPER::_initialize_args(@args);

	my $args = $self->prepare_args(@args);

	my @valid_attributes = qw();

	$self->fields([qw(locus haplotype contig begin end vartype reference alleleSeq totalScore hapLink)]);

	$self->set_attributes($args, @valid_attributes);

}

#-----------------------------------------------------------------------------

=head2 _parse_all_features

 Title   : _parse_all_features
 Usage   : $a = $self->_parse_all_features();
 Function: Parse and store all of the features in a file
 Returns : N/A
 Args    : N/A

=cut

sub _parse_all_features {

	my $self = shift;

	while (my $record = $self->_read_next_record) {

		my $feature_hash = $self->parse_record($record);
		next unless defined $feature_hash;
		my $type = $feature_hash->{type};
		my $feature = $self->feature_factory->create($feature_hash);
		push @{$self->{features}}, $feature;

		}
	return $self;
}

#-----------------------------------------------------------------------------

=head2 parse_next_feature

 Title   : parse_next_feature
 Usage   : $a = $self->parse_next_feature();
 Function: Get/Set the value of parse.
 Returns : The value of parse.
 Args    : A value to set parse to.

=cut

sub parse_next_feature {

	my $self = shift;


	my (@records, @stack);
      OUTER:
	while (my $record1 = pop @stack || $self->_read_next_record) {

		# A hack to skip over junk we don't want like this:
		# contig,begin,end,ploidy
		# chr1,44045,44254,2
		next unless $record1->{vartype};

		# Skip over headers (vartype), non-variants (=), and 
		# ambiguous data (no-call).
		next if $record1->{vartype} =~ /=|no-call|vartype/;

		push @records, $record1;

		my $locus1 = $record1->{locus};
	      INNER:
		while (my $record_add = $self->_read_next_record) {
			$self->throw() unless $record_add->{vartype};
			my $locus_add = $record_add->{locus};
			if ($locus1 ne $locus_add) {
				push @stack, $record_add;
				last INNER;
			}
			next if $record_add->{vartype} =~ /=|no-call|vartype/;
			push @records, $record_add;
		}
		# Ignore variants that have more than two alleles
		if (scalar @records > 2) {
			@records = ();
			next OUTER;
		}
	}

	return undef unless scalar @records;

	# Detect inconsistant data
	for my $record (@records) {
		if (grep {$record->{locus}     ne $_->{locus}}     @records ||
		    grep {$record->{contig}    ne $_->{contig}}    @records ||
		    grep {$record->{begin}     ne $_->{begin}}     @records ||
		    grep {$record->{end}       ne $_->{end}}       @records ||
		    grep {$record->{reference} ne $_->{reference}} @records
		   ) {
			$self->throw(message => ("Inconsistant data in a " .
						 "record group.  You may " .
						 "have found a bug in "    .
						 "GAL::Parser::complete_genomics"
						)
				    );
		}
	}

	my $feature_hash = $self->parse_record(@records);
	return undef unless defined $feature_hash;
	my $type = $feature_hash->{type};
	my $feature = $self->feature_factory->create($feature_hash);

	return $feature;
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
	my ($self, @records) = @_;

	# $record is a hash reference that contains the keys assigned
	# in the $self->fields call in _initialize_args above

	my $var_record = shift @records;
	my $alt_record = shift @records;

	# locus,haplotype,contig,begin,end,vartype,reference,alleleSeq,totalScore,hapLink
	# 1,1,chr1,485,496,=,GCCCGCCCGCC,GCCCGCCCGCC,27,

	# Fill in the first 8 columns for GFF3
	# See http://www.sequenceontology.org/resources/gff3.html for details.
	my $id         = sprintf ('CG_%.6x', $var_record->{locus});
	my $seqid      = $var_record->{contig};
	my $source     = 'Complete_Genomics';

	my %type_map = (snp => 'SNP',
			inv => 'inversion',
			ins => 'nucleotide_insertion',
			del => 'nucleotide_deletion',
		       );

	my $type       = $type_map{$var_record}
	my $start      = $record->{start};
	my $end        = $record->{end};
	my $score      = '.';
	my $strand     = $record->{strand};
	my $phase      = '.';

	$seqid = ($seqid eq 'PAR1' || $seqid eq 'chrXnonPAR') ? 'chrX' : $seqid;
	$seqid = ($seqid eq 'PAR2' || $seqid eq 'chrYnonPAR') ? 'chrY' : $seqid;

	# Create the attributes hash

	# Assign the reference and variant allele sequences:
	# reference_allele=A
	# variant_allele=G
	my ($reference_allele, @variant_alleles) = split m|/|, $record->{alleles};

	# Assign the reference and variant allele read counts:
	# my $reference_reads=A:7
	# my $variant_reads=G:8

	# Assign the total number of reads covering this position:
	# my $total_reads=16

	# Assign the genotype:
	# my $genotype=homozygous

	# Assign the probability that the genotype call is correct:
	# my $genotype_probability=0.667

	my ($genotype, $variant_type) = $record->{variant_type} =~ /(.*?)_(.*)/;

	# Any quality score given for this variant should be assigned
	# to $score above (column 6 in GFF3).  Here you can assign a
	# name for the type of score or algorithm used to calculate
	# the sscore (e.g. phred_like, clcbio, illumina).
	my $score_type = 'complete_genomics';

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
	# reference_allele, variant_allele, reference_reads, variant_reads
	# total_reads, genotype, genotype_probability and score type.
	my $attributes = {reference_allele => [$reference_allele],
			  variant_allele   => \@variant_alleles,
			  genotype         => [$genotype],
			  score_type       => [$score_type],
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

<GAL::Parser::complete_genomics> requires no configuration files or environment variables.

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
