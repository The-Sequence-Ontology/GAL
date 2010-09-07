package GAL::FeatureSet;

use strict;
use vars qw($VERSION);


$VERSION = '0.01';
use base qw(GAL::Base);
use DBI;

=head1 NAME

GAL::FeatureSet - <One line description of module's purpose here>

=head1 VERSION

This document describes GAL::FeatureSet version 0.01

=head1 SYNOPSIS

     use GAL::FeatureSet;

=for author to fill in:
     Brief code example(s) here showing commonest usage(s).
     This section will be as far as many users bother reading
     so make it as educational and exemplary as possible.

=head1 DESCRIPTION

=for author to fill in:
     Write a full description of the module and its features here.
     Use subsections (=head2, =head3) as appropriate.

=head1 CONSTRUCTOR

=cut

#-----------------------------------------------------------------------------
#-------------------------------- Constructor --------------------------------
#-----------------------------------------------------------------------------

=head2 new

     Title   : new
     Usage   : GAL::FeatureSet->new()
     Function: Creates a FeatureSet object;
     Returns : A FeatureSet object
     Args    :

=cut

sub new {
	my ($class, @args) = @_;
	my $self = $class->SUPER::new(@args);
	return $self;
}

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
#-------------------------------- Attributes ---------------------------------
#-----------------------------------------------------------------------------


=head1  ATTRIBUTES

All attributes can be supplied as parameters to the constructor
constructor as a list (or referenece) of key value pairs.

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

=head2 storage

 Title   : storage
 Usage   : $a = $self->storage()
 Function: Get/Set the value of storage.
 Returns : The value of storage.
 Args    : A value to set storage to.

=cut

sub storage {
  my ($self, $storage) = @_;
  $self->{storage} = $storage if $storage;
  return $self->{storage};
}

#-----------------------------------------------------------------------------

=head2 ids

 Title   : ids
 Usage   : $a = $self->ids()
 Function: Get/Set the value of ids.
 Returns : The value of ids.
 Args    : A value to set ids to.

=cut

sub ids {
  my ($self, $ids) = @_;
  $self->{ids} = $ids if $ids;
  return $self->{ids};
}

#-----------------------------------------------------------------------------
#                                   Methods
#-----------------------------------------------------------------------------

=head2 search

 Title   : search
 Usage   : $a = $self->search()
 Function:
 Returns :
 Args    :

=cut

sub search {
    my ($self, $constraints, $order) = @_;


    # TODO: Pull out pattern match contraints and impliment them here.

    my $ids = $self->storage->select_ids($constraints, $order);
    return GAL::FeatureSet->new(storage    => $self->storage,
				annotation => $self->annotation,
				ids        => $ids
			       );
}

#-----------------------------------------------------------------------------

=head2 filter

 Title   : filter
 Usage   : $a = $self->filter()
 Function:
 Returns :
 Args    :

=cut

sub filter {
  my ($self, $constraints, $order) = @_;

  my $ids = $self->storage->select_ids($constraints, $order);
  $self->{_ids} = $ids;
  return $self;
}

#-----------------------------------------------------------------------------

=head2 find

 Title   : find
 Usage   : $a = $self->find()
 Function:
 Returns :
 Args    :

=cut

sub find {
    my $self = shift;
    $self->throw(message => 'This method is not yet implimented');
}

#-----------------------------------------------------------------------------

=head2 get_column

 Title   : get_column
 Usage   : $a = $self->get_column()
 Function:
 Returns :
 Args    :

=cut

sub get_column {
    my $self = shift;
    $self->throw(message => 'This method is not yet implimented');
}

#-----------------------------------------------------------------------------

=head2 slice

 Title   : slice
 Usage   : $a = $self->slice()
 Function:
 Returns :
 Args    :

=cut

sub slice {
    my $self = shift;
    $self->throw(message => 'This method is not yet implimented');
}

#-----------------------------------------------------------------------------

=head2 count

 Title   : count
 Usage   : $a = $self->count()
 Function:
 Returns :
 Args    :

=cut

sub count {
    my $self = shift;

    return scalar @{$self->{ids}};

}

#-----------------------------------------------------------------------------

=head2 reset

 Title   : reset
 Usage   : $a = $self->reset()
 Function:
 Returns :
 Args    :

=cut

sub reset {
    my $self = shift;

    $self->{counter} = 0;

    return $self;

}

#-----------------------------------------------------------------------------

=head2 all

 Title   : all
 Usage   : $a = $self->all()
 Function:
 Returns :
 Args    :

=cut

sub all {
    my $self = shift;

    my @features = @{$self->{storage}->{_features}}{@{$self->{ids}}};
    return wantarray ? @features : \@features;
}

#-----------------------------------------------------------------------------

=head2 next

 Title   : next
 Usage   : $a = $self->next()
 Function:
 Returns :
 Args    :

=cut

sub next {
    my $self = shift;
    return = $self->{storage}->{_features}[$self->{ids}[$self->counter_next]];
}

#-----------------------------------------------------------------------------

=head2 previous

 Title   : previous
 Usage   : $a = $self->previous()
 Function:
 Returns :
 Args    :

=cut

sub previous {
    my $self = shift;
    return = $self->{storage}->{_features}[$self->{ids}[$self->counter_previous]];
}

#-----------------------------------------------------------------------------

=head2 first

 Title   : first
 Usage   : $a = $self->first()
 Function:
 Returns :
 Args    :

=cut

sub first {
    my $self = shift;
    return = $self->{storage}->{_features}[$self->{ids}[0]];
}

#-----------------------------------------------------------------------------

=head2 last

 Title   : last
 Usage   : $a = $self->last()
 Function:
 Returns :
 Args    :

=cut

sub last {
    my $self = shift;
    return = $self->{storage}->{_features}[$self->{ids}[-1]];
}

#-----------------------------------------------------------------------------

=head2 delete

 Title   : delete
 Usage   : $a = $self->delete()
 Function:
 Returns :
 Args    :

=cut

sub delete {
    my $self = shift;
    $self->throw(message => 'This method is not yet implimented');
}

#-----------------------------------------------------------------------------

=head2 pager

 Title   : pager
 Usage   : $a = $self->pager()
 Function:
 Returns :
 Args    :

=cut

sub pager {
    my $self = shift;
    $self->throw(message => 'This method is not yet implimented');
}

#-----------------------------------------------------------------------------

=head2 reset_pager

 Title   : reset_pager
 Usage   : $a = $self->reset_pager()
 Function:
 Returns :
 Args    :

=cut

sub reset_pager {
    my $self = shift;
    $self->throw(message => 'This method is not yet implimented');
}

#-----------------------------------------------------------------------------

=head2 next_page

 Title   : next_page
 Usage   : $a = $self->next_page()
 Function:
 Returns :
 Args    :

=cut

sub next_page {
    my $self = shift;
    $self->throw(message => 'This method is not yet implimented');
}

#-----------------------------------------------------------------------------

=head2 previous_page

 Title   : previous_page
 Usage   : $a = $self->previous_page()
 Function:
 Returns :
 Args    :

=cut

sub previous_page {
    my $self = shift;
    $self->throw(message => 'This method is not yet implimented');
}

#-----------------------------------------------------------------------------

=head2 first_page

 Title   : first_page
 Usage   : $a = $self->first_page()
 Function:
 Returns :
 Args    :

=cut

sub first_page {
    my $self = shift;
    $self->throw(message => 'This method is not yet implimented');
}

#-----------------------------------------------------------------------------

=head2 last_page

 Title   : last_page
 Usage   : $a = $self->last_page()
 Function:
 Returns :
 Args    :

=cut

sub last_page {
    my $self = shift;
    $self->throw(message => 'This method is not yet implimented');
}

#-----------------------------------------------------------------------------

=head2 create

 Title   : create
 Usage   : $a = $self->create()
 Function:
 Returns :
 Args    :

=cut

sub create {
    my $self = shift;
    $self->throw(message => 'This method is not yet implimented');
}

#-----------------------------------------------------------------------------

=head2 find_or_create

 Title   : find_or_create
 Usage   : $a = $self->find_or_create()
 Function:
 Returns :
 Args    :

=cut

sub find_or_create {
    my $self = shift;
    $self->throw(message => 'This method is not yet implimented');
}

#-----------------------------------------------------------------------------

=head2 update_or_create

 Title   : update_or_create
 Usage   : $a = $self->update_or_create()
 Function:
 Returns :
 Args    :

=cut

sub update_or_create {
    my $self = shift;
    $self->throw(message => 'This method is not yet implimented');
}

#-----------------------------------------------------------------------------

=head2 order_by

 Title   : order_by
 Usage   : $a = $self->order_by()
 Function:
 Returns :
 Args    :

=cut

sub order_by {
    my $self = shift;
    $self->throw(message => 'This method is not yet implimented');
}

#-----------------------------------------------------------------------------

=head2 method

 Title   : method
 Usage   : $a = $self->method()
 Function:
 Returns :
 Args    :

=cut

sub method {
    my $self = shift;
    $self->throw(message => 'This method is not yet implimented');
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

<GAL::FeatureSet> requires no configuration files or environment variables.

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
