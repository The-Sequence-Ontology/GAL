package GAL::Parser;

use strict;
use vars qw($VERSION);


$VERSION = '0.01';
use base qw(GAL::Base);
use GAL::FeatureFactory;
use Text::RecordParser;
#use Devel::Size qw(size total_size);;

=head1 NAME

GAL::Parser - <One line description of module's purpose here>

=head1 VERSION

This document describes GAL::Parser version 0.01

=head1 SYNOPSIS

     use GAL::Parser;

=for author to fill in:
     Brief code example(s) here showing commonest usage(s).
     This section will be as far as many users bother reading
     so make it as educational and exemplary as possible.

=head1 DESCRIPTION

=for author to fill in:
     Write a full description of the module and its features here.
     Use subsections (=head2, =head3) as appropriate.


################################################################################
################################  TO DO ########################################
################################################################################

Maybe allow using using any file iterator
Maybe remove Text::RecordParser
Maybe allow using any feature_factory

################################################################################
################################################################################
################################################################################

=head1 METHODS

=cut

#-----------------------------------------------------------------------------

=head2

     Title   : new
     Usage   : GAL::Parser->new();
     Function: Creates a GAL::Parser object;
     Returns : A GAL::Parser object
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

	my $args = $self->prepare_args(@args);

	my @valid_attributes = qw(file
				  record_separator
				  field_separator
				  comment_delimiter
				  fields
				 );

	$self->set_attributes($args, @valid_attributes);

}

#-----------------------------------------------------------------------------

=head2 file

 Title   : file
 Usage   : $a = $self->file();
 Function: Get/Set the value of file.
 Returns : The value of file.
 Args    : A value to set file to.

=cut

sub file {
	my ($self, $value) = @_;
	$self->{file} = $value if defined $value;
	return $self->{file};
}

#-----------------------------------------------------------------------------

=head2 format

 Title   : format
 Usage   : $a = $self->format();
 Function: Get/Set the value of format.
 Returns : The value of format.
 Args    : A value to set format to.

=cut

sub format {
	my ($self, $value) = @_;
	$self->{format} = $value if defined $value;
	$self->{format} ||= 'generic';
	return $self->{format};
}

#-----------------------------------------------------------------------------

=head2 feature_factory

 Title   : feature_factory
 Usage   : $a = $self->feature_factory();
 Function: Get/Set the value of feature_factory.
 Returns : The value of feature_factory.
 Args    : A value to set feature_factory to.

=cut

sub feature_factory {
	my ($self, $value) = @_;
	$self->{feature_factory} = $value if defined $value;
	$self->{feature_factory} ||= GAL::FeatureFactory->new();
	return $self->{feature_factory};
}

#-----------------------------------------------------------------------------

=head2 parser

 Title   : parser
 Usage   : $a = $self->parser();
 Function: Get/Set the value of parser.
 Returns : The value of parser.
 Args    : A value to set parser to.

=cut

sub parser {
	my ($self, $value) = @_;
	$self->{parser} = $value if defined $value;
	if (! $self->{parser}) {
		my $parser = Text::RecordParser->new({filename         => $self->file,
						      record_separator => $self->record_separator,
						      field_separator  => $self->field_separator,
						      comment          => $self->comment_delimiter,
						     });
		$parser->bind_fields($self->fields);
		$self->{parser} = $parser;
	}

	return $self->{parser};
}

#-----------------------------------------------------------------------------

=head2 next_record

 Title   : next_record
 Usage   : $a = $self->next_record();
 Function: Return the next record from the parser
 Returns : The next record from the parser.
 Args    : Optionally set the method the parser will use to get the next
           record.  Default is fetchrow_hashref for Text::RecordParser.

=cut

sub next_record {
	my ($self, $method) = @_;
	return $self->parser->fetchrow_hashref;
}

#-----------------------------------------------------------------------------

=head2 get_features

 Title   : get_features
 Usage   : $features = $self->get_features();
 Function: Get all the features objects created by this parser.
 Returns : A list of Feature objects.
 Args    :

=cut

sub get_features {
	my ($self, $value) = @_;
	$self->{features} = $value if defined $value;
	return wantarray ? @{$self->{features}} : $self->{features};
}

#-----------------------------------------------------------------------------

=head2 parse

 Title   : parse
 Usage   : $a = $self->parse();
 Function: Parse and store all of the features in a file
 Returns : N/A
 Args    : N/A

=cut

sub parse {

	my $self = shift;

	while (my $record = $self->next_record) {

		my $feature_hash = $self->parse_record($record);
		next unless defined $feature_hash;
		my $type = $feature_hash->{type};
		my $feature = $self->feature_factory->create($feature_hash);
		push @{$self->{features}}, $feature;

	}
#	print STDERR "Memory:\t" . (total_size($self) / 1000000) . " MB\n";
	return $self;
}

#-----------------------------------------------------------------------------

=head2 parse_next_feature

 Title   : parse_next_feature
 Usage   : $a = $self->parse_next_feature();
 Function: Get/Set the value of parse.
 Returns : The value of parse.
 Args    : A value to set parse to.

=cut

sub parse_next_feature {

	my $self = shift;

	my $record = $self->next_record;

	my $feature_hash = $self->parse_record($record);
	return undef unless defined $feature_hash;
	my $type = $feature_hash->{type};
	my $feature = $self->feature_factory->create($feature_hash);

	return $feature;
}

#-----------------------------------------------------------------------------

=head2 record_separator

 Title   : record_separator
 Usage   : $a = $self->record_separator();
 Function: Get/Set the value of record_separator.
 Returns : The value of record_separator.
 Args    : A value to set record_separator to.

=cut

sub record_separator {
	my ($self, $value) = @_;
	$self->{record_separator} = $value if defined $value;
	$self->{record_separator} ||= "\n";
	return $self->{record_separator};
}

#-----------------------------------------------------------------------------

=head2 field_separator

 Title   : field_separator
 Usage   : $a = $self->field_separator();
 Function: Get/Set the value of field_separator.
 Returns : The value of field_separator.
 Args    : A value to set field_separator to.

=cut

sub field_separator {
	my ($self, $value) = @_;
	$self->{field_separator} = $value if defined $value;
	$self->{field_separator} ||= "\t";
	return $self->{field_separator};
}

#-----------------------------------------------------------------------------

=head2 comment_delimiter

 Title   : comment_delimiter
 Usage   : $a = $self->comment_delimiter();
 Function: Get/Set the value of comment_delimiter.
 Returns : The value of comment_delimiter.
 Args    : A value to set comment_delimiter to.

=cut

sub comment_delimiter {
	my ($self, $value) = @_;
	$self->{comment_delimiter} = $value if defined $value;
	$self->{comment_delimiter} ||= qr/^\#/;
	return $self->{comment_delimiter};
}

#-----------------------------------------------------------------------------

=head2 fields

 Title   : fields
 Usage   : $a = $self->fields();
 Function: Get/Set the value of fields.
 Returns : The value of fields.
 Args    : A value to set fields to.

=cut

sub fields {
	my ($self, $value) = @_;
	$self->{fields} = $value if defined $value;
	$self->{fields} ||= [qw(seqid source type start end score strand phase attributes)];
	return wantarray ? @{$self->{fields}} : $self->{fields};
}

#-----------------------------------------------------------------------------

=head2 parse_record

 Title   : parse_record
 Usage   : $a = $self->parse_record();
 Function: Parse the data from a record.
 Returns : A hash ref needed by Feature.pm to create a Feature object
 Args    : A hash ref of fields that this sub can understand (In this case GFF3).

=cut

sub parse_record {
	my ($self, $record) = @_;

	$record->{attributes} = $self->parse_attributes($record->{attributes});

	return $record;
}

#-----------------------------------------------------------------------------

=head2 parse_attributes

 Title   : parse_attributes
 Usage   : $a = $self->parse_attributes();
 Function: Parse the attributes from column 9 in a GFF3 style file.
 Returns : The value of parse_attributes.
 Args    : A value to set parse_attributes to.

=cut

sub parse_attributes {
	my ($self, $attrb_text) = @_;

	my @attrbs = split /\s*;\s*/, $attrb_text;
	my %attrb_hash;
	for my $attrb (@attrbs) {
		my ($key, $value_text) = split /=/, $attrb;
		my @values = split /,/, $value_text;
		push @{$attrb_hash{$key}}, @values;
	}
	return \%attrb_hash;
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

<GAL::Parser> requires no configuration files or environment variables.

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
