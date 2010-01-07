package GAL::Parser::dbsnp_flat;

use strict;
use vars qw($VERSION);


$VERSION = '0.01';
use base qw(GAL::Parser);

=head1 NAME

GAL::Parser::template - <One line description of module's purpose here>

=head1 VERSION

This document describes GAL::Parser::template version 0.01

=head1 SYNOPSIS

     use GAL::Parser::template;

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
     Usage   : GAL::Parser::template->new();
     Function: Creates a GAL::Parser::template object;
     Returns : A GAL::Parser::template object
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
	$self->record_separator("\n\n");
	$self->field_separator(undef);
	# $self->comment_delimiter(qr/^[^\d]/);
	$self->fields([qw(data)]);

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

	my $record = _parse_dbsnp_flat($record->{data});

	# $record is a hash reference that contains the keys assigned
	# in the $self->fields call in _initialize_args above

	# Fill in the first 8 columns for GFF3
	# See http://www.sequenceontology.org/resources/gff3.html for details.
	my $id         = $record->{id};
	my $seqid      = $record->{chromosome};
	my $source     = 'Template';
	my $type       = 'SNP';
	my $start      = $record->{start};
	my $end        = $record->{end};
	my $score      = '.';
	my $strand     = $record->{strand};
	my $phase      = '.';

	# Create the attributes hash

	# Assign the reference and variant allele sequences:
	# reference_allele=A
	# variant_allele=G
	my ($reference_allele, @variant_alleles) = split m|/|, $record->{alleles};

	# Assign the reference and variant allele read counts:
	# reference_reads=A:7
	# variant_reads=G:8

	# Assign the total number of reads covering this position:
	# total_reads=16

	# Assign the genotype:
	# genotype=homozygous

	# Assign the probability that the genotype call is correct:
	# genotype_probability=0.667

	my ($genotype, $variant_type) = $record->{variant_type} =~ /(.*?)_(.*)/;

	# Any quality score given for this variant should be assigned
	# to $score above (column 6 in GFF3).  Here you can assign a
	# name for the type of score or algorithm used to calculate
	# the sscore (e.g. phred_like, clcbio, illumina).
	my $score_type = 'template';

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

=head2 _parse_dbsnp_flat

 Title   : _parse_dbsnp_flat
 Usage   : $record = $self->_parse_dbsnp_flat($record->{data});
 Function: Parses one record from a dbSNP ASN1 flatfile format.
 Returns : Returns a hashref in a format more typical of GAL/Parser subclasses
 Args    : The data from one record in a dbSNP ASN1 flat file

=cut

sub _parse_dbsnp_flat {
	my ($self, $data) = @_;

	# rs241 | human | 9606 | snp | genotype=YES | submitterlink=YES | updated 2009-02-15 06:31
	# ss241 | KWOK | D10S1188 | orient=+ | ss_pick=NO
	# ss818 | WIAF | WIAF-4209 | orient=+ | ss_pick=NO
	# ss19405 | WIAF | WIAF-4519 | orient=+ | ss_pick=NO
	# SNP | alleles='A/C' | het=0.5 | se(het)=0.0287
	# VAL | validated=YES | min_prob=? | max_prob=? | notwithdrawn | byCluster | byFrequency | by2Hit2Allele | byHapMap
	# CTG | assembly=Celera | chr=10 | chr-pos=71729080 | NW_924796.1 | ctg-start=25923323 | ctg-end=25923323 | loctype=2 | orient=-
	# CTG | assembly=HuRef | chr=10 | chr-pos=72439347 | NW_001837987.2 | ctg-start=3016811 | ctg-end=3016811 | loctype=2 | orient=+
	# CTG | assembly=reference | chr=10 | chr-pos=78114462 | NT_008583.16 | ctg-start=26995611 | ctg-end=26995611 | loctype=2 | orient=-

	my @lines = split /\n/, $data;
	chomp @lines;

	my $this_assembly = $self->assembly;

	my ($assembly, $chromosome, $start, $contig, $contig_start, $contig_end,
	    $loctype, $strand, $alleles, $heterozygosity, $std_error_heterozygosity,
	    $id, $common, $tax_id, $type, $genotype, $submitter, $update);

	my %record;
	for my $line (@lines) {
		my ($head, @fields) = split /\s*|\s*/, $line;
		if ($head eq 'CTG') {
			next unless $fields[0] eq "assembly=$this_assembly";
			($assembly, $chromosome, $start, $contig, $contig_start,
			 $contig_end, $loctype, $strand) = @fields;
			$assembly  =~ s/assembly=//;
			$chomosome =~ s/chr=//;
			$start     =~ s/chr-pos=//;
			$contig    =~ 
		}
		elsif ($head eq 'SNP') {
			($alleles, $heterozygosity,
			 $std_error_heterozygosity) = @fields;
		}
		if ($head =~ /^rs\d+/) {
			($id, $common, $tax_id, $type, $genotype,
			 $submitter, $update) = ($head, @fields);
		}
	}


	return \%record;
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

<GAL::Parser::template> requires no configuration files or environment variables.

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
