package GAL::Storage::mysql;

use strict;
use vars qw($VERSION);

$VERSION = '0.01';
use base qw(GAL::Storage);
use File::Temp qw(tempfile);
use DBI;

=head1 NAME

GAL::Storage::mysql - <One line description of module's purpose here>

=head1 VERSION

This document describes GAL::Storage::mysql version 0.01

=head1 SYNOPSIS

     use GAL::Storage::mysql;

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
     Usage   : GAL::Storage::mysql->new();
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
	my @valid_attributes = qw();
	$self->set_attributes($args, @valid_attributes);
	######################################################################
}

#-----------------------------------------------------------------------------

=head2 scheme

 Title   : scheme
 Usage   : $a = $self->scheme();
 Function: Get the value of scheme.
 Returns : The value of scheme.
 Args    : N/A

=cut

sub scheme {'dbi'}

#-----------------------------------------------------------------------------

=head2 driver

 Title   : driver
 Usage   : $a = $self->driver();
 Function: Get the value of driver.
 Returns : The value of driver.
 Args    : N/A

=cut

sub driver {'mysql'}

#-----------------------------------------------------------------------------

=head2 dbh

 Title   : dbh
 Usage   : $a = $self->dbh();
 Function: Get the value of dbh.
 Returns : The value of dbh.
 Args    : N/A

=cut

sub dbh {

  my $self = shift;
  $self->{dbh} ||= $self->_open_or_create_database;
  return $self->{dbh};
}

#-----------------------------------------------------------------------------
#
# =head2 database
#
#  Title   : database
#  Usage   : $a = $self->database();
#  Function: Get/Set the value of database.
#  Returns : The value of database.
#  Args    : A value to set database to.
#
# =cut
#
# sub database {
#	my ($self, $database) = @_;
#
#	if (! $self->{database} && ! $database) {
#	  my $database = $self->random_database;
#	  $self->warn(message => ("Incomplete Data Source Name (DSN) ",
#				  "given. ", __PACKAGE__,
#				  ' created $database as a database ',
#				  'name for you.')
#		     );
#	}
#	$self->{database} = $database if $database;
#	return $self->{database};
# }
#
#-----------------------------------------------------------------------------
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

=head2 _open_or_create_database

 Title   : _open_or_create_database
 Usage   : $self->_open_or_create_database();
 Function: Create the database if it doesnt exists.
 Returns : Success
 Args    : N/A

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
	$dbh->do("DROP TABLE IF EXISTS feature");
		$dbh->do("DROP TABLE IF EXISTS attribute");
	$dbh->do("CREATE TABLE feature ("    .
		 "feature_id VARCHAR(255), " .
		 "seqid      VARCHAR(255), " .
		 "source     VARCHAR(255), " .
		 "type       VARCHAR(255), " .
		 "start      INT, "          .
		 "end        INT, "          .
		 "score      VARCHAR(255), "  .
		 "strand     VARCHAR(1), "   .
		 "phase      VARCHAR(1),"     .
		 "bin        VARCHAR(15))"
		 # "name      VARCHAR(255), "      .
		 # "parent    VARCHAR(255), "    .
		 );
	$dbh->do("CREATE TABLE attribute ("  .
		 "attribute_id INT NOT NULL AUTO_INCREMENT, " .
		 "feature_id VARCHAR(255), " .
		 "att_key    VARCHAR(255), "    .
		 "att_value  TEXT, "  .
		 "PRIMARY KEY (attribute_id))"
		 );
	}
	else {
		$self->warn(message => "Using exsiting database $database");
		$dbh = DBI->connect($self->dsn, $self->user,
				    $self->password);
	}
	$self->{dbh} = $dbh;
	return $self->{dbh};
}

#-----------------------------------------------------------------------------

=head2 load_file

 Title   : load_file
 Usage   : $self->load_file();
 Function: Get/Set value of load_file.
 Returns : Value of load_file.
 Args    : Value to set load_file to.

=cut

sub load_file {

  my ($self, @args) = @_;

  my $args = $self->prepare_args(\@args);
  my $files = $args->{file};
  $files = ref $files eq 'ARRAY' ? $files : [$files];
  my $parser_class = $args->{format};
  $parser_class =~ s/GAL::Parser//;
  $parser_class = 'GAL::Parser::' . $parser_class;
  $self->load_module($parser_class);

  my $temp_dir;
 ($temp_dir) = grep {-d $_} qw(/tmp .) unless ($temp_dir &&-d $temp_dir);

  my ($FEAT_TEMP,  $feat_filename)  = tempfile('gal_feat_XXXXXX',
					       SUFFIX => '.tmp',
					       DIR    => $temp_dir,
					       UNLINK => 0,
					      );

  my ($ATT_TEMP,  $att_filename)  = tempfile('gal_att_XXXXXX',
					     SUFFIX => '.tmp',
					     DIR    => $temp_dir,
					     UNLINK => 0,
					    );
  chmod (0444, $feat_filename, $att_filename);

  for my $file (@{$files}) {

    my $parser = $parser_class->new(file => $file);

    while (my $feature = $parser->next_feature_hash) {
      my $feature_id = $feature->{feature_id};
      my $bins = $self->get_feature_bins($feature);
      my $bin = $bins->[0];
      my @feature_data = (@{$feature}{qw(feature_id seqid source
					 type start end score strand
					 phase)},
			  $bin);
      my $attributes = $feature->{attributes};
      print $FEAT_TEMP join "\t", @feature_data;
      print $FEAT_TEMP "\n";

      for my $key (keys %{$attributes}) {
	my @values = @{$attributes->{$key}};
	for my $value (@values) {
	  print $ATT_TEMP  join "\t",
	    ($feature_id, $key, $value);
	  print $ATT_TEMP "\n";
	}
      }
    }
  }

  my $dbh = $self->dbh;

  $dbh->do("LOAD DATA INFILE '$feat_filename' INTO TABLE feature   (feature_id, seqid, source, type, start, end, score, strand, phase, bin)");
  $dbh->do("LOAD DATA INFILE '$att_filename'  INTO TABLE attribute (feature_id, att_key, att_value)");
}

#-----------------------------------------------------------------------------

=head2 get_children

 Title   : get_children
 Usage   : $self->get_children();
 Function: Get/Set value of get_children.
 Returns : Value of get_children.
 Args    : Value to set get_children to.

=cut

sub get_children {
	my $self = shift;
	$self->not_implemented('get_children');
}

#-----------------------------------------------------------------------------

=head2 get_children_recursively

 Title   : get_children_recursively
 Usage   : $self->get_children_recursively();
 Function: Get/Set value of get_children_recursively.
 Returns : Value of get_children_recursively.
 Args    : Value to set get_children_recursively to.

=cut

sub get_children_recursively {
  my $self = shift;
  $self->not_implemented('get_children_recursively');
}

#-----------------------------------------------------------------------------

=head2 get_parents

 Title   : get_parents
 Usage   : $self->get_parents();
 Function: Get/Set value of get_parents.
 Returns : Value of get_parents.
 Args    : Value to set get_parents to.

=cut

sub get_parents {
  my $self = shift;
  $self->not_implemented('get_parents');
}

#-----------------------------------------------------------------------------

=head2 get_parents_recursively

 Title   : get_parents_recursively
 Usage   : $self->get_parents_recursively();
 Function: Get/Set value of get_parents_recursively.
 Returns : Value of get_parents_recursively.
 Args    : Value to set get_parents_recursively to.

=cut

sub get_parents_recursively {
  my $self = shift;
  $self->not_implemented('get_parents_recursively');
}

#-----------------------------------------------------------------------------

=head2 get_all_features

 Title   : get_all_features
 Usage   : $self->get_all_features();
 Function: Get/Set value of get_all_features.
 Returns : Value of get_all_features.
 Args    : Value to set get_all_features to.

=cut

sub get_all_features {
  my $self = shift;
  $self->not_implemented('get_all_features');
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
  my $self = shift;
  $self->not_implemented('get_features_by_type');
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
  my $self = shift;
  $self->not_implemented('get_recursive_features_by_type');
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
  my $self = shift;
  $self->not_implemented('get_feature_by_id');
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
  my $self = shift;
  $self->not_implemented('filter_features');
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

<GAL::Storage::mysql> requires no configuration files or environment variables.

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
