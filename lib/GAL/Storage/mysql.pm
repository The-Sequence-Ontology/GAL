package GAL::Storage::mysql;

use strict;
use vars qw($VERSION);

$VERSION = '0.01';
use base qw(GAL::Storage);
use DBI;

=head1 NAME

GAL::Storage::mysql - MySQL feature storage for GAL

=head1 VERSION

This document describes GAL::Storage::mysql version 0.01

=head1 SYNOPSIS

    use GAL::Storage::mysql;
    my $storage = GAL::Storage::mysql->new(dsn => 'dbi:mysql:db_name');

=head1 DESCRIPTION

The L<GAL::Storage::SQLite> class provides SQLite based storage to
GAL.

=head1 CONSTRUCTOR

New GAL::Storage::mysql objects are created by the class method new.
Arguments should be passed to the constructor as a list (or reference)
of key value pairs.  All attributes of the Storage object can be set
in the call to new. An simple example of object creation would look
like this:

    my $parser = GAL::Storage::mysql->new(dsn => 'dbi:mysql:db_name);

The constructor recognizes the following parameters which will set the
appropriate attributes:

=over 4

=item * C<scheme>

This is a read only parameter that is set to 'DBI';

=item * C<driver >

This is a read only parameter that is set to 'SQLite';

=item * C<database>

database => 'db_name'

This optional parameter defines the database name.  You don't need to
specify both the database name and the dsn as they both contain the
database name. Since the driver and the scheme are set by the class
you could give either the dsn or the database name and it will work.

B<The following attributes are inherited from> L<GAL::Storage>

=item * C<annotation>

This is a read only attribute that provides access to a weakened
version of the L<GAL::Annotation> object that created this storage

=item * C<dsn => 'dbi:SQLite:db_name'>

dsn => 'dbi:mysql:db_name

This optional parameter defines the data source name of the database
to open.  By default Storage will use and SQLite database with a
random filename, but see the comment for the database attribute below.

=item * C<user => 'user_name'>

This optional parameter defines the user name for connecting to the
database.

=item * C<password => 'password'>

This optional parameter defines the password for connecting to the
database.

=back

=head1 METHODS

=cut

#-----------------------------------------------------------------------------

=head2 new

     Title   : new
     Usage   : GAL::Storage::SQLite->new();
     Function: Creates a Storage object;
     Returns : A L<GAL::Storage::mysql> object
     Args    : See the attributes described above.

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
  my @valid_attributes = qw();
  $self->set_attributes($args, @valid_attributes);
  ######################################################################
}

#-----------------------------------------------------------------------------

=head2 scheme

 Title   : scheme
 Usage   : $a = $self->scheme();
 Function: Return the RDMS scheme.
 Returns : DBI
 Args    : N/A

=cut

sub scheme {'dbi'}

#-----------------------------------------------------------------------------

=head2 driver

 Title   : driver
 Usage   : $a = $self->driver();
 Function: Get the value of driver.
 Returns : mysql
 Args    : N/A

=cut

sub driver {'mysql'}

#-----------------------------------------------------------------------------

=head2 dbh

 Title   : dbh
 Usage   : $a = $self->dbh();
 Function: Get/Set the database handle
 Returns : The a DBI::mysql object
 Args    : A DBI::mysql object

=cut

sub dbh {

  my $self = shift;
  $self->{dbh} ||= $self->_open_or_create_database;
  return $self->{dbh};
}

=head2 database

 Title   : database
 Usage   : $a = $self->database();
 Function: Get/Set the database name.
 Returns : A database name.
 Args    : A database name.

=cut

sub database {
      my ($self, $database) = @_;

      if (! $database && ! $self->{database}) {
	$database = $self->random_string . '.mysql';
      }
      $self->{database} = $database if $database;
      return $self->{database};
}

#-----------------------------------------------------------------------------
#
# TODO: Fix up GAL::Storage::mysql::add_features
#
# =head2 add_features
#
#  Title   : add_features
#  Usage   : $self->add_features();
#  Function: Get/Set value of add_features.
#  Returns : Value of add_features.
#  Args    : Value to set add_features to.
#
# =cut
#
# sub add_features {
#   my ($self, $feature_hash) = @_;
#   $self->not_implemented('add_features');
#
#
#   $features = ref $features ? $features : [$features];
#
#   my ($features, $attributes) = $self->prepare_features($features);
#
#   my $feat_stmt = ('INSERT INTO feature   (feature_id, seqid, source, ' .
#		   'type, start, end, score, strand, phase, name) ' .
#		   'VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
#		  );
#   my $feat_sth = $dbh->prepare($feat_stmt);
#
#   my $sth_stmt = ('INSERT INTO attribute (feature_id, att_key, att_value) ' .
#		  'VALUES(?, ?, ?)'
#		 );
#   my $sth_attr = $dbh->prepare($sth_stmt);
#
#   for my $feature (@{$features}) {
#     $sth_feat->execute(@{$feature}) or die $sth_feat->errstr;
#   }
#
#   for my $attribute (@{$attributes}) {
#     $sth_attr->execute(@{$attribute}) or die $sth_attr->errstr;
#   }
#
# }
#
#-----------------------------------------------------------------------------

=head2 drop_database

  Title   : drop_database
  Usage   : $self->drop_database();
  Function: Drop the database;
  Returns : Nothing
  Args    : None

=cut

sub drop_database {

  my $self = shift;

  my @databases = DBI->data_sources($self->driver,
				    {user     => $self->user,
				     password => $self->password,
				    }
				   );
  my $dbh;
  my $dsn = $self->dsn;
  my $database = $self->database;
  if (grep {$_ eq $dsn} @databases) {
    my $drh = DBI->install_driver("mysql");
    my $host = ''; # Defaults to localhost, abstract this later.
    my $rc = $drh->func('dropdb',
			$database,
			$host,
			$self->user,
			$self->password,
			'admin');
  }
  return;
}
#-----------------------------------------------------------------------------

=head2 _open_or_create_database

 Title   : _open_or_create_database
 Usage   : $self->_open_or_create_database();
 Function: Create the database if it doesnt exists.
 Returns : A DBD::mysql object
 Args    : None

=cut

sub _open_or_create_database {
  my $self = shift;

  my @databases = DBI->data_sources($self->driver,
				    {user     => $self->user,
				     password => $self->password,
				    }
				   );

  my $dbh;
  my $dsn = $self->dsn;
  my $database = $self->database;
  if (! grep {$_ eq $dsn} @databases) {
    my $drh = DBI->install_driver("mysql");
    my $host = ''; # Defaults to localhost, abstract this later.
    my $rc = $drh->func('createdb',
			$database,
			$host,
			$self->user,
			$self->password,
			'admin');

    $dbh = DBI->connect($self->dsn, $self->user,
			$self->password);

    # TODO: Write GAL::Storage::mysql::_load_schema
    $self->_load_schema($dbh);
  }
  else {
    $self->warn(message => ("A database by the name $database already "      .
			    "existed, so I'll use it as is."
			   ),
		code    => "using_existing_database : $database");
    $dbh = DBI->connect($self->dsn, $self->user,
			$self->password);
  }
  return $dbh;
}

#-----------------------------------------------------------------------------

=head2 index_database

 Title   : index_database
 Usage   : $self->index_database();
 Function: Create indeces on the database.
 Returns : Nothing
 Args    : None

=cut

sub index_database {

  my $self = shift;
  my $dbh  = $self->dbh;

  # Create feature indeces
  $dbh->do("CREATE INDEX feat_feature_id_index USING BTREE ON feature (feature_id)");
  # $dbh->do("CREATE INDEX feat_seqid_start_end_index USING BTREE ON feature (seqid, start, end)");
  $dbh->do("CREATE INDEX feat_bin_index USING BTREE ON feature (bin)");
  # $dbh->do("CREATE INDEX feat_type_index USING BTREE ON feature (type)");

  # Create attribute indeces
  $dbh->do("CREATE INDEX att_feature_id_index USING BTREE ON attribute (feature_id)");
  # $dbh->do("CREATE INDEX att_key_value_index USING BTREE ON attribute (att_key, att_value)");

  # Create relationship indeces
  $dbh->do("CREATE INDEX rel_parent_index USING BTREE ON relationship (parent)");
  $dbh->do("CREATE INDEX rel_child_index  USING BTREE ON relationship (child)");

}

#-----------------------------------------------------------------------------

# Title   : _load_temp_files
# Usage   : $self->_load_temp_files();
# Function: Load the temporary data files into the database
# Returns : Nothing
# Args    : Three file names for the feature, attribute and relationship
#           temporary data files.

sub _load_temp_files {

  my ($self, $feat_filename, $att_filename, $rel_filename) = @_;

  my $dbh = $self->dbh;

  $dbh->do("LOAD DATA INFILE '$feat_filename' INTO TABLE feature " .
	   "(subject_id, feature_id, seqid, source, type, start, " .
	   "end, score, strand, phase, bin)");
  $dbh->do("LOAD DATA INFILE '$att_filename'  INTO TABLE attribute " .
	   "(attribute_id, subject_id, feature_id, att_key, att_value)");
  $dbh->do("LOAD DATA INFILE '$rel_filename'  INTO TABLE relationship " .
	   "(subject_id, parent, child)");
  $self->index_database;
}

##-----------------------------------------------------------------------------
#
#=head2 get_children
#
# Title   : get_children
# Usage   : $self->get_children();
# Function: Get/Set value of get_children.
# Returns : Value of get_children.
# Args    : Value to set get_children to.
#
#=cut
#
#sub get_children {
#	my $self = shift;
#	$self->not_implemented('get_children');
#}
#
##-----------------------------------------------------------------------------
#
#=head2 get_children_recursively
#
# Title   : get_children_recursively
# Usage   : $self->get_children_recursively();
# Function: Get/Set value of get_children_recursively.
# Returns : Value of get_children_recursively.
# Args    : Value to set get_children_recursively to.
#
#=cut
#
#sub get_children_recursively {
#  my $self = shift;
#  $self->not_implemented('get_children_recursively');
#}
#
##-----------------------------------------------------------------------------
#
#=head2 get_parents
#
# Title   : get_parents
# Usage   : $self->get_parents();
# Function: Get/Set value of get_parents.
# Returns : Value of get_parents.
# Args    : Value to set get_parents to.
#
#=cut
#
#sub get_parents {
#  my $self = shift;
#  $self->not_implemented('get_parents');
#}
#
##-----------------------------------------------------------------------------
#
#=head2 get_parents_recursively
#
# Title   : get_parents_recursively
# Usage   : $self->get_parents_recursively();
# Function: Get/Set value of get_parents_recursively.
# Returns : Value of get_parents_recursively.
# Args    : Value to set get_parents_recursively to.
#
#=cut
#
#sub get_parents_recursively {
#  my $self = shift;
#  $self->not_implemented('get_parents_recursively');
#}
#
##-----------------------------------------------------------------------------
#
#=head2 get_all_features
#
# Title   : get_all_features
# Usage   : $self->get_all_features();
# Function: Get/Set value of get_all_features.
# Returns : Value of get_all_features.
# Args    : Value to set get_all_features to.
#
#=cut
#
#sub get_all_features {
#  my $self = shift;
#  $self->not_implemented('get_all_features');
#}
#
##-----------------------------------------------------------------------------
#
#=head2 get_features_by_type
#
# Title   : get_features_by_type
# Usage   : $self->get_features_by_type();
# Function: Get/Set value of get_features_by_type.
# Returns : Value of get_features_by_type.
# Args    : Value to set get_features_by_type to.
#
#=cut
#
#sub get_features_by_type {
#  my $self = shift;
#  $self->not_implemented('get_features_by_type');
#}
#
##-----------------------------------------------------------------------------
#
#=head2 get_recursive_features_by_type
#
# Title   : get_recursive_features_by_type
# Usage   : $self->get_recursive_features_by_type();
# Function: Get/Set value of get_recursive_features_by_type.
# Returns : Value of get_recursive_features_by_type.
# Args    : Value to set get_recursive_features_by_type to.
#
#=cut
#
#sub get_recursive_features_by_type {
#  my $self = shift;
#  $self->not_implemented('get_recursive_features_by_type');
#}
#
##-----------------------------------------------------------------------------
#
#=head2 get_feature_by_id
#
# Title   : get_feature_by_id
# Usage   : $self->get_feature_by_id();
# Function: Get/Set value of get_feature_by_id.
# Returns : Value of get_feature_by_id.
# Args    : Value to set get_feature_by_id to.
#
#=cut
#
#sub get_feature_by_id {
#  my $self = shift;
#  $self->not_implemented('get_feature_by_id');
#}
#
##-----------------------------------------------------------------------------
#
#=head2 filter_features
#
# Title   : filter_features
# Usage   : $self->filter_features();
# Function: Get/Set value of filter_features.
# Returns : Value of filter_features.
# Args    : Value to set filter_features to.
#
#=cut
#
#sub filter_features {
#  my $self = shift;
#  $self->not_implemented('filter_features');
#}
#
##-----------------------------------------------------------------------------
#
#=head2 foo
#
# Title   : foo
# Usage   : $a = $self->foo();
# Function: Get/Set the value of foo.
# Returns : The value of foo.
# Args    : A value to set foo to.
#
#=cut
#
#sub foo {
#	my ($self, $value) = @_;
#	$self->{foo} = $value if defined $value;
#	return $self->{foo};
#}
#
##-----------------------------------------------------------------------------

=head1 DIAGNOSTICS

=over

=item C<using_existing_database>

A database by the same name specified already existed and you haven't
asked for it to be overwritten, so it will be used and possible
appended to.  If you want to overwrite this database you should use
the attribute C<mode => overwrite> when you create the storage object.

=back

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::Storage::mysql> requires no configuration files or environment variables.

=head1 DEPENDENCIES

L<GAL::Storage>
L<DBI>
L<DBD::mysql>

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to:
barry.moore@genetics.utah.edu

=head1 AUTHOR

Barry Moore <barry.moore@genetics.utah.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2010, Barry Moore <barry.moore@genetics.utah.edu>.  All
rights reserved.

    This module is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT
WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER
PARTIES PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND,
EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE
SOFTWARE IS WITH YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME
THE COST OF ALL NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE LIABLE
TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE
SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH
DAMAGES.

=cut

1;
