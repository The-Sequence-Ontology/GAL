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

=head2 new

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

    ######################################################################
    # This block of code handels class attributes.  Use the
    # @valid_attributes below to define the valid attributes for
    # this class.  You must have identically named get/set methods
    # for each attribute.  Leave the rest of this block alone!
    ######################################################################
    my $args = $self->SUPER::_initialize_args(@args);
    my @valid_attributes = qw(); # Set attributes here.
    $self->set_attributes($args, @valid_attributes);
    ######################################################################

    # Set the column headers from your incoming data file here
    # These will become the keys in your $record hash reference below.
    $self->fields([qw(locus haplotype contig begin end vartype reference alleleSeq totalScore hapLink xRef)]);
    $self->field_separator(',');
    $self->comment_delimiter(qr/^[^\d]/);
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
    
    return undef unless $record->{locus} =~ /^\d+$/;
    
    # locus,haplotype,contig,begin,end,vartype,reference,alleleSeq,totalScore,hapLink,xRef
    # 14,1,chr1,26241,26252,=,AAGAATTTAAA,AAGAATTTAAA,30,349,
    # 14,1,chr1,26252,26252,ref-consistent,,?,,349,
    # 14,1,chr1,26252,26259,=,TTATAAA,TTATAAA,32,349,
    # 14,2,chr1,26241,26259,ref-consistent,AAGAATTTAAATTATAAA,?,,350,
    # 15,1,chr1,26263,26264,=,T,T,22,349,
    # 15,2,chr1,26263,26264,ref-consistent,T,N,91,350,
    
    my $id         = sprintf 'CG_%09d', $record->{locus};
    my $seqid      = $record->{contig};
    my $source     = 'Complete_Genomics';
    
    my $type = $record->{vartype};
    my $has_ref_seq;
    $has_ref_seq++ if $types{'='};
    
    # snp: single-nucleotide polymorphism
    # ins: insertion
    # del: deletion
    # inv: inversion
    # sub: substitution of one or more reference bases with the
    #     bases in the allele column ref no variation; the sequence is
    #     identical to the reference sequence on the indicated
    #     haplotype
    # no-call-rc: “no-call reference consistent “one or more bases
    #     are ambiguous, but the allele is potentially consistent with
    #     the reference no-call-ri “no-call reference inconsistent”
    #     one or more bases are ambiguous, but the allele is
    #     definitely inconsistent with the reference
    # no-call: an allele is completely indeterminate in length and
    #     composition, i.e. alleleSeq = ‘?’
    # no-ref: the reference sequence is unspecified at this locus.
    # PAR-called-in-X: this locus overlaps one of the
    #     pseudoautosomal regions on the sex chromosomes. The called
    #     sequence is reported as diploid sequence on Chromosome X; on
    #     chromosome Y the sequence is reported as varType = “PAR-
    #     called-in-X”.
    
    my %type_map = ('snp'		  => 'SNV',
		    'ins'		  => 'nucleotide_insertion',
		    'del'		  => 'nucleotide_deletion',
		    'inv'	          => 'inversion',
		    'sub'             => 'sequence_alteration',
		    'ref'             => 'reference',
		    '='               => 'reference',
		    'no-call-rc'	  => 'no_call',
		    'no-call-rc'	  => 'no_call',
		    'no-call-ri'	  => 'no_call',
		    'no-call'	  => 'no_call',
		    'no-ref'          => 'no_call',
		    'PAR-called-in-X' => 'unknown',
		    );
    
    $type = $type_map{$type} || 'sequence_alteration';
    
    my $start      = $record->{begin} + 1;
    my $end        = $record->{end};
    my $score      = $record->{totalScore};
    my $strand     = '+';
    my $phase      = '.';
    
    my $reference_seq = $record->{reference} || '-';
    my %variant_hash  = map {$_ => 1} ($record->{seq1}, $record->{seq2});
    $variant_hash{$reference_seq}++ if $has_ref_seq;
    my @variant_seqs = map {$_ ||= '-'} keys %variant_hash;
    
    my $genotype = scalar @variant_seqs > 1 ? 'heterozygous' : 'homozygous';
    
    my $attributes = {Reference_seq => [$reference_seq],
		      Variant_seq   => \@variant_seqs,
		      Genotype         => [$genotype],
		      ID               => [$id],
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

=head2 next_feature_hash

 Title   : next_feature_hash
 Usage   : $a = $self->next_feature_hash;
 Function: Return the next record from the parser as a 'feature hash'.
 Returns : A hash or hash reference.
 Args    : N/A

=cut

sub next_feature_hash {
    my $self = shift;
    
    my $feature;
    
    # If a previous record has returned multiple features then
    # grab them off the stack first instead of reading a new one
    # from the file.
    if (ref $self->{_feature_stack} eq 'ARRAY' &&
	scalar @{$self->{_feature_stack}} > 0) {
	$feature = shift @{$self->{_feature_stack}};
	return wantarray ? %{$feature} : $feature;
    }
    
    # Allow parse_record to return undef to ignore a record, but
    # still keep parsing the file.
    until ($feature) {
	# Get the next record from the file.
	my $record = $self->_read_next_record;
	return undef if ! defined $record;
	
	# Parser the record - probably overridden by a subclass.
	$feature = $self->parse_record($record);
    }
    
    # Allow parsers to return more than one feature.
    # This allows the parser to expand a single record into
    # multiple features.
    if (ref $feature eq 'ARRAY') {
	my $this_feature = shift @{$feature};
	push @{$self->{_feature_stack}}, @{$feature};
	$feature = $this_feature;
    }
    
    return wantarray ? %{$feature} : $feature;
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
