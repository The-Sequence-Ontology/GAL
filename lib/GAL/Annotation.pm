package GAL::Annotation;

use strict;
use warnings;

use DBI;
use GAL::Schema;
use base qw(GAL::Base);

use vars qw($VERSION);
$VERSION = '0.01';

=head1 NAME

Annotation::GAL - <One line description of module's purpose here>

=head1 VERSION

This document describes Annotation::GAL version 0.01

=head1 SYNOPSIS

     use Annotation::GAL;

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
     Usage   : Annotation::GAL->new();
     Function: Creates a Annotation::GAL object;
     Returns : A Annotation::GAL object
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

	my @valid_attributes = qw(dsn
				  usr
				  password
				 );

	my $args = $self->prepare_args(\@args, \@valid_attributes);

	$self->set_attributes($args, \@valid_attributes);

}

#-----------------------------------------------------------------------------

=head2 dsn

 Title   : dsn
 Usage   : $a = $self->dsn();
 Function: Get/Set the value of dsn.
 Returns : The value of dsn.
 Args    : A value to set dsn to.

=cut

sub dsn {
	my ($self, $dsn) = @_;

	if ($self->{dsn} && ! $dsn) {
		return $self->{dsn};
	}

	$dsn ||= '';
	my ($db_name, $driver, $storage) = reverse split ':', $dsn;
	$storage = $self->storage($storage);
	$driver  = $self->driver($driver);
	$db_name = $self->db_name($db_name);
	$self->{dsn} = join ':', ($storage, $driver, $db_name);
	return $self->{dsn};
}

#-----------------------------------------------------------------------------

=head2 user

 Title   : user
 Usage   : $a = $self->user();
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
 Usage   : $a = $self->password();
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

=head2 db_name

 Title   : db_name
 Usage   : $a = $self->db_name();
 Function: Get/Set the value of db_name.
 Returns : The value of db_name.
 Args    : A value to set db_name to.

=cut

sub db_name {
	my ($self, $db_name) = @_;

	if (! $self->{db_name} && ! $db_name) {
		# Generate a date stamp
		my ($sec,$min,$hour,$mday,$mon,$year,$wday,
		    $yday,$isdst) = localtime(time);
		my $time_stamp = sprintf("%02d%02d%02d", $year + 1900,
					 $mon, $mday);
		# Generate a 8 charachter not-really-random hex extension
		# for the db_name.
		my @symbols = (0..9);
		push @symbols, qw(a b c d e f);
		my $extension = join '', map {(@symbols[rand(16)])} (1..8);
		$db_name = join '_', ('gal_database', $time_stamp,
				      $extension);
		$self->warn(message => ("Incomplete Data Source Name (DSN) ",
					"given. ", __PACKAGE__,
					' created $db_name as a database ',
					'name for you.')
			   );
	}
	$self->{db_name} = $db_name if $db_name;
	return $self->{db_name};
}

#-----------------------------------------------------------------------------

=head2 driver

 Title   : driver
 Usage   : $a = $self->driver();
 Function: Get/Set the value of driver.
 Returns : The value of driver.
 Args    : A value to set driver to.

=cut

sub driver {
	my ($self, $driver) = @_;

	if (! $self->{driver} && ! $driver) {
		$driver = 'mysql';
		$self->warn(message => ("Incomplete Data Source Name (DSN) ",
					"given. ", __PACKAGE__,
					' created $driver as a database ',
					'driver for you.')
			   );
	}
	$self->{driver} = $driver if $driver;
	return $self->{driver};
}

#-----------------------------------------------------------------------------

=head2 storage

 Title   : storage
 Usage   : $a = $self->storage();
 Function: Just returns DBI
 Returns : DBI
 Args    : Whatever you want, but it'll be ignored!

=cut

sub storage {
	my ($self, $storage) = @_;

	# This will probably never change, but you could abstract the
	# storage here.  Just hard coded here for symetry with driver
	# and db_name methods.
	$self->{storage} = 'DBI';
	return $self->{storage};
}

#-----------------------------------------------------------------------------

=head2 parser

 Title   : parser
 Usage   : $a = $self->parser();
 Function: Get/Set the parser.
 Returns : The parser object.
 Args    : file  => data_file_name
	   class => GAL::Parser::subclass.

=cut

sub parser {
	my ($self, @args) = @_;

	my @valid_args = qw(file class);
	my $args = $self->prepare_args(\@args, \@valid_args);

	my $class = $args->{class};
	my $file  = $args->{file};

	my $parser;
	if ($class && $file) {
		$class =~ s/GAL::Parser:://;
		$class = 'GAL::Parser::' . $class;
		$self->load_module($class);
		$parser = $class->new(file => $file);
	}

	$self->{parser} = $parser if defined $parser;
	return $self->{parser};
}

#-----------------------------------------------------------------------------

=head2 load_file

 Title   : load_file
 Usage   : $a = $self->load_file();
 Function: Parse and store all of the features in a file
 Returns : N/A
 Args    : file  => data_file_name
	   class => GAL::Parser::subclass.

=cut

sub load_file {

	my $self = shift;
	my $parser = $self->parser(@_);
	my $feature_rs   = $self->schema->resultset('Feature');
	my $attribute_rs = $self->schema->resultset('Attribute');

	my @features;
	my @attributes;
	my $count = 1;
	my $bulk_load_count = 10; #$self->bulk_load_count;
	while (my $record = $parser->_read_next_record) {

		my $feature_hash = $parser->parse_record($record);
		next unless defined $feature_hash;
		my ($feature, $attribute_array) = 
		  $self->_split_feature_and_attributes($feature_hash);
		push @features, $feature;
		push @attributes, @{$attribute_array};
		if ($count++ >= $bulk_load_count) {
			$feature_rs->populate(\@features);
			$attribute_rs->populate(\@attributes);
			$count = 1;
			@features = ();
			@attributes = ();
		}
	}
	$feature_rs->insert_bulk(@features) if scalar @features;;
	$attribute_rs->populate(\@attributes) if scalar @attributes;

	return $self;
}

#-----------------------------------------------------------------------------

=head2 _split_feature_and_attributes

 Title   : _split_feature_and_attributes
 Usage   : $self->_split_feature_and_attributes();
 Function: Normalizes a feature hash produced by the parsers
           and seperate the attributes for bulk insert into the database;
 Returns : A feature hash reference and an array reference of hash references
           of attributes.  Both normalized for insert statements
 Args    : Value to set _split_feature_and_attributes to.

=cut

sub _split_feature_and_attributes {

	my ($self, $feature_hash) = @_;
	my @attributes;
	for my $tag (keys %{$feature_hash->{attributes}}) {
		for my $value (@{$feature_hash->{attributes}{$tag}}) {
			push @attributes, {feature_id 	=> $feature_hash->{feature_id},
					   tag        	=> $tag,
					   value      	=> $value,
					  };
		}
	}
	delete $feature_hash->{attributes};
	return ($feature_hash, \@attributes);
}

#-----------------------------------------------------------------------------

=head2 _normalize_feature

 Title   : _normalize_feature
 Usage   : $self->_normalize_feature();
 Function: Normalizes a feature hash produced by the parsers
           for insert into the database;
 Returns : A feature hash reference with the attributes turned into an array
           of hash references.
 Args    : Value to set _normalize_feature to.

=cut

sub _normalize_feature {

	my ($self, $feature_hash) = @_;
	my @attributes;
	for my $tag (keys %{$feature_hash->{attributes}}) {
		for my $value (@{$feature_hash->{attributes}{$tag}}) {
			push @attributes, {feature_id 	=> $feature_hash->{feature_id},
					   tag        	=> $tag,
					   value      	=> $value,
					  };
		}
	}
	$feature_hash->{attributes} = \@attributes;
	return ($feature_hash);
}

#-----------------------------------------------------------------------------

=head2 add_feature

 Title   : add_feature
 Usage   : $self->add_feature();
 Function: Get/Set value of add_feature.
 Returns : Value of add_feature.
 Args    : Value to set add_feature to.

=cut

sub add_feature {
  my ($self, $feature_hash) = @_;

  my $feature_rs   = $self->schema->resultset('Feature');
  my $normal_feature = $self->_normalize_feature($feature_hash);
  return $feature_rs->create($feature_hash);
}

#-----------------------------------------------------------------------------

=head2 add_attributes

 Title   : add_attributes
 Usage   : $self->add_attributes();
 Function: Get/Set value of add_attributes.
 Returns : Value of add_attributes.
 Args    : Value to set add_attributes to.

=cut

#sub add_attributes {
#  my ($self, $attributes) = @_;
#
#  my $attribute_rs = $self->schema->resultset('Attribute');
#
#  $attribute_rs->new($attributes)->update_or_insert;
#
#  $self->add_attributes($attribute_array);
#
#  return if $success;
#  my $hash_text = join ', ', %{$feature_hash};
#  $self->warn(message => ('Failed to update or add a feature with this ',
#			  "data: $hash_text")
#	     );
#}

#-----------------------------------------------------------------------------

=head2 schema

 Title   : schema
 Usage   : $self->schema();
 Function: Return the cached DBIx::Class::Schema object
 Returns : DBIx::Class::Schema object
 Args    : N/A

=cut

sub schema {
	my $self = shift;

	# Create the schema if it doesn't exist
	if (! $self->{schema}) {
		$self->create_database;
		$self->{schema} = GAL::Schema->connect($self->dsn,
						       $self->user,
						       $self->password);
	}
	return $self->{schema};
}

#-----------------------------------------------------------------------------

=head2 create_database

 Title   : create_database
 Usage   : $self->create_database();
 Function: Create the database if it doesn't exists.
 Returns : Success
 Args    : N/A

=cut

sub create_database {
	my $self = shift;

	my @databases = DBI->data_sources($self->driver,
					  {user     => $self->user,
					   password => $self->password,
					  }
					 );

	my $dsn = $self->dsn;
	my $db_name = $self->db_name;
	if (! grep {$_ eq $dsn} @databases) {
		my $drh = DBI->install_driver("mysql");
		my $host = ''; # Defaults to localhost, abstract this later.
		my $rc = $drh->func('createdb',
				    $db_name,
				    $host,
				    $self->user,
				    $self->password,
				    'admin');
		my $dbh = DBI->connect($self->dsn, $self->user,
				       $self->password);
		$dbh->do("DROP TABLE IF EXISTS feature");
		$dbh->do("DROP TABLE IF EXISTS attribute");
		my @feature_columns = (feature_id => 'VARCHAR(100),',
				       seqid      => 'VARCHAR(100),',
				       source     => 'VARCHAR(100),',
				       type       => 'VARCHAR(100),',
				       start      => 'INT,',
				       end        => 'INT,',
				       score      => 'varchar(20),',
				       strand     => 'VARCHAR(1),',
				       phase      => 'VARCHAR(1),',
				      );
		my $feature_columns_text = join ' ', @feature_columns;
		$feature_columns_text =~ s/,\s*$//;
		my $feature_create_stmt =
		  "CREATE TABLE feature ($feature_columns_text)";
		$dbh->do($feature_create_stmt);

		my @att_columns =
			       (attribute_id => 'INT NOT NULL AUTO_INCREMENT,',
				feature_id   => 'VARCHAR(100),',
				tag      => 'VARCHAR(100),',
				value    => 'TEXT,',
			       );
		my $att_columns_text = join ' ', @att_columns;
		my $att_create_stmt =
		  "CREATE TABLE attribute ($att_columns_text " .
		    "PRIMARY KEY (attribute_id))";
		#CREATE TABLE attribute (attribute_id INT NOT NULL AUTO_INCREMENT, feature_id VARCHAR(100), tag VARCHAR(100), value TEXT, PRIMARY KEY (attribute_id))
		$dbh->do($att_create_stmt);
	}
	else {
		$self->warn(message => "Using exsiting database $db_name");
	}

	return 1;
}

#-----------------------------------------------------------------------------

=head2 create_schema

 Title   : create_schema
 Usage   : $self->create_schema();
 Function: Creates a DBIx::Class::Schema object
 Returns : DBIx::Class::Schema object
 Args    : N/A

=cut

#sub create_schema {
#	my $self = shift;
#	my $dsn = $self->dsn;

#	$self->{schema} ||= $self->create_schema;
#	return $self->{schema};
#}

#-----------------------------------------------------------------------------

=head2 get_all_features

 Title   : get_all_features
 Usage   : $self->get_all_features();
 Function: Get/Set value of get_all_features.
 Returns : Value of get_all_features.
 Args    : Value to set get_all_features to.

=cut

sub get_all_features {
  my ($self, $value) = @_;
  $self->{get_all_features} = $value if defined $value;
  return $self->{get_all_features};
}

#-----------------------------------------------------------------------------

=head2 get_features_by_type

 Title   : get_features_by_type
 Usage   : $self->get_features_by_type();
 Function: Get/Set value of get_features_by_type.
 Returns : Value of get_features_by_type.
 Args    : Value to set get_features_by_type to.

=cut

sub get_features_by_type {
  my ($self, $value) = @_;
  $self->{get_features_by_type} = $value if defined $value;
  return $self->{get_features_by_type};
}

#-----------------------------------------------------------------------------

=head2 get_recursive_features_by_type

 Title   : get_recursive_features_by_type
 Usage   : $self->get_recursive_features_by_type();
 Function: Get/Set value of get_recursive_features_by_type.
 Returns : Value of get_recursive_features_by_type.
 Args    : Value to set get_recursive_features_by_type to.

=cut

sub get_recursive_features_by_type {
  my ($self, $value) = @_;
  $self->{get_recursive_features_by_type} = $value if defined $value;
  return $self->{get_recursive_features_by_type};
}

#-----------------------------------------------------------------------------

=head2 get_feature_by_id

 Title   : get_feature_by_id
 Usage   : $self->get_feature_by_id();
 Function: Get/Set value of get_feature_by_id.
 Returns : Value of get_feature_by_id.
 Args    : Value to set get_feature_by_id to.

=cut

sub get_feature_by_id {
  my ($self, $value) = @_;
  $self->{get_feature_by_id} = $value if defined $value;
  return $self->{get_feature_by_id};
}

#-----------------------------------------------------------------------------

=head2 filter_features

 Title   : filter_features
 Usage   : $self->filter_features();
 Function: Get/Set value of filter_features.
 Returns : Value of filter_features.
 Args    : Value to set filter_features to.

=cut

sub filter_features {
  my ($self, $value) = @_;
  $self->{filter_features} = $value if defined $value;
  return $self->{filter_features};
}


#-----------------------------------------------------------------------------

=head2 foo

 Title   : foo
 Usage   : $a = $self->foo();
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

<Annotation::GAL> requires no configuration files or environment variables.

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
