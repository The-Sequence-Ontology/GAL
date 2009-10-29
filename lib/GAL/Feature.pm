package GAL::Feature;

use strict;
use vars qw($VERSION);


$VERSION = '0.01';
use base qw(GAL::Base);

=head1 NAME

GAL::Feature - <One line description of module's purpose here>

=head1 VERSION

This document describes GAL::Feature version 0.01

=head1 SYNOPSIS

     use GAL::Feature;

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

=head2

     Title   : new
     Usage   : GAL::Feature->new();
     Function: Creates a GAL::Feature object;
     Returns : A GAL::Feature object
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

        $self->SUPER::_initialize_args(@args);

	my @valid_attributes = qw(seqid
				  source
				  type
				  start
				  end
				  score
				  strand
				  phase
				  attributes
				 );

	my $args = $self->prepare_args(\@args, \@valid_attributes);

	$self->set_attributes($args, @valid_attributes);

}

#-----------------------------------------------------------------------------

=head2 seqid

 Title   : seqid
 Usage   : $self->seqid();
 Function: Get/Set value of seqid.
 Returns : Value of seqid.
 Args    : Value to set seqid to.

=cut

sub seqid {
  my ($self, $value) = @_;
  $self->{seqid} = $value if defined $value;
  return $self->{seqid};
}

#-----------------------------------------------------------------------------

=head2 source

 Title   : source
 Usage   : $self->source();
 Function: Get/Set value of source.
 Returns : Value of source.
 Args    : Value to set source to.

=cut

sub source {
  my ($self, $value) = @_;
  $self->{source} = $value if defined $value;
  return $self->{source};
}

#-----------------------------------------------------------------------------

=head2 type

 Title   : type
 Usage   : $self->type();
 Function: Get/Set value of type.
 Returns : Value of type.
 Args    : Value to set type to.

=cut

sub type {
  my ($self, $value) = @_;
  $self->{type} = $value if defined $value;
  return $self->{type};
}

#-----------------------------------------------------------------------------

=head2 start

 Title   : start
 Usage   : $self->start();
 Function: Get/Set value of start.
 Returns : Value of start.
 Args    : Value to set start to.

=cut

sub start {
  my ($self, $value) = @_;
  $self->{start} = $value if defined $value;
  return $self->{start};
}

#-----------------------------------------------------------------------------

=head2 end

 Title   : end
 Usage   : $self->end();
 Function: Get/Set value of end.
 Returns : Value of end.
 Args    : Value to set end to.

=cut

sub end {
  my ($self, $value) = @_;
  $self->{end} = $value if defined $value;
  return $self->{end};
}

#-----------------------------------------------------------------------------

=head2 score

 Title   : score
 Usage   : $self->score();
 Function: Get/Set value of score.
 Returns : Value of score.
 Args    : Value to set score to.

=cut

sub score {
  my ($self, $value) = @_;
  $self->{score} = $value if defined $value;
  return $self->{score};
}

#-----------------------------------------------------------------------------

=head2 strand

 Title   : strand
 Usage   : $self->strand();
 Function: Get/Set value of strand.
 Returns : Value of strand.
 Args    : Value to set strand to.

=cut

sub strand {
  my ($self, $value) = @_;
  $self->{strand} = $value if defined $value;
  return $self->{strand};
}

#-----------------------------------------------------------------------------

=head2 phase

 Title   : phase
 Usage   : $self->phase();
 Function: Get/Set value of phase.
 Returns : Value of phase.
 Args    : Value to set phase to.

=cut

sub phase {
  my ($self, $value) = @_;
  $self->{phase} = $value if defined $value;
  return $self->{phase};
}

#-----------------------------------------------------------------------------

=head2 attributes

 Title   : attributes
 Usage   : $self->attributes();
 Function: Get/Set value of attributes.
 Returns : Value of attributes.
 Args    : Value to set attributes to.

=cut

sub attributes {
  my ($self, $value) = @_;
  $self->{attributes} = $value if defined $value;
  return $self->{attributes};
}


#-----------------------------------------------------------------------------

=head2 id

 Title   : id
 Usage   : $self->id();
 Function: Get value of id.
 Returns : Value of id.
 Args    : N/A

=cut

sub id {
  my $self = shift;
  my @ids = $self->get_attribute_values('ID');
  my $id = shift @ids;
  $id ||= join ':', ($self->{seqid},
		     $self->{source},
		     $self->{type},
		     $self->{start},
		     $self->{end},
		    );
  return $id;
}

#-----------------------------------------------------------------------------

=head2 name

 Title   : name
 Usage   : $self->name();
 Function: Get value of name.
 Returns : Value of name.
 Args    : N/A

=cut

sub name {
  my $self = shift;
  my @names = $self->get_attribute_values('Name');
  return shift @names;
}

#-----------------------------------------------------------------------------

=head2 parents

 Title   : parents
 Usage   : $self->parents();
 Function: Get the parents.
 Returns : List of parent IDs.
 Args    : N/A

=cut

sub parents {
  my $self = shift;
  my @parents = $self->get_attribute_values('Parent');
  return wantarray ? @parents : \@parents;
}

#-----------------------------------------------------------------------------

=head2 get_attribute_keys

 Title   : get_attribute_keys
 Usage   : $self->get_attribute_keys();
 Function: Get keys of attributes.
 Returns : List of attribute keys.
 Args    : N/A

=cut

sub get_attribute_keys {
  my $self = shift;
  my @keys = keys %{$self->{attributes}};
  return wantarray ? @keys : \@keys;
}

#-----------------------------------------------------------------------------

=head2 get_attribute_values

 Title   : get_attribute_values
 Usage   : $self->get_attribute_values($key);
 Function: Get the values of the attribute $key
 Returns : A list of values.
 Args    : N/A

=cut

sub get_attribute_values {
  my ($self, $key) = @_;
  my @values = ();
  if (exists $self->{attributes}{$key} &&
      ref($self->{attributes}{$key}) eq 'ARRAY') {
	  @values = @{$self->{attributes}{$key}};
  }
  return wantarray ? @values : \@values;
}

#-----------------------------------------------------------------------------

=head2 to_gff3

 Title   : to_gff3
 Usage   : print $self->to_gff3();
 Function: Print the feature in GFF3 format
 Returns : The feautre stringified in a GFF3 format.
 Args    : N/A

=cut

sub to_gff3 {
	my $self = shift;

	my $attrb_text;

	my $gff3_text = join "\t", ($self->seqid,
				    $self->source,
				    $self->type,
				    $self->start,
				    $self->end,
				    $self->score,
				    $self->strand,
				    $self->phase,
				   );

	my $att_text = 'ID=' . $self->id . ';';
	if (my @parents = $self->parents) {
		$att_text .= 'Parent=' . join ',', @parents . ';';
	}
	if ($self->name) {
		$att_text .= 'Name=' . $self->name . ';';
	}
	for my $key ($self->get_attribute_keys) {
		next if $key =~ /^(ID|Parent|Name)$/;
		my @values = $self->get_attribute_values($key);
		my $value_text = join ',', @values;
		$att_text .= "$key=$value_text;";
	}
	$gff3_text .= "\t$att_text";

	return $gff3_text;
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

<GAL::Feature> requires no configuration files or environment variables.

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
