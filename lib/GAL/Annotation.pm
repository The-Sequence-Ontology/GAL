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

=head2 dsn

 Title   : dsn
 Usage   : $a = $self->dsn();
 Function: Get/Set the value of dsn.
 Returns : The value of dsn.
 Args    : A value to set dsn to.

=cut

sub dsn {
	my ($self, $dsn) = @_;
	$self->{dsn} = $dsn if $dsn;
	return $self->{dsn};
}

#-----------------------------------------------------------------------------

=head2 storage

 Title   : storage
 Usage   : $a = $self->storage();
 Function: Just returns DBI
 Returns : DBI
 Args    : Whatever you want, but it_ll be ignored!

=cut

sub storage {
	my ($self, $dsn) = @_;

	my $storage;
	if ($dsn) {
		$self->load_module('GAL::Storage');
		$storage = GAL::Storage->new(dsn => $dsn);
	}

	$self->{storage} = $storage if defined $storage;
	return $self->{parser};
}

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
	   #$self->create_database;
	   $self->{schema} = GAL::Schema->connect($self->dsn,
						  $self->user,
						  $self->password);
       }
       return $self->{schema};
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

	my ($self, $file) = @_;
	$self->stroage->load_file($file);
	return $self;
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
	my $feature = $self->storage->add_feature($feature_hash);
	return $feature;
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
	my $features = $self->storage->get_all_features;
	return wantarray ? @{$features} : $features;
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
	my ($self, $type) = @_;
	my $features = $self->storage->get_features_by_type($type);
	return wantarray ? @{$features} : $features;
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
	my ($self, $type) = @_;
	my $features = $self->storage->get_features_by_type_recursive;
	return wantarray ? @{$features} : $features;
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
	my ($self, $id) = @_;
	my $feature = $self->storage->get_feature_by_id($id);
	return $feature;
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
	my ($self, $filter) = @_;
	my $features = $self->storage->filter_features($filter);
	return wantarray ? @{$features} : $features;
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
