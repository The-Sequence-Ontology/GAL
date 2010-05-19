package GAL::Storage;

use strict;
use vars qw($VERSION);


$VERSION = '0.01';
use base qw(GAL::Base);
use DBI;

=head1 NAME

GAL::Storage - <One line description of module's purpose here>

=head1 VERSION

This document describes GAL::Storage version 0.01

=head1 SYNOPSIS

     use GAL::Storage;

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
     Usage   : GAL::Storage->new()
     Function: Creates a Storage object;
     Returns : A Storage object
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
	my @valid_attributes = qw(dsn user password);
	$self->set_attributes($args, @valid_attributes);
	######################################################################
}

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

=head2 dsn

 Title   : dsn
 Usage   : $a = $self->dsn()
 Function: Get/Set the value of dsn.
 Returns : The value of dsn.
 Args    : A value to set dsn to.

=cut

sub dsn {
	my ($self, $dsn) = @_;

	if ($self->{dsn} && ! $dsn) {
		return $self->{dsn};
	}

	# If we don't have a dsn, then create one
	$dsn ||= '';
	my ($scheme, $driver, $attr_string, $attr_hash, $driver_dsn)
	  = DBI->parse_dsn($dsn);
	$scheme = $self->scheme;
	my $self_driver = $self->driver;
	$self->warn(message => ("Warn : conflicting_db_drivers " .
				": You gave: $driver, using $self_driver instead\n"
			       )
		   )
	  if $self_driver ne $driver;
	$driver = $self->driver($driver);

	my ($database, %attributes);
	if ($driver_dsn =~ /=/) {
	  my %attributes = map {split /=/} split /;/, $driver_dsn;
	  $database = $attributes{dbname} || $attributes{database};
	}
	else {
	  $database = $driver_dsn;
	}

	$database = $self->database($database);
	my $attribute_txt = '';
	map {$attribute_txt .= $_ . '=' . $attributes{$_} . ';'} keys %attributes;

	$self->{dsn} = join ':', ($scheme, $driver, $database, $attribute_txt);
	$self->{dsn} =~ s/:$//;

	return $self->{dsn};
}

#-----------------------------------------------------------------------------

=head2 scheme

 Title   : scheme
 Usage   : $a = $self->scheme()
 Function: Get/Set the value of scheme.
 Returns : The value of scheme.
 Args    : A value to set scheme to.

=cut

sub scheme {
	my $self = shift;
	$self->throw(message => ('Method must be implimented by subclass : ' .
				 'scheme')
		    );
}

#-----------------------------------------------------------------------------

=head2 user

 Title   : user
 Usage   : $a = $self->user()
 Function: Get/Set the value of user.
 Returns : The value of user.
 Args    : A value to set user to.

=cut

sub user {
	my ($self, $user) = @_;
	$self->{user} = $user if $user;
	return $self->{user};
}

#-----------------------------------------------------------------------------

=head2 password

 Title   : password
 Usage   : $a = $self->password()
 Function: Get/Set the value of password.
 Returns : The value of password.
 Args    : A value to set password to.

=cut

sub password {
	my ($self, $password) = @_;
	$self->{password} = $password if $password;
	return $self->{password};
}

#-----------------------------------------------------------------------------

=head2 database

 Title   : database
 Usage   : $a = $self->database();
 Function: Get/Set the value of database.
 Returns : The value of database.
 Args    : A value to set database to.

=cut

sub database {
      my ($self, $database) = @_;

      $self->{database} = $database if $database;
      $self->{database} ||= join '_', ('gal_database',
				       $self->time_stamp,
				       $self->random_string(8)
				      );
      return $self->{database};
}

#-----------------------------------------------------------------------------

=head2 driver

 Title   : driver
 Usage   : $a = $self->driver()
 Function: Get/Set the value of driver.
 Returns : The value of driver.
 Args    : A value to set driver to.

=cut

sub driver {

  my $self = shift;
	$self->throw(message => ('Method driver must be implimented by subclass : ' .
				 'driver')
		    );
}

#-----------------------------------------------------------------------------

=head2 _load_schema

 Title   : _load_schema
 Usage   : $self->_load_schema();
 Function: Get/Set value of _load_schema.
 Returns : Value of _load_schema.
 Args    : Value to set _load_schema to.

=cut

sub _load_schema {
  my ($self, $dbh) = @_;

  my $self = shift;
  $self->throw(message => ('Method _load_schema must be implimented by subclass : ' .
			   'driver')
	      );

  # $dbh->do("DROP TABLE IF EXISTS feature");
  # $dbh->do("DROP TABLE IF EXISTS attribute");
  # $dbh->do("DROP TABLE IF EXISTS relationship");
  # $dbh->do("CREATE TABLE feature ("    .
  #	   "subject_id VARCHAR(255), " .
  #	   "feature_id VARCHAR(255), " .
  #	   "seqid      VARCHAR(255), " .
  #	   "source     VARCHAR(255), " .
  #	   "type       VARCHAR(255), " .
  #	   "start      INT, "          .
  #	   "end        INT, "          .
  #	   "score      VARCHAR(255), " .
  #	   "strand     VARCHAR(1), "   .
  #	   "phase      VARCHAR(1),"    .
  #	   "bin        VARCHAR(15))"
  #	  );
  # $dbh->do("CREATE TABLE attribute ("  .
  #	   "attribute_id INT NOT NULL AUTO_INCREMENT, " .
  #	   "subject_id VARCHAR(255), " .
  #	   "feature_id VARCHAR(255), " .
  #	   "att_key    VARCHAR(255), "    .
  #	   "att_value  TEXT, "  .
  #	   "PRIMARY KEY (attribute_id))"
  #	  );
  # $dbh->do("CREATE TABLE relationship ("  .
  #	   "subject_id   VARCHAR(255), " .
  #	   "parent       VARCHAR(255), " .
  #	   "child        VARCHAR(255), "    .
  #	   "relationship VARCHAR(255)) "
  #	  );
}

#-----------------------------------------------------------------------------

=head2 load_files

 Title   : load_files
 Usage   : $self->load_files();
 Function: Get/Set value of load_file.
 Returns : Value of load_file.
 Args    : Value to set load_file to.

=cut

sub load_files {
	my $self = shift;
	$self->throw(message => ('Warn : method_must_be_overridden : ' .
				 'load_files')
		    );
}

#-----------------------------------------------------------------------------

  # my $parser = $self->parser;
  # my $temp_dir;
  # ($temp_dir) = grep {-d $_} qw(/tmp .) unless ($temp_dir &&-d $temp_dir);
  # 
  # my ($FEAT_TEMP,  $feat_filename)  = tempfile('gal_feat_XXXXXX',
  # 					       SUFFIX => '.tmp',
  # 					       DIR    => $temp_dir,
  # 					       UNLINK => 0,
  # 					      );
  # 
  # my ($ATT_TEMP,  $att_filename)  = tempfile('gal_att_XXXXXX',
  # 					     SUFFIX => '.tmp',
  # 					     DIR    => $temp_dir,
  # 					     UNLINK => 0,
  # 					    );
  # my ($REL_TEMP,  $rel_filename)  = tempfile('gal_rel_XXXXXX',
  # 					     SUFFIX => '.tmp',
  # 					     DIR    => $temp_dir,
  # 					     UNLINK => 0,
  # 					    );
  # chmod (0444, $feat_filename, $att_filename, $rel_filename);
  # 
  # for my $file (@{$files}) {
  # 
  #   my $parser = $parser_class->new(file => $file);
  # 
  #   while (my $feature = $parser->next_feature_hash) {
  #     my ($feature_rows, $attribute_rows, $relationship_rows) = $self->prepare_features($feature);
  # 
  #     for my $feature_row (@{$feature_rows}) {
  # 	print $FEAT_TEMP join "\t", @{$feature_row};
  # 	print $FEAT_TEMP "\n";
  #     }
  # 
  #     for my $attribute_row (@{$attribute_rows}) {
  # 	print $ATT_TEMP  join "\t", @{$attribute_row};
  # 	print $ATT_TEMP "\n";
  #     }
  #     for my $relationship_row (@{$relationship_rows}) {
  # 	print $REL_TEMP join "\t", @{$relationship_row};
  # 	print $REL_TEMP "\n";
  #     }
  #   }
  # }
  # $self->_load_temp_files($feat_filename, $att_filename, $rel_filename);
  # }

#-----------------------------------------------------------------------------

=head2 add_features_to_buffer

 Title   : add_features_to_buffer
 Usage   : $self->add_features_to_buffer()
 Function: Get/Set value of add_features_to_buffer.
 Returns : Value of add_features_to_buffer.
 Args    : Value to set add_feature to.

=cut

sub add_features_to_buffer {

	my ($self, $features) = @_;

	$features = ref $features eq 'ARRAY' ? $features : [$features];

	$self->{_feature_buffer} ||= [];

	#my $max_feature_buffer = $self->config('MAX_FEATURE_BUFFER')
	my $max_feature_buffer = 10_000;
	if (scalar @{$self->{_feature_buffer}} + scalar @{$features} >= $max_feature_buffer) {
	  push @{$self->{_feature_buffer}}, @{$features};
	  $self->flush_feature_buffer;
	}
	else {
	  push @{$self->{_feature_buffer}}, @{$features};
	}
}

#-----------------------------------------------------------------------------

=head2 flush_feature_buffer

 Title   : flush_feature_buffer
 Usage   : $self->flush_feature_buffer()
 Function: Get/Set value of flush_feature_buffer.
 Returns : Value of flush_feature_buffer.
 Args    : Value to set add_feature to.

=cut

sub flush_feature_buffer {

	my $self = shift;

	if (scalar @{$self->{_feature_buffer}}) {
		$self->add_features($self->{_feature_buffer});
		$self->{_feature_buffer} = undef;
	}
}

#-----------------------------------------------------------------------------

=head2 prepare_features

 Title   : prepare_features
 Usage   : $self->prepare_features()
 Function: Normalizes feature hashes produced by the parsers
	   and seperates the attributes for bulk insert into the database;
 Returns : A feature hash reference and an array reference of hash references
	   of attributes.  Both normalized for insert statements
 Args    : A feature hash or array of feature hashes

=cut

sub prepare_features {

  my ($self, $feature_hashes) = @_;

  $feature_hashes = ref $feature_hashes eq 'ARRAY' ? $feature_hashes :
    [$feature_hashes];

  my (@features, @attributes, @relationships);

  for my $feature_hash (@{$feature_hashes}) {
    my $feature_id = $feature_hash->{feature_id};
    my $bins = $self->get_feature_bins($feature_hash);
    my $bin = $bins->[0];
    my $attributes = $feature_hash->{attributes};
    my $subject_id = $attributes->{Subject_ID} || '';
    my @parents = ref $attributes->{Parent} eq 'ARRAY' ? @{$attributes->{Parent}} : ();
    my @feature_data = ($subject_id,
			@{$feature_hash}{qw(feature_id seqid source
				       type start end score strand
				       phase)},
			$bin);
    push @features, \@feature_data;

    for my $key (keys %{$attributes}) {
      my @values = @{$attributes->{$key}};
      for my $value (@values) {
	push @attributes, [undef, $subject_id, $feature_id, $key, $value];
      }
    }

    # "subject_id   VARCHAR(255), " .
    # "parent       VARCHAR(255), " .
    # "child        VARCHAR(255), "    .
    # "relationship VARCHAR(255)) "

    for my $parent (@parents) {
      my @relationship_data = ($subject_id, $parent, $feature_id, undef);
      push @relationships, \@relationship_data;
    }
  }
  return (\@features, \@attributes, \@relationships);
}

#-----------------------------------------------------------------------------

=head2 add_features

 Title   : add_features
 Usage   : $self->add_features()
 Function: Get/Set value of add_feature.
 Returns : Value of add_feature.
 Args    : Value to set add_feature to.

=cut

sub add_features {
  my $self = shift;

  $self->throw(message => ('Method must be implimented by subclass : ' .
			   'add_features')
	      );
}

#-----------------------------------------------------------------------------

=head2 create_database

 Title   : create_database
 Usage   : $self->create_database()
 Function: Create the database if it doesnt exists.
 Returns : Success
 Args    : N/A

=cut

sub create_database {

  my $self = shift;
  $self->throw(message => ('Method must be implimented by subclass : ' .
			   'add_features')
	      );
}

#-----------------------------------------------------------------------------

=head2 get_children

 Title   : get_children
 Usage   : $self->get_children()
 Function: Get/Set value of get_children.
 Returns : Value of get_children.
 Args    : Value to set get_children to.

=cut

sub get_children {
	my $self = shift;
	$self->throw(message => ('Method must be implimented by subclass : ' .
				 'add_features')
		    );
}

#-----------------------------------------------------------------------------

=head2 get_children_recursively

 Title   : get_children_recursively
 Usage   : $self->get_children_recursively()
 Function: Get/Set value of get_children_recursively.
 Returns : Value of get_children_recursively.
 Args    : Value to set get_children_recursively to.

=cut

sub get_children_recursively {
  my $self = shift;
  $self->throw(message => ('Method must be implimented by subclass : ' .
			   'add_features')
	      );
}

#-----------------------------------------------------------------------------

=head2 get_parents

 Title   : get_parents
 Usage   : $self->get_parents()
 Function: Get/Set value of get_parents.
 Returns : Value of get_parents.
 Args    : Value to set get_parents to.

=cut

sub get_parents {
  my $self = shift;
  $self->throw(message => ('Method must be implimented by subclass : ' .
			   'add_features')
	      );
}

#-----------------------------------------------------------------------------

=head2 get_parents_recursively

 Title   : get_parents_recursively
 Usage   : $self->get_parents_recursively()
 Function: Get/Set value of get_parents_recursively.
 Returns : Value of get_parents_recursively.
 Args    : Value to set get_parents_recursively to.

=cut

sub get_parents_recursively {
  my $self = shift;
  $self->throw(message => ('Method must be implimented by subclass : ' .
			   'add_features')
	      );
}

#-----------------------------------------------------------------------------

=head2 get_all_features

 Title   : get_all_features
 Usage   : $self->get_all_features()
 Function: Get/Set value of get_all_features.
 Returns : Value of get_all_features.
 Args    : Value to set get_all_features to.

=cut

sub get_all_features {
  my $self = shift;
  $self->throw(message => ('Method must be implimented by subclass : ' .
			   'add_features')
	      );
}

#-----------------------------------------------------------------------------

=head2 get_features_by_type

 Title   : get_features_by_type
 Usage   : $self->get_features_by_type()
 Function: Get/Set value of get_features_by_type.
 Returns : Value of get_features_by_type.
 Args    : Value to set get_features_by_type to.

=cut

sub get_features_by_type {
  my $self = shift;
  $self->throw(message => ('Method must be implimented by subclass : ' .
			   'add_features')
	      );
}

#-----------------------------------------------------------------------------

=head2 get_recursive_features_by_type

 Title   : get_recursive_features_by_type
 Usage   : $self->get_recursive_features_by_type()
 Function: Get/Set value of get_recursive_features_by_type.
 Returns : Value of get_recursive_features_by_type.
 Args    : Value to set get_recursive_features_by_type to.

=cut

sub get_recursive_features_by_type {
  my $self = shift;
  $self->throw(message => ('Method must be implimented by subclass : ' .
			   'add_features')
	      );
}

#-----------------------------------------------------------------------------

=head2 get_feature_by_id

 Title   : get_feature_by_id
 Usage   : $self->get_feature_by_id()
 Function: Get/Set value of get_feature_by_id.
 Returns : Value of get_feature_by_id.
 Args    : Value to set get_feature_by_id to.

=cut

sub get_feature_by_id {
  my $self = shift;
  $self->throw(message => ('Method must be implimented by subclass : ' .
			   'add_features')
	      );
}

#-----------------------------------------------------------------------------

=head2 filter_features

 Title   : filter_features
 Usage   : $self->filter_features()
 Function: Get/Set value of filter_features.
 Returns : Value of filter_features.
 Args    : Value to set filter_features to.

=cut

sub filter_features {
  my $self = shift;
    $self->throw(message => ('Method must be implimented by subclass : ' .
			   'add_features')
		);
}

#-----------------------------------------------------------------------------

=head2 foo

 Title   : foo
 Usage   : $a = $self->foo()
 Function: Get/Set the value of foo.
 Returns : The value of foo.
 Args    : A value to set foo to.

=cut

sub foo {
	my ($self, $value) = @_;
	$self->{foo} = $value if defined $value;
	return $self->{foo};
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

<GAL::Storage> requires no configuration files or environment variables.

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
