package GAL::Schema::Result::Feature;

use strict;
use warnings;
use base qw/DBIx::Class/;

#BEGIN {

  # Map feature types to a parent that has an subclass.
  my %FEATURE_MAP = (gene            => 'gene',
		     transcript      => 'transcript',
		     mRNA            => 'mrna',
		     exon            => 'exon',
		     intron          => 'intron',
		     three_prime_UTR => 'three_prime_utr',
		     five_prime_UTR  => 'five_prime_utr',
		    );

  # Eventually get this from SO at runtime.
  my @sequence_alterations = qw(copy_number_variation deletion indel
				insertion duplication tandem_duplication
				transgenic_insertion inversion substitution
				MNP SNV SNP point_mutation transition
				purine_transition A_to_G_transition
				G_to_A_transition pyrimidine_transition
				C_to_T_transition T_to_C_transition transversion
				purine_to_pyrimidine_transversion
				A_to_C_transversion A_to_T_transversion
				G_to_C_transversion G_to_T_transversion
				pyrimidine_to_purine_transversion
				C_to_A_transversion C_to_G_transversion
				T_to_A_transversion T_to_G_transversion
				complex_substitution sequence_length_variation
				simple_sequence_length_variation translocation);
  map {$FEATURE_MAP{$_} = 'sequence_alteration'} @sequence_alterations;


=head1 NAME

GAL::Schema::Result::Feature - <One line description of module's purpose here>

=head1 VERSION

This document describes GAL::Schema::Result::Feature version 0.01

=head1 SYNOPSIS

     use GAL::Schema::Result::Feature;

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

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('feature');
__PACKAGE__->add_columns(qw/ subject_id feature_id seqid source type start end score strand phase bin/);
__PACKAGE__->set_primary_key('feature_id');
__PACKAGE__->has_many(attributes   => 'GAL::Schema::Result::Attribute', 'feature_id');
__PACKAGE__->has_many(my_parents  => 'GAL::Schema::Result::Relationship', {'foreign.child' => 'self.feature_id'});
__PACKAGE__->has_many(my_children => 'GAL::Schema::Result::Relationship', {'foreign.parent'  => 'self.feature_id'});
__PACKAGE__->many_to_many(parents  => 'my_parents', 'your_parents');
__PACKAGE__->many_to_many(children => 'my_children', 'your_children');

#-----------------------------------------------------------------------------

sub inflate_result {
	my $self = shift;
	my $feature = $self->next::method(@_);

	my $subtype = $FEATURE_MAP{$feature->type} || 'sequence_feature';

	if ($subtype) {
		my $subclass = __PACKAGE__ . '::' . $subtype;
		$self->ensure_class_loaded($subclass);
		bless $feature, $subclass;
	}

	return $feature;
}

#-----------------------------------------------------------------------------

sub feature_bins {

    my $self = shift;

    my ($seqid, $start, $end) = ($self->seqid, $self->start, $self->end);
    my @feature_bins;
    my $count;
    my $single_bin;
    for my $bin_size (128_000, 1_000_000, 8_000_000, 64_000_000,
		      512_000_000) {
      $count++;
      my $start_bin = int($start/$bin_size);
      my $end_bin   = int($end/$bin_size);
      my @these_bins = map {$_ = join ':', ($seqid, $count, $_)} ($start_bin .. $end_bin);
	if (! $single_bin && scalar @these_bins == 1) {
	    $single_bin = shift @these_bins;
	}
	unshift @feature_bins, @these_bins;
    }
    unshift @feature_bins, $single_bin;
    return wantarray ? @feature_bins : \@feature_bins;
}

#-----------------------------------------------------------------------------

sub annotation {
  return shift->result_source->schema->annotation;
}

#-----------------------------------------------------------------------------

sub seq {
  my $self = shift;

  my $seq = $self->annotation->fasta->seq($self->seqid,
					  $self->start,
					  $self->end
					 );
  $seq = $self->annotation->revcomp($seq) if $self->strand eq '-';
  return $seq;
}

#-----------------------------------------------------------------------------

sub genomic_seq {
  my $self = shift;

  my $seq = $self->annotation->fasta->seq($self->seqid,
					  $self->start,
					  $self->end
					 );
  return $seq;
}

#-----------------------------------------------------------------------------

sub length {
  my $self = shift;

  return ($self->end - $self->start) + 1;
}

#-----------------------------------------------------------------------------

sub genomic_length {
  my $self = shift;

  return $self->end - $self->start;
}

#-----------------------------------------------------------------------------

=head2 attributes

 Title   : attributes_hash
 Usage   : $self->attributes_hash();
 Function: 
 Returns : 
 Args    : 

=cut

sub attributes_hash {
  my $self = shift;

  if (! $self->{my_attributes}) {
    map {push @{$self->{my_attributes}{$_->att_key}}, $_->att_value}
	   $self->attributes->all;
  }
  return $self->{my_attributes}
}

#-----------------------------------------------------------------------------

=head2 attribute_value

 Title   : attribute_value
 Usage   : $self->attribute_value($tag);
 Function: 
 Returns : 
 Args    : 

=cut

sub attribute_value {
  my ($self, $tag) = @_;

  my $attributes = $self->attributes_hash;
  my $values = [];
  if (exists $attributes->{$tag}) {
    $values = $attributes->{$tag};
  }
  return wantarray ? @{$values} : $values;
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

<GAL::Schema::Result::Feature> requires no configuration files or environment variables.

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
