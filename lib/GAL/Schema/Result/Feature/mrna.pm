package GAL::Schema::Result::Feature::mrna;

use strict;
use warnings;
use base qw(GAL::Schema::Result::Feature::transcript);

=head1 NAME

GAL::Schema::Result::Feature::mrna - <One line description of module's purpose here>

=head1 VERSION

This document describes GAL::Schema::Result::Feature::mrna version 0.01

=head1 SYNOPSIS

     use GAL::Schema::Result::Feature::mrna;

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

sub CDSs {

  my $self = shift;

  my $CDSs = $self->children->search({type => 'CDS'},
				     {order_by => { -asc => 'start' }});

  return wantarray ? $CDSs->all : $CDSs;

}

#-----------------------------------------------------------------------------

sub CDS_seq_genomic {

  my $self = shift;

  my $CDS_seq_genomic;
  map {$CDS_seq_genomic .= $_->genomic_seq} $self->CDSs->all;
  return $CDS_seq_genomic;
}

#-----------------------------------------------------------------------------

sub CDS_seq {

  my $self = shift;

  my $CDS_seq = $self->CDS_seq_genomic;
  if ($self->strand eq '-') {
    $CDS_seq = $self->annotation->revcomp($CDS_seq);
  }
  return $CDS_seq;
}

#-----------------------------------------------------------------------------

sub protein_seq {

  my $self = shift;

  my $CDS_seq = $self->CDS_seq;
  my $protein_seq = $self->annotation->translate($CDS_seq);
  return $protein_seq;
}

#-----------------------------------------------------------------------------

sub map2my_CDS {

  my ($self, @coordinates) = @_;

  my ($CDS_start) = $self->map2me($self->CDS_start);
  my @CDS_coordinates = $self->map2me(@coordinates);
  map {$_ = $_ - $CDS_start + 1} @CDS_coordinates;

  return wantarray ? @CDS_coordinates : \@CDS_coordinates;
}

#-----------------------------------------------------------------------------

sub map2my_protein {

  my ($self, @coordinates) = @_;

  my @protein_coordinates = $self->map2my_CDS(@coordinates);
  map {$_ = int($_ / 3) + 1} @protein_coordinates;

  return wantarray ? @protein_coordinates : \@protein_coordinates;
}

#-----------------------------------------------------------------------------

sub CDS_start {

  my $self = shift;
  my $strand = $self->strand;
  my @CDSs = $self->CDSs;
  my $CDS_start = $strand eq '-' ? $CDSs[-1]->end : $CDSs[0]->start;

}

#-----------------------------------------------------------------------------

sub CDS_end {

  my $self = shift;
  my $strand = $self->strand;
  my $CDSs = $self->CDSs;
  my $CDS_start = $strand eq '-' ? $CDSs->first->start : $CDSs->last->end;

}

#-----------------------------------------------------------------------------

sub CDS_length {

  my $self = shift;
  my $CDS_length;
  map {$CDS_length += $_->genomic_length} $self->CDSs->all;
  return $CDS_length;
}

#-----------------------------------------------------------------------------

sub protein_length {
  my $self = shift;
  return int($self->CDS_length / 3);
}

#-----------------------------------------------------------------------------

sub phase_at_location {

  my ($self, $location) = @_;

  my %mod2phase = (1 => 0,
		   2 => 2,
		   0 => 1,
		  );
  my ($CDS_location) = $self->map2my_CDS($location);
  my $modulus = $CDS_location % 3;
  return $mod2phase{$modulus};
}

#-----------------------------------------------------------------------------

sub frame_at_location {

  my ($self, $location) = @_;
  my %mod2frame = (1 => 0,
		   2 => 1,
		   0 => 2,
		  );
  my ($CDS_location) = $self->map2my_CDS($location);
  my $modulus = $CDS_location % 3;
  my $frame = $mod2frame{$modulus};;
  return $frame;
}

#-----------------------------------------------------------------------------

sub codon_at_location {

  my ($self, $location) = @_;

  my $CDS_sequence = $self->CDS_seq;
  my ($CDS_location) = $self->map2my_CDS($location);
  my $frame = $self->frame_at_location($location);
  my $codon_start = $CDS_location - $frame;
  my $codon = substr($CDS_sequence, ($codon_start - 1), 3);
  return wantarray ? ($codon, $frame) : $codon;
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

<GAL::Schema::Result::Feature::mrna> requires no configuration files or environment variables.

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
