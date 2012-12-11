package GAL::Feature::sequence_alteration;

use strict;
use vars qw($VERSION);


$VERSION = 0.2.0;
use base qw(GAL::Feature);

=head1 NAME

GAL::Feature::sequence_alteration - <One line description of module's purpose here>

=head1 VERSION

This document describes GAL::Feature::sequence_alteration version 0.2.0

=head1 SYNOPSIS

     use GAL::Feature::sequence_alteration;

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
     Usage   : GAL::Feature::sequence_alteration->new();
     Function: Creates a sequence_alteration object;
     Returns : A sequence_alteration object
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
	# Set valid class attributes here
	my @valid_attributes = qw(seqid source type start end score strand
				  phase attributes reference_allele
				  variant_allele reference_reads variant_reads
				  total_reads genotype genotype_probability
				  variant_locations variant_effects);
	$self->set_attributes($args, @valid_attributes);
	######################################################################
}

#-----------------------------------------------------------------------------

=head2 reference_allele

 Title   : reference_allele
 Usage   : $self->reference_allele();
 Function: Get/Set value of reference_allele.
 Returns : Value of reference_allele.
 Args    : Value to set reference_allele to.

=cut

sub reference_allele {
  my ($self, $value) = @_;
  $self->{attributes}{reference_allele}[0] = $value if defined $value;
  return $self->{attributes}{reference_allele}[0];
}

#-----------------------------------------------------------------------------

=head2 variant_allele

 Title   : variant_allele
 Usage   : $self->variant_allele();
 Function: Get/Set value of variant_allele.
 Returns : Value of variant_allele.
 Args    : Value to set variant_allele to.

=cut

sub variant_allele {
  my ($self, $value) = @_;
  $self->{attributes}{variant_allele}[0] = $value if defined $value;
  return $self->{attributes}{variant_allele}[0];
}

#-----------------------------------------------------------------------------

=head2 reference_reads

 Title   : reference_reads
 Usage   : $self->reference_reads();
 Function: Get/Set value of reference_reads.
 Returns : Value of reference_reads.
 Args    : Value to set reference_reads to.

=cut

sub reference_reads {
  my ($self, $value) = @_;
  $self->{attributes}{reference_reads}[0] = $value if defined $value;
  return $self->{attributes}{reference_reads}[0];
}

#-----------------------------------------------------------------------------

=head2 variant_reads

 Title   : variant_reads
 Usage   : $self->variant_reads();
 Function: Get/Set value of variant_reads.
 Returns : Value of variant_reads.
 Args    : Value to set variant_reads to.

=cut

sub variant_reads {
  my ($self, $value) = @_;
  $self->{attributes}{variant_reads}[0] = $value if defined $value;
  return $self->{attributes}{variant_reads}[0];
}

#-----------------------------------------------------------------------------

=head2 total_reads

 Title   : total_reads
 Usage   : $self->total_reads();
 Function: Get/Set value of total_reads.
 Returns : Value of total_reads.
 Args    : Value to set total_reads to.

=cut

sub total_reads {
  my ($self, $value) = @_;
  $self->{attributes}{total_reads}[0] = $value if defined $value;
  return $self->{attributes}{total_reads}[0];
}

#-----------------------------------------------------------------------------

=head2 genotype

 Title   : genotype
 Usage   : $self->genotype();
 Function: Get/Set value of genotype.
 Returns : Value of genotype.
 Args    : Value to set genotype to.

=cut

sub genotype {
  my ($self, $value) = @_;
  $self->{attributes}{genotype}[0] = $value if defined $value;
  return $self->{attributes}{genotype}[0];
}

#-----------------------------------------------------------------------------

=head2 genotype_probability

 Title   : genotype_probability
 Usage   : $self->genotype_probability();
 Function: Get/Set value of genotype_probability.
 Returns : Value of genotype_probability.
 Args    : Value to set genotype_probability to.

=cut

sub genotype_probability {
  my ($self, $value) = @_;
  $self->{attributes}{genotype_probability}[0] = $value if defined $value;
  return $self->{attributes}{genotype_probability}[0];
}

#-----------------------------------------------------------------------------

=head2 intersected_types

 Title   : intersected_types
 Usage   : $self->intersected_types();
 Function: Get/Set value of intersected_types.
 Returns : Value of intersected_types.
 Args    : Value to set intersected_types to.

=cut

sub intersected_types {
  my ($self, $value) = @_;
  push @{$self->{attributes}{intersected_type}}, @{$value} if
    defined $value->[0];
  return wantarray ? @{$self->{attributes}{intersected_type}} :
    $self->{attributes}{intersected_type};
}

#-----------------------------------------------------------------------------

=head2 intersected_xrefs

 Title   : intersected_xrefs
 Usage   : $self->intersected_xrefs();
 Function: Get/Set value of intersected_xrefs.
 Returns : Value of intersected_xrefs.
 Args    : Value to set intersected_xrefs to.

=cut

sub intersected_xrefs {
  my ($self, $value) = @_;
  push @{$self->{attributes}{intersected_xref}}, @{$value} if
    defined $value->[0];
  return wantarray ? @{$self->{attributes}{intersected_xref}} :
    $self->{attributes}{intersected_xref};
}

#-----------------------------------------------------------------------------

=head2 variant_effects

 Title   : variant_effects
 Usage   : $self->variant_effects();
 Function: Get/Set value of variant_effects.
 Returns : Value of variant_effects.
 Args    : Value to set variant_effects to.

=cut

sub variant_effects {
  my ($self, $value) = @_;
  push @{$self->{attributes}{variant_effect}}, @{$value} if
    defined $value->[0];
  return wantarray ? @{$self->{attributes}{variant_effect}} :
    $self->{attributes}{variant_effect};
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

<GAL::Feature::sequence_alteration> requires no configuration files or environment variables.

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

Copyright (c) 2012, Barry Moore <barry.moore@genetics.utah.edu>.  All rights reserved.

    This module is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself (See LICENSE).

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
