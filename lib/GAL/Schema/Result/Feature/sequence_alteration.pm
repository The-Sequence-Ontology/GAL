package GAL::Schema::Result::Feature::sequence_alteration;

use strict;
use warnings;
use base qw(GAL::Schema::Result::Feature::sequence_feature);

=head1 NAME

GAL::Schema::Result::Feature::sequence_alteration - <One line description of module's purpose here>

=head1 VERSION

This document describes GAL::Schema::Result::Feature::sequence_alteration version 0.01

=head1 SYNOPSIS

     use GAL::Schema::Result::Feature::sequence_alteration;

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

sub variant_seq {
  my $self = shift;
  my $variant_seqs = $self->attribute_value('Variant_seq');
  return wantarray ? @{$variant_seqs} : $variant_seqs;
}

#-----------------------------------------------------------------------------

sub variant_seq_no_ref {
  my $self = shift;
  my $reference_seq = $self->reference_seq;
  my @variant_seqs_no_ref = grep {$_ ne $reference_seq}
    $self->attribute_value('Variant_seq');
  return wantarray ? @variant_seqs_no_ref : \@variant_seqs_no_ref;
}

#-----------------------------------------------------------------------------

sub reference_seq {
  my $self = shift;
  my $reference_seq = $self->attribute_value('Reference_seq');
  return $reference_seq->[0];
}

#-----------------------------------------------------------------------------

sub variant_reads {
  my $self = shift;
  my $variant_reads = $self->attribute_value('Variant_reads');
  return wantarray ? @{$variant_reads} : $variant_reads;
}

#-----------------------------------------------------------------------------

sub total_reads {
  my $self = shift;
  my $total_reads = $self->attribute_value('Total_reads');
  return wantarray ? @{$total_reads} : $total_reads;
}

#-----------------------------------------------------------------------------

sub genotype {
  my $self = shift;
  my $genotype = $self->attribute_value('Genotype');
  return $genotype->[0];
}

#-----------------------------------------------------------------------------

sub variant_effect {
  my $self = shift;
  my $variant_effect = $self->attribute_value('Variant_effect');
  return wantarray ? @{$variant_effect} : $variant_effect;
}

#-----------------------------------------------------------------------------

sub variant_copy_number {
  my $self = shift;
  my $variant_copy_number = $self->attribute_value('Variant_copy_number');
  return wantarray ? @{$variant_copy_number} : $variant_copy_number;
}

#-----------------------------------------------------------------------------

sub reference_copy_number {
  my $self = shift;
  my $reference_copy_number = $self->attribute_value('Reference_copy_number');
  return $reference_copy_number->[0];
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

<GAL::Schema::Result::Feature::sequence_alteration> requires no configuration files or environment variables.

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
