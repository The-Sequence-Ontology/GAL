package GAL::Reader::DelimitedLine;

use strict;
use vars qw($VERSION);


$VERSION = '0.01';
use base qw(GAL::Reader);

=head1 NAME

GAL::Reader::DelimitedLine -  Delimited file parsing for GAL

=head1 VERSION

This document describes GAL::Reader::DelimitedLine version 0.01

=head1 SYNOPSIS

    use GAL::Reader::DelimitedLine;
    $reader = GAL::Reader::DelimitedLine->new();
    $reader->file('annotation_file.gff');
    $reader->field_names(qw(seqid source type start end score strand phase
			   attributes));
    $reader->next_record, '$reader->next_record');

=head1 DESCRIPTION

<GAL::Reader::DelimitedLine> provides delimited file (tab delimited, csv etc.)
reading capability to GAL.  It is not intended for general library use, but
rather as a GAL::Reader subclass for developers of GAL::Parser subclasses.
There is however no reason why it couldn't also be used as a stand alone
module for other purposes.

=head1 CONSTRUCTOR

New GAL::Reader::DelimitedLine objects are created by the class method new.
Arguments should be passed to the constructor as a list (or reference)
of key value pairs.  All attributes of the Reader object can be set in
the call to new. An simple example of object creation would look like
this:

  $reader = GAL::Reader::DelimitedLine->new(field_names => \@field_names);

The constructor recognizes the following parameters which will set the
appropriate attributes:

=over 4

=item * C<< field_names => [qw(seqid source type start end)] >>

This optional attribute provides an orderd list that describes the
field names of the columns in the delimited file.  If this attribute
is set then a call to next_record will return a hash (or reference)
with the given field names as keys, otherwise next_record will
return an array of column values.

=item * C<< field_separator => "\t" >>

This optional attribute provides a regular expression that will be used
to split the fields in each line of data.  The default is "\t" - a
tab.

=item * C<< comment_delimiter => "^\s*#" >>

This optional attribute provides a regular expression that will be
used to skip comment lines.  The default is "^\s*#" - lines whos first
non-whitespace charachter is a '#'.

The following attributes are inhereted from GAL::Reader:

=item * C<< file => feature_file.txt >>

This optional parameter defines what file to parse. While this
parameter is optional either it, or the following fh parameter must be
set before the first call to next_record.

=item * C<< fh => $FH >>

This optional parameter provides a file handle to parse. While this
parameter is optional, either it or the previous must be set before
the first call to next_record.

=back

=cut

#-----------------------------------------------------------------------------
#------------------------------- Constructor ---------------------------------
#-----------------------------------------------------------------------------

=head2 new

     Title   : new
     Usage   : $reader = GAL::Reader::DelimitedLine->new();
     Function: Creates a GAL::Reader::DelimitedLine object;
     Returns : A GAL::Reader::DelimitedLine object
     Args    : field_names => [qw(seqid source type)]
	       file => $file_name
	       fh   => FH
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
	my @valid_attributes = qw(field_names field_separator
                                  comment_delimiter);
	$self->set_attributes($args, @valid_attributes);
	######################################################################
	return $args;
}

#-----------------------------------------------------------------------------
#--------------------------------- Attributes --------------------------------
#-----------------------------------------------------------------------------

=head1 ATTRIBUTES

All attributes can be supplied as parameters to the
GAL::Reader::DelimitedLine constructor as a list (or referenece) of
key value pairs.

=head2 field_names

 Title   : field_names
 Usage   : $self->field_names([qw(seqid source type)]);
 Function: Set the names for the columns in the delimited text.  If this
	   attribute is set then next_record will return a hash (or reference)
	   otherwise it will return an array (or reference).
 Returns : The next record from the reader.
 Args    : N/A

=cut

sub field_names {

  my ($self, $field_names) = @_;

  $self->{field_names} = $field_names if $field_names;
  return wantarray ? @{$self->{field_names}} : $self->{field_names};
}

#-----------------------------------------------------------------------------

=head2 field_separator

 Title   : field_separator
 Usage   : $self->field_separator("\t");
 Function: Set the field separator for spliting lines of data.  Default
           is "\t" (tab).
 Returns : The field separator as a complied regular expression.
 Args    : A string or complied regular expression pattern.

=cut

sub field_separator {

  my ($self, $field_separator) = @_;

  if ($field_separator) {
    $field_separator = qr/$field_separator/
      unless ref $field_separator eq 'Regexp';
  }
  $self->{field_separator} = $field_separator if $field_separator;
  $self->{field_separator} ||= qr/\t/;
  return wantarray ? @{$self->{field_separator}} : $self->{field_names};
}

#-----------------------------------------------------------------------------

=head2 comment_delimiter

 Title   : comment_delimiter
 Usage   : $self->comment_delimiter("\t");
 Function: Set the field separator for spliting lines of data.  Default
           is "\t" (tab).
 Returns : The field separator as a complied regular expression.
 Args    : A string or complied regular expression pattern.

=cut

sub comment_delimiter {

  my ($self, $comment_delimiter) = @_;

  if ($comment_delimiter) {
    $comment_delimiter = qr/$comment_delimiter/
      unless ref $comment_delimiter eq 'Regexp';
  }
  $self->{comment_delimiter} = $comment_delimiter if $comment_delimiter;
  $self->{comment_delimiter} ||= qr/^\s*#/;
  return wantarray ? @{$self->{comment_delimiter}} : $self->{field_names};
}

#-----------------------------------------------------------------------------
#---------------------------------- Methods ----------------------------------
#-----------------------------------------------------------------------------

=head1 METHODS

=head2 next_record

 Title   : next_record
 Usage   : $record = $reader->next_record();
 Function: Return the next record from the reader
 Returns : The next record from the reader as a hash, array or reference
	   to one of those.  If feild_names is set then a hash will be
	   returned, otherwise an array.
 Args    : N/A

=cut

sub next_record {
	my $self = shift;
	my $fh = $self->fh;
	my $line;
	while ($line = <$fh>) {
	  last unless $line =~ $self->comment_delimiter;
	  chomp $line;
	}
	return undef unless defined $line;
	my @record_array = split $self->field_separator, $line;
	if (ref $self->{field_names} eq 'ARRAY') {
	  my %record_hash;
	  @record_hash{@{$self->{field_names}}} = @record_array;
	  return wantarray ? %record_hash : \%record_hash;
	}
	return wantarray ? @record_array : \@record_array;
}

#-----------------------------------------------------------------------------

=head1 DIAGNOSTICS

<GAL::Reader::DelimitedLine> does not throw any error or warnings.  If
errors or warnings appear to be coming from GAL::Reader::Delimited it may be
that they are being throw by <GAL::Reader>

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::Reader::DelimitedLine> requires no configuration files or environment variables.

=head1 DEPENDENCIES

<GAL::Reader>

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to:
barry.moore@genetics.utah.edu

=head1 AUTHOR

Barry Moore <barry.moore@genetics.utah.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2010, Barry Moore <barry.moore@genetics.utah.edu>.  All rights reserved.

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