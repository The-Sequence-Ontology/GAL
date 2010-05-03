package GAL::Feature::sequence_feature;

use strict;
use vars qw($VERSION);


$VERSION = '0.01';
use base qw(GAL::Feature);

=head1 NAME

GAL::Feature::sequence_feature - <One line description of module's purpose here>

=head1 VERSION

This document describes GAL::Feature::sequence_feature version 0.01

=head1 SYNOPSIS

     use GAL::Feature::sequence_feature;

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
     Usage   : GAL::Feature::sequence_feature->new();
     Function: Creates a GAL::Feature::sequence_feature object;
     Returns : A GAL::Feature::sequence_feature object
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
				  phase attributes);
	$self->set_attributes($args, @valid_attributes);
	######################################################################
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
  my $id =   $self->{attributes}{ID}[0];
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

=head2 alias

 Title   : alias
 Usage   : $self->alias();
 Function: Get value of alias.
 Returns : Value of alias.
 Args    : N/A

=cut

sub alias {
  my $self = shift;
  my @aliases = $self->get_attribute_values('Alias');
  return shift @aliases;
}

#-----------------------------------------------------------------------------

=head2 parent

 Title   : parent
 Usage   : $self->parent();
 Function: Get the parent.
 Returns : List of parent IDs.
 Args    : N/A

=cut

sub parent {
  my $self = shift;
  my @parents = $self->get_attribute_values('Parent');
  return wantarray ? @parents : \@parents;
}

#-----------------------------------------------------------------------------

=head2 target

 Title   : target
 Usage   : $self->target();
 Function: Get value of target.
 Returns : Value of target.
 Args    : N/A

=cut

sub target {
  my $self = shift;
  my @targets = $self->get_attribute_values('Target');
  return shift @targets;
}

#-----------------------------------------------------------------------------

=head2 gap

 Title   : gap
 Usage   : $self->gap();
 Function: Get value of gap.
 Returns : Value of gap.
 Args    : N/A

=cut

sub gap {
  my $self = shift;
  my @gaps = $self->get_attribute_values('Gap');
  return shift @gaps;
}

#-----------------------------------------------------------------------------

=head2 derives_from

 Title   : derives_from
 Usage   : $self->derives_from();
 Function: Get value of derives_from.
 Returns : Value of derives_from.
 Args    : N/A

=cut

sub derives_from {
  my $self = shift;
  my @derives_from = $self->get_attribute_values('Derives_from');
  return shift @derives_from;
}

#-----------------------------------------------------------------------------

=head2 note

 Title   : note
 Usage   : $self->note();
 Function: Get value of note.
 Returns : Value of note.
 Args    : N/A

=cut

sub note {
  my $self = shift;
  my @notes = $self->get_attribute_values('Note');
  return shift @notes;
}

#-----------------------------------------------------------------------------

=head2 dbxref

 Title   : dbxref
 Usage   : $self->dbxref();
 Function: Get value of dbxref.
 Returns : Value of dbxref.
 Args    : N/A

=cut

sub dbxref {
  my $self = shift;
  my @dbxrefs = $self->get_attribute_values('Dbxref');
  return shift @dbxrefs;
}

#-----------------------------------------------------------------------------

=head2 ontology_term

 Title   : ontology_term
 Usage   : $self->ontology_term();
 Function: Get value of ontology_term.
 Returns : Value of ontology_term.
 Args    : N/A

=cut

sub ontology_term {
  my $self = shift;
  my @ontology_terms = $self->get_attribute_values('Ontology_term');
  return shift @ontology_terms;
}

#-----------------------------------------------------------------------------

=head2 get_attribute_tags

 Title   : get_attribute_tags
 Usage   : $self->get_attribute_tags();
 Function: Get tags of attributes.
 Returns : List of attribute tags.
 Args    : N/A

=cut

sub get_attribute_tags {
  my $self = shift;
  my @tags = keys %{$self->{attributes}};
  return wantarray ? @tags : \@tags;
}

#-----------------------------------------------------------------------------

=head2 get_attribute_values

 Title   : get_attribute_values
 Usage   : $self->get_attribute_values($tag);
 Function: Get the values of the attribute $tag
 Returns : A list of values.
 Args    : N/A

=cut

sub get_attribute_values {
  my ($self, $tag) = @_;
  my @values = ();
  if (exists $self->{attributes}{$tag} &&
      ref($self->{attributes}{$tag}) eq 'ARRAY') {
	  @values = @{$self->{attributes}{$tag}};
  }
  return wantarray ? @values : \@values;
}

#-----------------------------------------------------------------------------

=head2 has_attribute_value

 Title   : has_attribute_value
 Usage   : $self->has_attribute_value($tag, $value);
 Function: Get the values of the attribute $tag
 Returns : A list of values.
 Args    : N/A

=cut

sub has_attribute_value {
  my ($self, $tag, $value) = @_;
  my @values = ();
  if (exists $self->{attributes}{$tag} &&
      ref($self->{attributes}{$tag}) eq 'ARRAY') {
	  @values = @{$self->{attributes}{$tag}};
  }
  return 1 if grep {$value eq $_} @values;
}

#-----------------------------------------------------------------------------

=head2 to_gff3

 Title   : to_gff3
 Usage   : print $self->to_gff3();
 Function: Print the feature in GFF3 format
 Returns : The feautre stringified in a GFF3 format.
 Args    : N/A

=cut


#
# MOVE ME TO BASE.PM AND DELETE ME FROM PARSER ALSO
#


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
	for my $tag ($self->get_attribute_tags) {
		next if $tag =~ /^(ID|Parent|Name)$/;
		my @values = $self->get_attribute_values($tag);
		my $value_text = join ',', @values;
		$att_text .= "$tag=$value_text;";
	}
	$gff3_text .= "\t$att_text";

	return $gff3_text;
}

#-----------------------------------------------------------------------------

=head2 children

 Title   : children
 Usage   : $self->children($type);
 Function: Get this feature's immediate children
 Returns : A list of Feature objects
 Args    : Optionally a valid SO term(s) (scalar or array ref) defining what
           type(s) of children to return.

=cut

sub children {
  my ($self, $type) = @_;
  my $children = $self->storage->get_children($self->feature_id, $type);
  return wantarray ? @{$children} : $children;
}

#-----------------------------------------------------------------------------

=head2 children_recursive

 Title   : children_recursive
 Usage   : $self->children_recursive($type);
 Function: Get this feature's children recursively.
 Returns : A list of Feature objects
 Args    : Optionally a valid SO term(s) (scalar or array ref) defining what
           type(s) of children to return.

=cut

sub children_recursive {
  my ($self, $type) = @_;
  my $children = $self->storage->get_children_recursive($self->feature_id, $type);
  return wantarray ? @{$children} : $children;
}

#-----------------------------------------------------------------------------

=head2 parents_recursive

 Title   : parents_recursive
 Usage   : $self->parents_recursive($type);
 Function: Get this feature's parents recursively.
 Returns : A list of Feature objects
 Args    : Optionally a valid SO term(s) (scalar or array ref) defining what
           type(s) of parent to return.

=cut

sub parents_recursive {
  my ($self, $type) = @_;
  my $parents = $self->storage->get_parents($self->feature_id, $type);
  return wantarray ? @{$parents} : $parents;
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

<GAL::Feature::sequence_feature> requires no configuration files or environment variables.

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
