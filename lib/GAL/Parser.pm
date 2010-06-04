package GAL::Parser;

use strict;
use vars qw($VERSION);


$VERSION = '0.01';
use base qw(GAL::Base);
use Text::RecordParser;

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

=head1 METHODS

=cut

#-----------------------------------------------------------------------------
#-------------------------------- Constructor --------------------------------
#-----------------------------------------------------------------------------

=head2 new

     Title   : new
     Usage   : GAL::Parser->new();
     Function: Creates a GAL::Parser object;
     Returns : A GAL::Parser object
     Args    :

=cut

sub new {
	my ($class, @args) = @_;
	my $self = $class->SUPER::new(@args);
	my $class = $self->class;
	bless $self, $class;
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
	my @valid_attributes = qw(annotation class fh file);
	$self->set_attributes($args, @valid_attributes);
	######################################################################
	return $args;
}

#-----------------------------------------------------------------------------
#-------------------------------- Attributes ---------------------------------
#-----------------------------------------------------------------------------

=head2 annotation

 Title   : annotation
 Usage   : $a = $self->annotation()
 Function: Get/Set the value of annotation.
 Returns : The value of annotation.
 Args    : A value to set annotation to.

=cut

sub annotation {
  my ($self, $annotation) = @_;
  $self->{annotation} = $annotation if $annotation;
  return $self->{annotation};
}

#-----------------------------------------------------------------------------

=head2 class

 Title   : class
 Usage   : $a = $self->class()
 Function: Get/Set the value of class.
 Returns : The value of class.
 Args    : A value to set class to.

=cut

sub class {
  my ($self, $class) = @_;
  
  if ($class) {
      $class =~ s/GAL::Parser:://;
      $class = 'GAL::Parser::' . $class;
      $self->{class} = $class;
  }
  $self->{class} ||= 'GAL::Parser::gff3';
  return $self->{class};
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
	my ($self, $file) = @_;
	return $self->reader->file($file);
}

#-----------------------------------------------------------------------------

=head2 fh

 Title   : fh
 Usage   : $a = $self->fh();
 Function: Get/Set the filehandle.
 Returns : The filehandle.
 Args    : A filehandle.

=cut

sub fh {
  my ($self, $fh) = @_;
  return $self->reader->fh($fh);
}

#-----------------------------------------------------------------------------

=head2 reader

 Title   : reader
 Usage   : $a = $self->reader();
 Function: Get/Set the reader.  This is left as a public
	   method to support future use of alternate readers, but
	   this is currently not implimented so this method should be
	   considered for internal use only.
 Returns : The value of reader.
 Args    : A value to set reader to.

=cut

sub reader {
	my ($self, $reader) = @_;
	$self->{reader} = $reader if $reader;
	return $self->{reader};
}

#-----------------------------------------------------------------------------
#---------------------------------- Methods ----------------------------------
#-----------------------------------------------------------------------------

=head2 next_record

 Title   : next_record
 Usage   : $a = $self->next_record();
 Function: Return the next record from the parser
 Returns : The next record from the parser.
 Args    : N/A

=cut

sub next_record {
	shift->reader->next_record;
}

#-----------------------------------------------------------------------------

=head2 next_feature_hash

 Title   : next_feature_hash
 Usage   : $a = $self->next_feature_hash;
 Function: Return the next record from the parser as a 'feature hash'.
 Returns : A hash or hash reference.
 Args    : N/A

=cut

sub next_feature_hash {
	my $self = shift;

	my $feature;

	# If a previous record has returned multiple features then
	# grab them off the stack first instead of reading a new one
	# from the file.
	if (ref $self->{_feature_stack} eq 'ARRAY' &&
	    scalar @{$self->{_feature_stack}} > 0) {
		$feature = shift @{$self->{_feature_stack}};
		return wantarray ? %{$feature} : $feature;
	}

	# Allow parse_record to return undef to ignore a record, but
	# still keep parsing the file.
	until ($feature) {
		# Get the next record from the file.
		my $record = $self->next_record;
		return undef if ! defined $record;

		# Parser the record - probably overridden by a subclass.
		$feature = $self->parse_record($record);
	}

	# Allow parsers to return more than one feature.
	# This allows the parser to expand a single record into
	# multiple features.
	if (ref $feature eq 'ARRAY') {
		my $this_feature = shift @{$feature};
		push @{$self->{_feature_stack}}, @{$feature};
		$feature = $this_feature;
	}

	return wantarray ? %{$feature} : $feature;
}

#-----------------------------------------------------------------------------

=head2  to_gff3

 Title   : to_gff3
 Usage   : $self->to_gff3($feature_hash)
 Function: Returns a string of GFF3 formatted text for a given feature hash
 Returns : A string in GFF3 format.
 Args    : A feature hash reference in the form returned by next_feature_hash

=cut

sub to_gff3 {
	my ($self, $feature) = @_;

	my %ATTRB_ORDER = (ID             	 => 1,
			   Name           	 => 2,
			   Alias          	 => 3,
			   Parent         	 => 3,
			   Target         	 => 4,
			   Gap            	 => 5,
			   Derives_from   	 => 6,
			   Note           	 => 7,
			   Dbxref         	 => 8,
			   Ontology_term  	 => 9,
			   Variant_seq    	 => 10,
			   Reference_seq  	 => 11,
			   Variant_reads  	 => 12,
			   Total_reads    	 => 13,
			   Genotype       	 => 14,
			   Variant_effect 	 => 15, 
			   Variant_copy_number   => 16,
			   Reference_copy_number => 17,
			   );

	my $attribute_text;
	for my $key (sort {($ATTRB_ORDER{$a} || 99) <=> ($ATTRB_ORDER{$b} || 99) ||
			       $a cmp $b}
		     keys %{$feature->{attributes}}) {
	    my $value_text = join ',', @{$feature->{attributes}{$key}};
	    $attribute_text .= "$key=$value_text;";
	}

	my $gff3_text = join "\t", ($feature->{seqid},
				    $feature->{source},
				    $feature->{type},
				    $feature->{start},
				    $feature->{end},
				    $feature->{score},
				    $feature->{strand},
				    $feature->{phase},
				    $attribute_text,
				   );

	return $gff3_text;
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

	my $attributes = $self->parse_attributes($record->{attributes});

	my $feature_id = $attributes->{id} || join ':',
	  @{$record}{qw(seqid source type start)};

	my $feature_hash = {feature_id => $feature_id,
			    seqid      => $record->{seqid},
			    source     => $record->{source},
			    type       => $record->{type},
			    start      => $record->{start},
			    end        => $record->{end},
			    score      => $record->{score},
			    strand     => $record->{strand},
			    phase      => $record->{phase},
			    attributes => $attributes,
			   };

	return $feature_hash;
}

#-----------------------------------------------------------------------------

=head2 parse_attributes

 Title   : parse_attributes
 Usage   : $a = $self->parse_attributes($attrb_text);
 Function: Parse the attributes from column 9 in a GFF3 style file.
 Returns : The value of parse_attributes.
 Args    : A value to set parse_attributes to.

=cut

sub parse_attributes {
	my ($self, $attrb_text) = @_;

	my @attrbs = split /\s*;\s*/, $attrb_text;
	my %attrb_hash;
	for my $attrb (@attrbs) {
		my ($tag, $value_text) = split /=/, $attrb;
		my @values = split /,/, $value_text;
		push @{$attrb_hash{$tag}}, @values;
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
