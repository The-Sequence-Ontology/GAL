package GAL::Annotation;

use strict;
use warnings;

use base qw(GAL::Base);
use GAL::Schema;
use Scalar::Util qw(weaken);

use vars qw($VERSION);
$VERSION = '0.01';

=head1 NAME

GAL::Annotation - Genome Annotation Library

=head1 VERSION

This document describes GAL::Annotation version 0.01

=head1 SYNOPSIS

    use GAL::Annotation;

    my $feat_store = GAL::Annotation->new(fasta => '/path/to/fasta_dir/');

    $feat_store->load_files(files => $feature_file,
			    mode  => 'overwrite',
			   );

    my $features = $feat_store->schema->resultset('Feature');

    my $mrnas = $features->search({type => 'mRNA'});
    while (my $mrna = $mrnas->next) {
      print $mrna->feature_id . "\n";
      my $CDSs = $mrna->CDSs;
      while (my $CDS = $CDSs->next) {
	print join "\n", ($CDS->start,
			  $CDS->end,
			  $CDS->seq,
			 );
      }
    }

=head1 DESCRIPTION

The Genome Annotation Library is a collection of modules that strive
to make working with genome annotations simple, intuitive and fast.
Users of GAL first create an annotation object which in turn will
contain Parser, Storage and Schema objects.  The parser allows
features to be loaded into GAL's storage from a variety of formats.
The storage object specifies how the features should be stored, and
the schema object provides flexible query and iteration functions over
the features.  In addtion, Index objects (not yet implimented) provide
additional key/value mapped look up tables, and List objects provide
aggregation and analysis functionality for lists of feature
attributes.

A wide variety of parsers are available to convert sequence features
from various formats, and new parsers are easy to write.  See
GAL::Parser for more details.  Currently MySQL and SQLite storage
options are available (a fast RAM storage engine is on the TODO list).
Schema objects are provided by DBIx::Class and a familiarity with that
package is necessary to understanding how to query and iterate over
feature objects.

=head1 CONSTRUCTOR

New Annotation objects are created by the class method new.  Arguments
should be passed to the constructor as a list (or reference) of key
value pairs.  All attributes of the Annotation object can be set in
the call to new, but reasonable defaults will be used where ever
possilbe to keep object creation simple.  An simple example of object
creation would look like this:

    my $feat_store = GAL::Annotation->new();

The resulting object would use a GFF3 parser and SQLite storage by
default and it would not have access to feature sequence.

A more complex object creation might look like this:

    my $feat_store = GAL::Annotation->new(parser  => {class => gff3},
					  storage => {class => mysql,
						      dsn   => 'dbi:mysql:database'
						      user  => 'me',
						      password => 'secret'
					  fasta   =>  '/path/to/fasta/files/'
					  );

The constructor recognizes the following parameters which will set the
appropriate attributes:

=over 4

=item * C<< parser => parser_subclass [gff3] >>

This optional parameter defines which parser subclass to instantiate.
This parameter will default to gff3 if not provided.  See GAL::Parser
for a complete list of available parser classes.

=item * C<< storage => storage_subclass [SQLite] >>

This optional parameter defines which storage subclass to instantiate.
Currently available storage classes are SQLite (the default) and
mysql.

=item * C<< fasta => '/path/to/fasta/files/ >>

This optional parameter defines a path to a collection of fasta files
that correspond the annotated features.  The IDs (first contiguous
non-whitespace charachters) of the fasta headers must correspond to
the sequence IDs (seqids) in the annotated features.  The fasta
parameter is optional, but if the fasta attribute is not set then the
features will not have access to their sequence.  Access to the
sequence in provided by Bio::DB::Fasta.

=cut

#-----------------------------------------------------------------------------
#-------------------------------- Constructor --------------------------------
#-----------------------------------------------------------------------------

=head2 new

     Title   : new
     Usage   : GAL::Annotation->new();
     Function: Creates a GAL::Annotation object;
     Returns : A GAL::Annotation object
     Args    : A list of key value pairs for the attributes specified above.

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
	my @valid_attributes = qw(parser storage);
	$self->set_attributes($args, @valid_attributes);
	######################################################################
}

#-----------------------------------------------------------------------------
#-------------------------------- Attributes ---------------------------------
#-----------------------------------------------------------------------------

=head1  ATTRIBUTES

All attributes can be supplied as parameters to the GAL::Annotation
constructor as a list (or referenece) of key value pairs.

=cut

=head2 parser

 Title   : parser
 Usage   : $parser = $self->parser();
 Function: Create or return a parser object.
 Returns : A GAL::Parser::subclass object.
 Args    : (class => gal_parser_subclass)
	   See GAL::Parser and it's subclasses for more arguments.
 Notes   : The parser object is created as a singleton, but it
	   can be changed by passing new arguments to a call to
	   parser.

=cut

sub parser {
  my ($self, @args) = @_;

  if (! $self->{parser} || @args) {
      my $args = $self->prepare_args(@args);
      my $class = $args->{class} || 'gff3';
      $class =~ s/GAL::Parser:://;
      $class = 'GAL::Parser::' . $class;
      $self->load_module($class);
      my $parser = $class->new(@args);
      my $weak_self = $self;
      weaken $weak_self;
      $parser->annotation($weak_self);
      $self->{parser} = $parser;
  }
  return $self->{parser};
}

#-----------------------------------------------------------------------------

=head2 storage

  Title   : storage
  Usage   : $storage = $self->storage();
  Function: Create or return a storage object.
  Returns : A GAL::Storage::subclass object.
  Args    : (class => gal_storage_subclass)
	    See GAL::Storage and it's subclasses for more arguments.
  Notes   : The storage object is created as a singleton and can not be
	    destroyed or recreated after being created.

=cut

sub storage {
    my ($self, @args) = @_;

    if (! $self->{storage}) {
	my $args = $self->prepare_args(@args);
	my $class = $args->{class} || 'SQLite';
	$class =~ s/GAL::Storage:://;
	$class = 'GAL::Storage::' . $class;
	$self->load_module($class);
	my $storage = $class->new(@args);
	my $weak_self = $self;
	weaken $weak_self;
	$storage->annotation($weak_self);
	$self->{storage} = $storage;
    }
    return $self->{storage};
}


=head2 fasta

The fasta attribute is provided by GAL::Base, see that module for more
details.

=cut

#-----------------------------------------------------------------------------
#---------------------------------- Metohds ----------------------------------
#-----------------------------------------------------------------------------

=head1 Methods


=head2 schema

  Title   : schema
  Usage   : $self->schema();
  Function: Create and/or return the DBIx::Class::Schema object
  Returns : DBIx::Class::Schema object.
  Args    : N/A - Arguments are provided by the GAL::Storage object.

=cut

sub schema {
    my $self = shift;

    # Create the schema if it doesn't exist
    if (! $self->{schema}) {
	# We should be able to reuse the Annotation dbh here!
	# my $schema = GAL::Schema->connect([sub {$self->storage->dbh}]);
	my $schema = GAL::Schema->connect($self->storage->dsn,
					  $self->storage->user,
					  $self->storage->password,
					  );
	# If we're using SQLite we should be using a larger cache_size;
	# but why doesn't this seem to help?  Do this in the Storage object
	# $schema->storage->dbh_do(sub {
	#			     my ($storage, $dbh) = @_;
	#			     $dbh->do('PRAGMA cache_size = 800000');
	#			   },
	#			  );
	my $weak_self = $self;
	weaken $weak_self;
	$schema->annotation($weak_self); # See GAL::SchemaAnnotation
	$self->{schema} = $schema;
    }
    return $self->{schema};
}

#-----------------------------------------------------------------------------

=head2 load_files

 Title   : load_files
 Usage   : $a = $self->load_files();
 Function: Parse and store all of the features in a file.
 Returns : N/A
 Args    : (files => \@feature_files,
	    mode  => 'overwrite',
	   )
 Notes   : Default

=cut

sub load_files {
  my ($self, @args) = @_;
  my $args = $self->prepare_args(\@args);
  my ($mode, $files) = @{$args}{qw/mode files/};
  $mode ||= 'append';
  if ($mode eq 'overwrite') {
    $self->storage->drop_database;
    $self->storage->load_files($files);
  }
  elsif ($mode eq 'append') {
    $self->storage->load_files($files);
  }
}

# #-----------------------------------------------------------------------------
#
# =head2 add_feature
#
#  Title   : add_feature
#  Usage   : $self->add_feature();
#  Function: Get/Set value of add_feature.
#  Returns : Value of add_feature.
#  Args    : Value to set add_feature to.
#
# =cut
#
# sub add_feature {
#	my ($self, $feature_hash) = @_;
#	my $feature = $self->storage->add_feature($feature_hash);
#	return $feature;
# }
#
# #-----------------------------------------------------------------------------
#
# =head2 get_all_features
#
#  Title   : get_all_features
#  Usage   : $self->get_all_features();
#  Function: Get/Set value of get_all_features.
#  Returns : Value of get_all_features.
#  Args    : Value to set get_all_features to.
#
# =cut
#
# sub get_all_features {
#	my $self = shift;
#	my $features = $self->storage->get_all_features;
#	return wantarray ? @{$features} : $features;
# }
#
# #-----------------------------------------------------------------------------
#
# =head2 get_features_by_type
#
#  Title   : get_features_by_type
#  Usage   : $self->get_features_by_type();
#  Function: Get/Set value of get_features_by_type.
#  Returns : Value of get_features_by_type.
#  Args    : Value to set get_features_by_type to.
#
# =cut
#
# sub get_features_by_type {
#	my ($self, $type) = @_;
#	my $features = $self->storage->get_features_by_type($type);
#	return wantarray ? @{$features} : $features;
# }
#
# #-----------------------------------------------------------------------------
#
# =head2 get_recursive_features_by_type
#
#  Title   : get_recursive_features_by_type
#  Usage   : $self->get_recursive_features_by_type();
#  Function: Get/Set value of get_recursive_features_by_type.
#  Returns : Value of get_recursive_features_by_type.
#  Args    : Value to set get_recursive_features_by_type to.
#
# =cut
#
# sub get_recursive_features_by_type {
#	my ($self, $type) = @_;
#	my $features = $self->storage->get_features_by_type_recursive;
#	return wantarray ? @{$features} : $features;
# }
#
# #-----------------------------------------------------------------------------
#
# =head2 get_feature_by_id
#
#  Title   : get_feature_by_id
#  Usage   : $self->get_feature_by_id();
#  Function: Get/Set value of get_feature_by_id.
#  Returns : Value of get_feature_by_id.
#  Args    : Value to set get_feature_by_id to.
#
# =cut
#
# sub get_feature_by_id {
#	my ($self, $id) = @_;
#	my $feature = $self->storage->get_feature_by_id($id);
#	return $feature;
# }
#
# #-----------------------------------------------------------------------------
#
# =head2 filter_features
#
#  Title   : filter_features
#  Usage   : $self->filter_features();
#  Function: Get/Set value of filter_features.
#  Returns : Value of filter_features.
#  Args    : Value to set filter_features to.
#
# =cut
#
# sub filter_features {
#	my ($self, $filter) = @_;
#	my $features = $self->storage->filter_features($filter);
#	return wantarray ? @{$features} : $features;
# }
#
#
# #-----------------------------------------------------------------------------
#
# =head2 foo
#
#  Title   : foo
#  Usage   : $a = $self->foo();
#  Function: Get/Set the value of foo.
#  Returns : The value of foo.
#  Args    : A value to set foo to.
#
# =cut
#
# sub foo {
#	my ($self, $value) = @_;
#	$self->{foo} = $value if defined $value;
#	return $self->{foo};
# }
#
# #-----------------------------------------------------------------------------

=head1 DIAGNOSTICS

<GAL::Annotation> currently does not throw any warnings or errors, but
most other modules in the library do, and details of those errors can
be found in those modules.

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::Annotation> requires no configuration files or environment variables.

=head1 DEPENDENCIES

Modules in GAL/lib use the following modules:

Bio::DB::Fasta
Carp
DBD::SQLite
DBD::mysql
DBI
File::Temp
List::Util
Scalar::Util
Set::IntSpan::Fast
Statistics::Descriptive
Text::RecordParser

Some script in GAL/bin and/or GAL/lib/GAL/t use the following modules:

Data::Dumper
FileHandle
Getopt::Long
Getopt::Std
IO::Prompt
List::MoreUtils
TAP::Harness
Test::More
Test::Pod::Coverage
URI::Escape
XML::LibXML::Reader

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

I'm sure there are plenty of bugs right now - please let me know if you find one.

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

1;
