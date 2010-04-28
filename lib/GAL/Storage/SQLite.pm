package GAL::Storage::SQLite;

use strict;
use vars qw($VERSION);


$VERSION = '0.01';
use base qw(GAL::Storage);

=head1 NAME

GAL::Storage::SQLite - <One line description of module's purpose here>

=head1 VERSION

This document describes GAL::Storage::SQLite version 0.01

=head1 SYNOPSIS

     use GAL::Storage::SQLite;

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
     Usage   : GAL::Storage::SQLite->new();
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
	my @valid_attributes = qw(dsn user password storage);
	$self->set_attributes($args, @valid_attributes);
	######################################################################
}

#-----------------------------------------------------------------------------

=head2 dbh

 Title   : dbh
 Usage   : $a = $self->dbh();
 Function: Get/Set the value of dbh.
 Returns : The value of dbh.
 Args    : A value to set dbh to.

=cut

sub dbh {
	my $self = shift;

	if (! defined $self->{dbh}) {

	  my $dbh = DBI->connect($self->dsn,
				 $user,
				 $password);
		$self->load_schema($dbh);
		# http://search.cpan.org/~adamk/DBD-SQLite-1.29/lib/DBD/SQLite.pm#Transactions
		$dbh->{AutoCommit} = 1;
		$self->{dbh} = $dbh;
	}
	return $self->{dbh};
}

#-----------------------------------------------------------------------------

=head2 load_schema

 Title   : load_schema
 Usage   : $a = $self->load_schema();
 Function: Get/Set the value of load_schema.
 Returns : The value of load_schema.
 Args    : A value to set load_schema to.

=cut

sub load_schema {
	my ($self, $dbh) = @_;

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
			       phase      => 'VARCHAR(1)',
			      );
	my $feature_columns_text = join ' ', @feature_columns;
	my $feature_create_stmt =
	  "CREATE TABLE feature ($feature_columns_text)";
	$dbh->do($feature_create_stmt);

	my @att_columns =
	  (feature_id   => 'VARCHAR(100),',
	   tag          => 'VARCHAR(100),',
	   value        => 'TEXT',
	  );
	my $att_columns_text = join ' ', @att_columns;
	my $att_create_stmt =
	  "CREATE TABLE attribute ($att_columns_text)";
	$dbh->do($att_create_stmt);
}

#-----------------------------------------------------------------------------

=head2 add_features

 Title   : add_features
 Usage   : $self->add_features();
 Function: Get/Set value of add_features.
 Returns : Value of add_features.
 Args    : Value to set add_feature to.

=cut

sub add_features {
	my ($self, $features) = @_;

	my ($features, $attributes) = $self->prepare_features($features);

	my $insert_stmt = "INSERT INTO feature VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

	my $dbh = $self->dbh;
	my $sth = $dbh->prepare($insert_stmt);

	# http://search.cpan.org/~adamk/DBD-SQLite-1.29/lib/DBD/SQLite.pm#Transactions
	$dbh->begin_work;
	for my $feature (@{$features}) {
		my $rv = $sth->execute(@{$feature});
		unless ($rv) {
			my $warn_message = "WARN: bad_insert : ";
			$warn_message .= join ', ', @{$feature};
			$self->warn(message => $warn_message);
		}
	}
	$dbh->commit;

	my $insert_stmt = "INSERT INTO attribute VALUES (?, ?, ?)";

	my $dbh = $self->dbh;
	my $sth = $dbh->prepare($insert_stmt);

	$dbh->begin_work;
	for my $attribute_set (@{$attributes}) {
		for my $pair (@{$attribute_set}) {
			my $rv = $sth->execute(@{$pair});
			unless ($rv) {
				my $warn_message = "WARN: bad_insert : ";
				$warn_message .= join ', ', @{$pair};
				$self->warn(message => $warn_message);
			}
		}
	}
	$dbh->commit;
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

<GAL::Storage::SQLite> requires no configuration files or environment variables.

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
