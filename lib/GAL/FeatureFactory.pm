package GAL::FeatureFactory;

use strict;
use vars qw($VERSION);


$VERSION = '0.01';
use base qw(GAL::Base);

=head1 NAME

GAL::FeatureFactory - <One line description of module's purpose here>

=head1 VERSION

This document describes GAL::FeatureFactory version 0.01

=head1 SYNOPSIS

     use GAL::FeatureFactory;

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
     Usage   : GAL::FeatureFactory->new();
     Function: Creates a GAL::FeatureFactory object;
     Returns : A GAL::FeatureFactory object
     Args    :

=cut

sub new {
	my ($class, @args) = @_;
	my $self = $class->SUPER::new;
	$self->_initialize_args(@args);
	return $self;
}

#-----------------------------------------------------------------------------

sub _initialize_args {
	my ($self, @args) = @_;

	my @valid_attributes = qw(type
				 );

	my $args = $self->prepare_args(\@args, \@valid_attributes);

	$self->set_attributes($args, @valid_attributes);

	$self->{type_map} = {sequence_alteration                           => 'sequence_alteration',
			     SNP 					   => 'sequence_alteration',
			     inversion 					   => 'sequence_alteration',
			     insertion 					   => 'sequence_alteration',
			     indel 					   => 'sequence_alteration',
			     substitution 				   => 'sequence_alteration',
			     deletion 					   => 'sequence_alteration',
			     translocation 				   => 'sequence_alteration',
			     uncharacterised_change_in_nucleotide_sequence => 'sequence_alteration',
			     nucleotide_insertion 			   => 'sequence_alteration',
			     nucleotide_deletion 			   => 'sequence_alteration',
			     nucleotide_duplication 			   => 'sequence_alteration',
			     transgenic_insertion 			   => 'sequence_alteration',
			     recombinationally_inverted_gene 		   => 'sequence_alteration',
			     SNP 					   => 'sequence_alteration',
			     point_mutation 				   => 'sequence_alteration',
			     sequence_length_variation 			   => 'sequence_alteration',
			     complex_substitution 			   => 'sequence_alteration',
			     MNP 					   => 'sequence_alteration',
			     transition 				   => 'sequence_alteration',
			     pyrimidine_transition 			   => 'sequence_alteration',
			     purine_transition 				   => 'sequence_alteration',
			     A_to_G_transition 				   => 'sequence_alteration',
			     G_to_A_transition 				   => 'sequence_alteration',
			     C_to_T_transition 				   => 'sequence_alteration',
			     T_to_C_transition 				   => 'sequence_alteration',
			     C_to_T_transition_at_pCpG_site 		   => 'sequence_alteration',
			     pyrimidine_to_purine_transversion 		   => 'sequence_alteration',
			     purine_to_pyrimidine_transversion 		   => 'sequence_alteration',
			     G_to_T_transversion 			   => 'sequence_alteration',
			     A_to_T_transversion 			   => 'sequence_alteration',
			     A_to_C_transversion 			   => 'sequence_alteration',
			     G_to_C_transversion 			   => 'sequence_alteration',
			     T_to_G_transversion 			   => 'sequence_alteration',
			     T_to_A_transversion 			   => 'sequence_alteration',
			     C_to_A_transversion 			   => 'sequence_alteration',
			     C_to_G_transversion 			   => 'sequence_alteration',
			    }

}

#-----------------------------------------------------------------------------

=head2 map_type

 Title   : map_type
 Usage   : $type = $self->map_type($type);
 Function: Map a SO sequence_feature to a supported Feature subclass
 Returns : A supported Feature subclass type
 Args    : A SO sequence_feature

=cut

sub map_type {
	my ($self, $type) = @_;
	$type = $self->{type_map}{$type} ||= 'generic';
	return $type;
}

#-----------------------------------------------------------------------------

=head2 type

 Title   : type
 Usage   : $a = $self->type();
 Function: Get/Set the value of type.
 Returns : The value of type.
 Args    : A value to set type to.

=cut

sub type {
	my ($self, $value) = @_;
	if (defined $value) {
		$value = $self->map_type($value);
		$self->{type} = $value;
	}
	$self->{type} ||= 'generic';
	return $self->{type};
}

#-----------------------------------------------------------------------------

=head2 create

 Title   : create
 Usage   : $a = $self->create();
 Function: Create a new GAL::Feature::$type object
 Returns : A GAL::Feature::$type object
 Args    : The arguments expected by GAL::Feature::$type
           See the GAL::Feature and subclass docs for more info

=cut

sub create {
	my ($self, @args) = @_;
	my @valid_attributes = qw(seqid source type start end score strand
                                  phase attributes);
	my $args = $self->prepare_args(\@args, \@valid_attributes);
	my $type = "GAL::Feature::" . $self->type($args->{type});
	$self->load_module($type);
	return $type->new(@args);
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

<GAL::FeatureFactory> requires no configuration files or environment variables.

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
