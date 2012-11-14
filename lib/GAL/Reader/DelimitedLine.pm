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

=item * C<< comment_pattern => "^\s*#" >>

This optional attribute provides a regular expression that will be
used to skip comment lines.  The default is "^\s*#" - lines whos first
non-whitespace charachter is a '#'.

=item * C<< header_count => 1 >>

This optional attribute provides the ability to instruct the parser to
skip header lines.  An integer i<n> value is provided that will cause
the parser to skip the first i<n> lines of the file.  The skipped
lines will be added to the L</"headers"> stack.

The following attributes are inhereted from L<GAL::Reader>:

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
	my @valid_attributes = qw(field_names field_separator end_of_data
                                  comment_pattern header_count);
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
  return $self->{field_separator};
}

#-----------------------------------------------------------------------------

=head2 end_of_data

 Title   : end_of_data
 Usage   : $self->end_of_data("^\#\#FASTA");
 Function: Set a pattern for a line that signals end of data in the file.
 Returns : The field separator as a complied regular expression.
 Args    : A string or complied regular expression pattern.

=cut

sub end_of_data {

  my ($self, $end_of_data) = @_;

  if ($end_of_data) {
    $end_of_data = qr/$end_of_data/
      unless ref $end_of_data eq 'Regexp';
  }
  $self->{end_of_data} = $end_of_data if $end_of_data;
  return $self->{end_of_data};
}

#-----------------------------------------------------------------------------

=head2 comment_pattern

 Title   : comment_pattern
 Usage   : $self->comment_pattern("^\#");
 Function: Set the field separator for spliting lines of data.  Default
           is "\t" (tab).
 Returns : The field separator as a complied regular expression.
 Args    : A string or complied regular expression pattern.

=cut

sub comment_pattern {

  my ($self, $comment_pattern) = @_;

  if ($comment_pattern) {
    $comment_pattern = qr/$comment_pattern/
      unless ref $comment_pattern eq 'Regexp';
  }
  $self->{comment_pattern} = $comment_pattern if $comment_pattern;
  $self->{comment_pattern} ||= qr/^\s*\#[^\#]/;
  return $self->{comment_pattern};
}

#-----------------------------------------------------------------------------

=head2 metadata_pattern

 Title   : metadata_pattern
 Usage   : $self->metadata_pattern("^\#");
 Function: Set the field separator for spliting lines of data.  Default
           is "\t" (tab).
 Returns : The field separator as a complied regular expression.
 Args    : A string or complied regular expression pattern.

=cut

sub metadata_pattern {

  my ($self, $metadata_pattern) = @_;

  if ($metadata_pattern) {
    $metadata_pattern = qr/$metadata_pattern/
      unless ref $metadata_pattern eq 'Regexp';
  }
  $self->{metadata_pattern} = $metadata_pattern if $metadata_pattern;
  $self->{metadata_pattern} ||= qr/^\s*\#\#/;
  return $self->{metadata_pattern};
}

#-----------------------------------------------------------------------------

=head2 header_count

 Title   : header_count
 Usage   : $self->header_count(1);
 Function: Set an value for files containing headers.  Default is undef.
           If the header attribute is set to a positive integer value then
           that many lines will be skipped from the top of the file and
           those lines will be added to the L</"headers"> stack.
 Returns : The current value of header_count
 Args    : An integer 0 or greater.

=cut

sub header_count {

  my ($self, $header_count) = @_;

  my $return_value;
  #TODO: Put a closure here to dectect if header_count is being set more
  #TODO: than once and warn.
  if ($header_count) {
    $self->{header_count} = $header_count;
  }
  $self->{header_count} ||= 0;
  return $self->{header_count};
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
    my $comment_pattern  = $self->comment_pattern;
    my $metadata_pattern = $self->metadata_pattern;
    my $field_separator  = $self->field_separator;
    my $end_of_data     = $self->end_of_data;
  LINE:
    while ($line = <$fh>) {
      if ($end_of_data && $line =~ $end_of_data) {
	$line = undef;
	last LINE
      }
	chomp $line;
	$self->{current_line} = $line;
	next if $line =~ /^\s*$/;
	if ($line =~ $metadata_pattern) {
	    $self->metadata($line);
	    next LINE;
	}
	if ($line =~ $comment_pattern) {
	    $self->comments($line);
	    next LINE;
	}
	if ($self->header_count > 0) {
	    push @{$self->{headers}}, $line;
	    $self->{header_count}--;
	    next LINE;
	}
	last;
    }
    return undef unless defined $line;
    my @record_array = split $field_separator, $line;
    if (ref $self->{field_names} eq 'ARRAY') {
	my %record_hash;
	@record_hash{@{$self->{field_names}}} = @record_array;
	return wantarray ? %record_hash : \%record_hash;
    }
    return wantarray ? @record_array : \@record_array;
}

#-----------------------------------------------------------------------------

=head2 headers

 Title   : headers
 Usage   : @headers = $reader->headers($line);
 Function: Add a line of data to the headers stack and/or return all the
           headers in the stack.
 Returns : An array or array reference of headers.
 Args    : A header.

=cut

sub headers {
	my ($self, $header) = @_;

	push @{$self->{headers}}, $header if $header;
	return wantarray ? @{$self->{headers}} : $self->{headers};
}

#-----------------------------------------------------------------------------

=head2 current_line

 Title   : current_line
 Usage   : $line = $reader->current_line();
 Function: Return the current line that the reader has most recently read.
 Returns : A string
 Args    : N/A

=cut

sub current_line {
  return shift->{current_line};
}

#-----------------------------------------------------------------------------

=head2 comments

 Title   : comments
 Usage   : $commnet = $reader->comments($line);
 Function: Add a comment (as defined by L</"comment_pattern">) to the
           comments stack or return all the comments in the stack.
 Returns : An array or array reference of comments.
 Args    : A comment.

=cut

sub comments {
	my ($self, $comment) = @_;

	push @{$self->{comments}}, $comment if $comment;
	return wantarray ? @{$self->{comments}} : $self->{comments};
}

#-----------------------------------------------------------------------------

=head2 metadata

 Title   : metadata
 Usage   : $commnet = $reader->metadata($line);
 Function: Add a comment (as defined by L</"comment_pattern">) to the
           metadata stack or return all the metadata in the stack.
 Returns : An array or array reference of metadata.
 Args    : A comment.

=cut

sub metadata {
	my ($self, $comment) = @_;

	push @{$self->{metadata}}, $comment if $comment;
	return wantarray ? @{$self->{metadata}} : $self->{metadata};
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
