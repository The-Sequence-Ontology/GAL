package GAL::Parser::gff::gff3;

use strict;
use vars qw($VERSION);


$VERSION = '0.01';
use base ;

=head1 NAME

Feature - <One line description of module's purpose here>

=head1 VERSION

This document describes Feature version 0.01

=head1 SYNOPSIS

     use Feature;

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
=head2 _parse_attrb

 Title   : _parse_attrb
 Usage   : $a = $self->_parse_attrb();
 Function: Parse the feature line
 Returns : N/A
 Args    : A 9 column text string in GFF

=cut

sub _parse_attrb {

	my ($self, $attrb_text) = @_;

	my $attrb_pairs = $self->_split_attrb($attrb_text);

	my $attrb_hash = {};
	for my $attrb_pair (@{$attrb_pairs}) {

		my ($key, $values) = $self->_split_key_value($attrb_pair);

		$attrb_hash->{$key} = $values;

	}
	$self->_standardize_attrb_hash($attrb_hash);

	return $attrb_hash;
}

#-----------------------------------------------------------------------------

=head2 _split_attrb

 Title   : _split_attrb
 Usage   : $self->_split_attrb
 Function: Descriptions
 Returns :
 Args    :

=cut

sub _split_attrb {

	my ($self, $attrb_text) = @_;

	my @attrb_pairs = split /\s*;\s*/, $attrb_text;

	map {$_ = $self->_trim_text($_)} @attrb_pairs;

	return \@attrb_pairs;
}

#-----------------------------------------------------------------------------

=head2 _split_key_value

 Title   : _split_key_value
 Usage   : $self->_split_key_value
 Function: Descriptions
 Returns :
 Args    :

=cut

sub _split_key_value {

	my ($self, $attrb_pair) = @_;

	my ($key, $value_text) = split /\s*=\s*/, $attrb_pair;

	$key   = $self->_trim_text($key);
	$value_text = $self->_trim_text($value_text);

	my $values = $self->_split_values($value_text);

	return ($key, $values);
}

#-----------------------------------------------------------------------------

=head2 _split_values

 Title   : _split_values
 Usage   : $self->_split_values
 Function: Descriptions
 Returns :
 Args    :

=cut

sub _split_values {

	my ($self, $value_text) = @_;

	my @values = split /\s*,\s*/, $value_text;

	map {$_ = $self->_trim_text($_)} @values;

	return \@values;
}

#-----------------------------------------------------------------------------

=head2 _standardize_attrb_hash

 Title   : _standardize_attrb_hash
 Usage   : $self->_standardize_attrb_hash
 Function: Descriptions
 Returns :
 Args    :

=cut

sub _standardize_attrb_hash {

	my ($self, $attrb_hash) = @_;

	# Over-ride this method to assign ID Parent Name etc. tags for formats
	# that don't use those tags.

	return;

}

#-----------------------------------------------------------------------------

=head2 _trim_text

 Title   : _trim_text
 Usage   : $self->_trim_text
 Function: Descriptions
 Returns :
 Args    :

=cut

sub _trim_text {

	my ($self, $text) = @_;

	$text =~ s/^\s*//;
	$text =~ s/\s*$//;

	return $text;
}

#-----------------------------------------------------------------------------

=head2 seq

 Title   : seq
 Usage   : $self->seq
 Function: Descriptions
 Returns :
 Args    :

=cut

sub seq {

	my ($self, $value) = @_;

	$self->{_seq} = $value if $value;
	return $self->{_seq};
}

#-----------------------------------------------------------------------------

=head2 source

 Title   : source
 Usage   : $self->source
 Function: Descriptions
 Returns :
 Args    :

=cut

sub source {

	my ($self, $value) = @_;

	$self->{_source} = $value if $value;
	return $self->{_source};

}

#-----------------------------------------------------------------------------

=head2 type

 Title   : type
 Usage   : $self->type
 Function: Descriptions
 Returns :
 Args    :

=cut

sub type {

	my ($self, $value) = @_;

	$self->{_type} = $value if $value;
	return $self->{_type};

}

#-----------------------------------------------------------------------------

=head2 start

 Title   : start
 Usage   : $self->start
 Function: Descriptions
 Returns :
 Args    :

=cut

sub start {

	my ($self, $value) = @_;

	$self->{_start} = $value if $value;
	return $self->{_start};

}

#-----------------------------------------------------------------------------

=head2 end

 Title   : end
 Usage   : $self->end
 Function: Descriptions
 Returns :
 Args    :

=cut

sub end {

	my ($self, $value) = @_;

	$self->{_end} = $value if $value;
	return $self->{_end};

}

#-----------------------------------------------------------------------------

=head2 score

 Title   : score
 Usage   : $self->score
 Function: Descriptions
 Returns :
 Args    :

=cut

sub score {

	my ($self, $value) = @_;

	$self->{_score} = $value if $value;
	return $self->{_score};

}

#-----------------------------------------------------------------------------

=head2 strand

 Title   : strand
 Usage   : $self->strand
 Function: Descriptions
 Returns :
 Args    :

=cut

sub strand {

	my ($self, $value) = @_;

	$self->{_strand} = $value if $value;
	return $self->{_strand};

}

#-----------------------------------------------------------------------------

=head2 phase

 Title   : phase
 Usage   : $self->phase
 Function: Descriptions
 Returns :
 Args    :

=cut

sub phase {

	my ($self, $value) = @_;

	$self->{_phase} = $value if $value;
	return $self->{_phase};

}

#-----------------------------------------------------------------------------

=head2 attributes

 Title   : attributes
 Usage   : $self->attributes
 Function: Descriptions
 Returns :
 Args    :

=cut

sub attributes {

	my ($self, $value) = @_;

	my $attrb_hash = $self->_parse_attrb($value);

	$self->{_attributes} = $attrb_hash if $attrb_hash;
	return $self->{_attributes};

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

<Feature> requires no configuration files or environment variables.

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
