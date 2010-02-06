package GAL::Parser::illumina_indel;

use strict;
use vars qw($VERSION);


$VERSION = '0.01';
use base qw(GAL::Parser);

=head1 NAME

GAL::Parser::illumina_indel - <One line description of module's purpose here>

=head1 VERSION

This document describes GAL::Parser::illumina_indel version 0.01

=head1 SYNOPSIS

     use GAL::Parser::illumina_indel;

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
     Usage   : GAL::Parser::illumina_indel->new();
     Function: Creates a illumina_indel object;
     Returns : A illumina_indel object
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

	$self->fields([qw(transcript_id chromosome location total_reads allele context1
			  context2 genotype gene_name gene_part)]);
}

#-----------------------------------------------------------------------------

=head2 parse_record

 Title   : parse_record
 Usage   : $a = $self->parse_record();
grep {$_ ne $reference_allele} Function: Parse the data from a record.
 Returns : A hash ref needed by Feature.pm to create a Feature object
 Args    : A hash ref of fields that this sub can understand (In this case GFF3).

=cut

sub parse_record {
	my ($self, $record) = @_;

	# Create the attributes hash

	# N/A chr1 713662 13 -2:AG    AGGGAGAGAGAAAGGAAGAGACGATGAGAGAC AGAGAGAAGGAGAGAGAAAGTACAAAAGAACG	HET Non_genic Other
	# N/A chr1 714130 49  5:GAATG TGGAACGCACTCGAATGGAATGGAACGGACAT GAATGGAATGGAATGGAACGGACACGAATGGA	HET Non_genic Other
	# N/A chr1 715647 78 -2:AG    TAATGGAATGGACTTGAATGGAATAGAATGGA AGAGACTCGAATGGAATGGAATGCAATGGAAT	HET Non_genic Other
	# N/A chr1 780560 13  2:AT    TACGGGTGTATCTGTGTATTGTGTATGCACAC ACGAGCATATGTGTACATGAATTTGTATTGCA	HET Non_genic Other
	# N/A chr1 780622 27 -2:TA    CACATGTGTTTAATGCGAACACGTGTCATGTG TATGTGTTCACATGCATGTGTGTCTGTGTACT	HET Non_genic Other
	# N/A chr1 794457 9  -1:A     TGCTGTGACAAAAAAGCAGGGAAAGGGAATTT AAAAAAAAAAAAGCAAACAACAACAACAAAAA	HET Non_genic Other
	# N/A chr1 805541 10 -1:G     GTTAGCTGTGTTTTTTGTTGTTGTTGTTTTTT GGGGTTTTTTTTGTATAACATTATGTTAAGGT	HET Non_genic Other
	# N/A chr1 806031 30 -1:T     CAGTGTAGCCATCTGGTCCAGGCTTTTCTTTG TTGCTGGGTTTTTTATTACTGATGCAATCTTC	HET Non_genic Other
	# N/A chr1 806276 26 -1:T     TTATTTTTGAGTTTGGTAATTTGAGTATTCCC TTTTTTTCTTAGTCAATCTAGATAAAATTTTG	HET Non_genic Other
	# N/A chr1 806790 32  1:C     TGTATCAACATTTGTTGTGTTCTCATAAACTT TGTAATACATGGAGATTTCTGGTCCACATATG	HET Non_genic Other

	# $self->fields([qw(transcript_id chromosome location total_reads allele context1
	#                   context2 genotype gene_name gene_part)]);

	my ($allele_size, $allele) =  split /:/, $record->{allele};

	my $seqid      = $record->{chromosome};
	my $source     = 'Illumina_GA';
	my $type       = $allele_size < 0 ? 'nucleotide_deletion' : 'nucleotide_insertion';
	my $start      = $allele_size < 0 ? $record->{location} : $record->{location} - 1;
	my $end        = $allele_size < 0 ? $record->{location} - $allele_size - 1 : $record->{location} - 1;
	my $score      = '.';
	my $strand     = '+';
	my $phase      = '.';

	my $id = join ":", ($source,
			    $type,
			    $seqid,
			    $start,
			    $end,
			   );

	my $reference_allele = $allele_size < 0 ? $allele : '-';
	my @variant_alleles;
	if ($record->{genotype} eq 'HET') {
		push @variant_alleles, ($allele_size < 0 ? $allele : '-')
	}
	else {
		push @variant_alleles, ($allele_size < 0 ? '-'     : $allele);
	}

	my $total_reads = $record->{total_reads};

	my $genotype = $record->{genotype} eq 'HET' ? 'heterozygous' : 'homozygous';

	my $intersected_gene;
	$intersected_gene = $record->gene_name ne 'Non_genic' ? 'gene:HGNC:' . $record->gene_name : undef;

	#perl -lane 'print $F[9] unless $F[9] eq "Other"' KOREF-solexa-indel-X30_d3D50E20.gff | sort | uniq -c | sort -nr
	#  127516 Intron
	#     319 3UTR
	#      49 CDS
	#      27 5UTR

	my %type_map = {Intron => 'intron',
			3UTR   => 'three_prime_UTR',
			CDS    => 'CDS',
			5UTR   => 'five_prime_UTR',
			Other  =>  undef,
		       };

	my $intersected_gene_part;
	$intersected_gene_part = $record->{gene_part};

	my @intersected_features;

	push @intersected_features, $intersected_gene      if $intersected_gene;
	push @intersected_features, $intersected_gene_part if $intersected_gene_part;

	my $attributes = {Reference_allele => [$reference_allele],
			  Variant_allele   => \@variant_alleles,
			  Total_reads      => [$total_reads],
			  Genotype         => [$genotype],
			  ID               => [$id],
			 };

	$attributes{Intersected_feature} = \@intersected_features if scalar @intersected_features;

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

<GAL::Parser::illumina_indel> requires no configuration files or environment variables.

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
