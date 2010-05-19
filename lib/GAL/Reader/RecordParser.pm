package GAL::Reader::RecordParser;

use strict;
use vars qw($VERSION);


$VERSION = '0.01';
use base qw(GAL::Reader);

=head1 NAME

GAL::Reader::RecordParser - <One line description of module's purpose here>

=head1 VERSION

This document describes GAL::Reader::RecordParser version 0.01

=head1 SYNOPSIS

     use GAL::Reader::RecordParser;

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
     Usage   : GAL::Reader::RecordParser->new();
     Function: Creates a GAL::Reader::RecordParser object;
     Returns : A GAL::Reader::RecordParser object
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
	my @valid_attributes = qw(file fh record_separator field_separator
				  comment_delimiter fields);
	$self->set_attributes($args, @valid_attributes);
	######################################################################
	return $args;
}

#-----------------------------------------------------------------------------

=head2 record_separator

 Title   : record_separator
 Usage   : $a = $self->record_separator();
 Function:
 Returns :
 Args    : N/A

=cut

sub record_separator {
  my ($self, $record_separator) = @_;
  $self->{record_separator} = $record_separator if $record_separator;
  return $self->{record_separator};
}

#-----------------------------------------------------------------------------

=head2 field_separator

 Title   : field_separator
 Usage   : $a = $self->field_separator();
 Function:
 Returns :
 Args    : N/A

=cut

sub field_separator {
  my ($self, $field_separator) = @_;
  $self->{field_separator} = $field_separator if $field_separator;
  return $self->{field_separator};
}

#-----------------------------------------------------------------------------

=head2 comment

 Title   : comment
 Usage   : $a = $self->comment();
 Function:
 Returns :
 Args    : N/A

=cut

sub comment {
  my ($self, $comment) = @_;
  $self->{comment} = $comment if $comment;
  return $self->{comment};
}

#-----------------------------------------------------------------------------

=head2 bind_fields

 Title   : bind_fields
 Usage   : $a = $self->bind_fields();
 Function:
 Returns :
 Args    : N/A

=cut

sub bind_fields {
  my ($self, $bind_fields) = @_;
  $self->{bind_fields} = $bind_fields if $bind_fields;
  return wantarray ? @{$self->{bind_fields}} : $self->{bind_fields};
}

#-----------------------------------------------------------------------------

=head2 external_reader

 Title   : external_reader
 Usage   : $a = $self->external_reader();
 Function: Get/Set the external_reader.  This is left as a public
	   method to support future use of alternate external_readers, but
	   this is currently not implimented so this method should be
	   considered for internal use only.
 Returns : The value of external_reader.
 Args    : A value to set external_reader to.

=cut

sub external_reader {
  my $self = shift;
  if (! $self->{external_reader}) {
    my $external_reader;
    my $reader_args = {fh               => $self->fh,
		       record_separator => $self->record_separator,
		       field_separator  => $self->field_separator,
		       comment          => $self->comment,
		      };

    $external_reader = Text::RecordParser->new($reader_args);
    $external_reader->bind_fields($self->bind_fields);
    $self->{external_reader} = $external_reader;
  }
  return $self->{external_reader};
}

#-----------------------------------------------------------------------------

=head2 next_record

 Title   : next_record
 Usage   : $a = $self->next_record();
 Function: Return the next record from the external_reader
 Returns : The next record from the external_reader.
 Args    : N/A

=cut

sub next_record {
	my $self = shift;
	return $self->external_reader->fetchrow_hashref;
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

<GAL::Reader::RecordParser> requires no configuration files or environment variables.

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
