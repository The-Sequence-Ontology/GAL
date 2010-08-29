package GAL::Storage::RAM;

use strict;
use vars qw($VERSION);

$VERSION = '0.01';
use base qw(GAL::Storage);

=head1 NAME

GAL::Storage::RAM - RAM feature storage for GAL

=head1 VERSION

This document describes GAL::Storage::RAM version 0.01

=head1 SYNOPSIS

    use GAL::Storage::RAM;
    my $storage = GAL::Storage::RAM->new(dsn => 'dbi:RAM:db_name');

=head1 DESCRIPTION

The L<GAL::Storage::RAM> class provides RAM based storage to
GAL.

=head1 CONSTRUCTOR

New GAL::Storage::RAM objects are created by the class method new.
Arguments should be passed to the constructor as a list (or reference)
of key value pairs.  All attributes of the Storage object can be set
in the call to new. An simple example of object creation would look
like this:

    my $parser = GAL::Storage::RAM->new(dsn => 'dbi:RAM:db_name);

The constructor recognizes the following parameters which will set the
appropriate attributes:

=over 4

=item * C<scheme>

This is a read only parameter that is set to 'DBI';

=item * C<driver >

This is a read only parameter that is set to 'RAM';

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

=item * C<dsn => 'dbi:RAM:db_name'>

dsn => 'dbi:RAM:db_name

This optional parameter defines the data source name of the database
to open.  By default Storage will use and RAM database with a
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
     Usage   : GAL::Storage::RAM->new();
     Function: Creates a Storage object;
     Returns : A L<GAL::Storage::RAM> object
     Args    : See the attributes described above.

=cut

sub new {
	my ($class, @args) = @_;
	my $self = $class->SUPER::new(@args);
	$self->{_features} = [];
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

=head2 load_files

 Title   : load_files
 Usage   : $self->load_files();
 Function: Load a file(s) into the database
 Returns : Nothing
 Args    : An scalar string or array reference containing the name(s) of
           files to load.

=cut

# TODO: Allow GAL::Storage::subclass::load_files to set the parser.

sub load_files {

  my ($self, $args) = @_;
  my ($files, $parser) = @{$args}{qw(files parser)};
  $files = ref $files eq 'ARRAY' ? $files : [$files];

  if ($parser) {
    $parser = 'GAL::Parser::' . $parser;
    $self->load_module($parser);
    $parser = $parser->new();
  }
  else {
    $parser = $self->annotation->parser;
  }

  for my $file (@{$files}) {
    $parser->file($file);
    while (my $feature = $parser->next_feature_hash) {
      $self->add_features($feature);
    }
  }
}

#-----------------------------------------------------------------------------

=head2 add_features

 Title   : add_features
 Usage   : $self->add_features();
 Function: Add features to the database.
 Returns : Nothing
 Args    : An array reference of feature hashes.

=cut

sub add_features {
  my ($self, $features) = @_;

  $features = ref $features eq 'ARRAY' ? $features : [$features];

  my $feature_idx = scalar @{$self->{_features}};
  for my $feature (@{$features}) {

    my ($feature_id, $seqid, $source, $type, $start, $end, $strand, $phase, $attrbs) = 
      @{$feature}{qw(feature_id seqid source type start end strand phase attrbs)};

    my $this_feature_idx = $feature_idx++;
    my ($bin) = $self->get_feature_bins($feature);
    my $individual_id = $attrbs->{individual}[0];
    @{$feature}{qw(idx, bin, individual_id)} = ($this_feature_idx, $bin, $individual_id);
    push @{$self->{_features}}, $feature;

    $self->{_indices}{feature_id}{$feature_id} = $this_feature_idx;
    push @{$self->{_indices}{seqid}{$seqid}}, $this_feature_idx;
    push @{$self->{_indices}{source}{$source}}, $this_feature_idx;
    push @{$self->{_indices}{type}{$type}}, $this_feature_idx;
    push @{$self->{_indices}{bin}{$bin}}, $this_feature_idx;

    my @parents;
    @parents = @{$attrbs->{Parent}} if exists $attrbs->{Parent};
    for my $parent (@parents) {
      push @{$self->{_indices}{bin}{attr}{parent}{$parent}}, $this_feature_idx;
      push @{$self->{_indices}{bin}{attr}{children}{$this_feature_idx}}, $parent;
    }

    my @var_effects;
    @var_effects = @{$attrbs->{Variant_effect}} if exists $attrbs->{Variant_effect};
    for my $var_effect (@var_effects) {
      my ($effect) = split /\s+/, $var_effect;
      push @{$self->{_indices}{bin}{attr}{variant_effect}{$var_effect}}, $this_feature_idx;
    }
  }
}

#-----------------------------------------------------------------------------
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

=item C<bad_feature_table_insert>

An error occured while trying to insert data into the feature table.
The offending data is given as a comma separated list.  Make sure that
all of the data is compatible with the database schema.  This may be a
problem in the parser you are using, or more likely the incoming data
is not in the correct format.

=item C<bad_attribute_table_insert>

Same problem as C<bad_feature_table_insert> above, but for the
attribute table.

=item C<bad_relationship_table_insert>

Same problem as C<bad_feature_table_insert> above, but for the
attribute table.

=back

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::Storage::RAM> requires no configuration files or environment
variables.

=head1 DEPENDENCIES

L<GAL::Storage>
L<DBI>
L<DBD::RAM>

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
