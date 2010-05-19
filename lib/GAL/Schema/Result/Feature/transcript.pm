package GAL::Schema::Result::Feature::transcript;

use strict;
use warnings;
use base qw(GAL::Schema::Result::Feature::sequence_feature);

=head1 NAME

GAL::Schema::Result::Feature::transcript - <One line description of module's purpose here>

=head1 VERSION

This document describes GAL::Schema::Result::Feature::transcript version 0.01

=head1 SYNOPSIS

     use GAL::Schema::Result::Feature::transcript;

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

sub exons {

  my $self = shift;

  my $exons = $self->children->search({type => 'exon'},
				      {order_by => { -asc => 'start' }});
  return wantarray ? $exons->all : $exons;

}

#-----------------------------------------------------------------------------

sub introns {

  my $self = shift;

  my $introns = $self->children->search({type => 'intron'},
					{order_by => { -asc => 'start' }});
  return wantarray ? $introns->all : $introns;

}

#-----------------------------------------------------------------------------

sub three_prime_UTRs {

  my $self = shift;

  my $three_prime_UTRs = $self->children->search({type => 'three_prime_UTR'},
						 {order_by => { -asc => 'start' }});
  return wantarray ? $three_prime_UTRs->all : $three_prime_UTRs;

}

#-----------------------------------------------------------------------------

sub five_prime_UTRs {

  my $self = shift;

  my $five_prime_UTRs = $self->children->search({type => 'five_prime_UTR'},
						{order_by => { -asc => 'start' }});
  return wantarray ? $five_prime_UTRs->all : $five_prime_UTRs;

}

#-----------------------------------------------------------------------------

sub mature_transcript_seq_genomic {

  my $self = shift;

  my $mature_transcript_seq_genomic;
  map {$mature_transcript_seq_genomic .= $_->genomic_seq} $self->exons->all;
  return $mature_transcript_seq_genomic;
}

#-----------------------------------------------------------------------------

sub mature_transcript_seq {

  my $self = shift;

  my $mature_transcript_seq = $self->mature_transcript_seq_genomic;
  if ($self->strand eq '-') {
    $mature_transcript_seq =
      $self->annotation->revcomp($mature_transcript_seq);
  }
  return $mature_transcript_seq;
}

#-----------------------------------------------------------------------------

sub five_prime_UTR_seq_genomic {

  my $self = shift;

  my $five_prime_UTR_seq_genomic;
  map {$five_prime_UTR_seq_genomic .= $_->genomic_seq} $self->five_prime_UTRs->all;
  return $five_prime_UTR_seq_genomic;
}

#-----------------------------------------------------------------------------

sub five_prime_UTR_seq {

  my $self = shift;

  my $five_prime_UTR_seq = $self->five_prime_UTR_seq_genomic;
  if ($self->strand eq '-') {
    $five_prime_UTR_seq =
      $self->annotation->revcomp($five_prime_UTR_seq);
  }
  return $five_prime_UTR_seq;
}

#-----------------------------------------------------------------------------

sub three_prime_UTR_seq_genomic {

  my $self = shift;
  my $three_prime_UTR_seq_genomic;
  map {$three_prime_UTR_seq_genomic .= $_->genomic_seq} $self->three_prime_UTRs->all;
  return $three_prime_UTR_seq_genomic;
}

#-----------------------------------------------------------------------------

sub three_prime_UTR_seq {

  my $self = shift;

  my $three_prime_UTR_seq = $self->three_prime_UTR_seq_genomic;
  if ($self->strand eq '-') {
    $three_prime_UTR_seq =
      $self->annotation->revcomp($three_prime_UTR_seq);
  }
  return $three_prime_UTR_seq;
}

#-----------------------------------------------------------------------------

sub coordinate_map {

  my $self = shift;

  if (! $self->{coordinate_map}) {
    my $strand = $self->strand;
    my $length = $self->length;
    my %coordinate_map;
    my @exons = $self->exons->all;
    my ($transcript_position, $increment);
    if ($strand eq '-') {
      $transcript_position = $length - 1;
      $increment = -1;
    }
    else {
      $transcript_position = 1;
      $increment = 1;
    }
    for my $exon (@exons) {
      my $start = $exon->start;
      my $end   = $exon->end;
      for my $genomic_position ($start .. $end) {
	$coordinate_map{genome2me}{$genomic_position}    = $transcript_position;
	$coordinate_map{me2genome}{$transcript_position} = $genomic_position;
	$transcript_position += $increment;
      }
    }
    $self->{coordinate_map} = \%coordinate_map;
  }
  return $self->{coordinate_map};
}

#-----------------------------------------------------------------------------

sub map2me {

  my ($self, @coordinates) = @_;

  my $coordinate_map = $self->coordinate_map;
  my @my_coordinates;
  for my $coordinate (@coordinates) {
    push @my_coordinates, $coordinate_map->{genome2me}{$coordinate};
  }
  return wantarray ? @my_coordinates : \@my_coordinates;
}

#-----------------------------------------------------------------------------

sub length {

  my $self = shift;

  my $length;
  map {$length += $_->length} $self->exons->all;
  $length++;
  return $length;
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

<GAL::Schema::Result::Feature::transcript> requires no configuration files or environment variables.

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
