package GAL::Interval;

use strict;
use vars qw($VERSION);

$VERSION = 0.2.0;
use base qw(GAL::Base);

=head1 NAME

GAL::Interval - Interval aggregation and analysis functions for GAL

=head1 VERSION

This document describes GAL::Interval version 0.2.0

=head1 SYNOPSIS

    use GAL::Interval;
    my $intvs = GAL::Interval->new(list => \@features);

    my @seqids = $intvs->seqids;
    for my $seqid (@seqids) {
        my $intervals = $intvs->intervals($seqid);
        while (my $interval = $intervals->next) {
            my $feature = $interval->feature;
        }
    }

    my $footprint = $intvs->footprint;
    # Get a hash(ref) keyed off seqid valued as footprint.
    my %footprints = $intvs->footprint_by_seqid;

    # All of the following also have a *_by_seqid method
    my $cardinality = $intvs->cardinality;

    longest
    shortest
    min
    max

    intersection
    union
    compliment
    difference

    contains
    is_contained
    intersects
    overlaps

    set_bedtools
    set_bitvector
    set_span
    set_interval

=head1 DESCRIPTION

<GAL::Interval> serves as a base class for the modules below it and
provides basic list summarization details.  It is not intended to be
used on it's own.  You should use it's subclasses instead.

=head1 CONSTRUCTOR

To construct a GAL::Interval subclass simply pass it an appropriate list.

    my $list_catg = GAL::Interval->new(list => [qw(red red red blue blue
							       green yellow orange orange
							       purple purple purple purple)]);
    $list_numeric = GAL::Interval->new(list => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);


=cut

#-----------------------------------------------------------------------------
#-------------------------------- Constructor --------------------------------
#-----------------------------------------------------------------------------

=head2 new

     Title   : new
     Usage   : GAL::Interval->new()
     Function: Creates a GAL::Interval object;
     Returns : A GAL::Interval object
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
	my @valid_attributes = qw(list);
	$self->set_attributes($args, @valid_attributes);
	######################################################################
}

#-----------------------------------------------------------------------------
#-------------------------------- Attributes ---------------------------------
#-----------------------------------------------------------------------------

=head1  ATTRIBUTES

All attributes can be supplied as parameters to the constructor as a
list (or referenece) of key value pairs.

=head2 list

 Title   : list
 Usage   : $a = $self->list()
 Function: Get/Set the value of list.
 Returns : The value of list.
 Args    : A value to set list to.

=cut

sub list {
  my ($self, $list) = @_;
  if ($list) {
    my $err_msg = ('GAL::Interval requires an array reference as the ' .
		   'first argument, but you gave a  ' . ref $list
		  );
    my $err_code = 'list_or_reference_required : ' . ref $list;
    $self->warn($err_code, $err_msg) unless ref $list eq 'ARRAY';
    $self->{list} = $list;
  }
  $self->{list} ||= [];
  return wantarray ? @{$self->{list}} : $self->{list};
}

#-----------------------------------------------------------------------------

=head2 method

 Title   : method
 Usage   : $a = $self->method()
 Function: Get/Set the value of method.
 Returns : The value of method.
 Args    : A value to set method to.

=cut

 sub method {
   my ($self, $method) = @_;
   $self->{method} = $method if $method;
   return $self->{method};
 }

#-----------------------------------------------------------------------------

=head2 key

 Title   : key
 Usage   : $a = $self->key()
 Function: Get/Set the value of key.
 Returns : The value of key.
 Args    : A value to set key to.

=cut

 sub key {
   my ($self, $key) = @_;
   $self->{key} = $key if $key;
   return $self->{key};
 }

#-----------------------------------------------------------------------------

=head2 iterator

 Title   : iterator
 Usage   : $a = $self->iterator()
 Function: Get/Set the value of iterator.
 Returns : The value of iterator.
 Args    : A value to set iterator to.

=cut

 sub iterator {
   my ($self, $iterator) = @_;
   $self->{iterator} = $iterator if $iterator;
   return $self->{iterator};
 }

#-----------------------------------------------------------------------------
#---------------------------------- Methods ----------------------------------
#-----------------------------------------------------------------------------

=head1 METHODS

=head2 _parse_list

 Title   : _parse_list
 Usage   : $self->_parse_list()
 Function: Parse the contents of the list and create an array of data if the
	   data isn't already an array.
 Returns : N/A
 Args    : N/A

=cut

sub _parse_list {
    my $self = shift;

    my $list     = $self->list();
    my $iterator = $self->iterator();
    my $method   = $self->method();
    my $key      = $self->method();

  VALUE:
    for my $value (@{$list}) {
      if (! ref $value) {
	next VALUE;
      }
      elsif (my $class = List::Util::blessed $value) {
	if (! defined $method || ! $value->can($method)) {
	  $self->warn('method_does_not_exist', "CLASS=$class; METHOD=$method");
	  next VALUE;
	}
	$value = $value->$method;
      }
      elsif (ref $value eq 'HASH') {
	if (! defined $key || ! exists $value->{$key}) {
	  $self->warn('key_does_not_exist', ("KEY=$key; " .
					     join ',', %{$value}));
	  next VALUE;
	}
	$value = $value->{$key};
      }
    }

    my @xtra_values;
    if ($iterator && (my $class = List::Util::blessed $iterator)) {
      if (! $iterator->can('next')) {
	$self->warn('next_method_does_not_exist', "CLASS=$class; METHOD=next");
      }
      else {
      ITR_LOOP:
	while (my $value = $iterator->next) {
	if (! defined $method || ! $value->can($method)) {
	  $self->warn('method_does_not_exist', "CLASS=$class; METHOD=$method");
	  next ITR_LOOP;
	}
	else {
	  push @xtra_values, $value->$method;
	}
	}
      }
    }

    push @{$self->{list}}, @xtra_values if @xtra_values;
}

#-----------------------------------------------------------------------------

=head2 _hash_list

 Title   : _hash_list
 Usage   : $hash = $self->_hash_list()
 Function:
	   data isn't already an array.
 Returns : N/A
 Args    : N/A

=cut

sub _hash_list {
  my $self = shift;

  if (! exists $self->{hash_list}) {
    map {$self->{hash_list}{$_}++} $self->list;
  }

  return wantarray ? %{$self->{hash_list}} : $self->{hash_list};

}

#-----------------------------------------------------------------------------

=head2 count

 Title   : count
 Usage   : $a = $self->count
 Function: Return the number of elements in the list
 Returns : Integer
 Args    : N/A

=cut

sub count {
  my @list = shift->list;
  return scalar @list;
}

#-----------------------------------------------------------------------------

=head2 cardinality

 Title   : cardinality
 Usage   : $a = $self->cardinality
 Function: Return the number of uniq elements in the list
 Returns : Integer
 Args    : N/A

=cut

sub cardinality {
  my $self = shift;
  my @uniq = $self->uniq;
  return scalar @uniq;
}

#-----------------------------------------------------------------------------

=head2 count_uniq

 Title   : count_uniq
 Usage   : $a = $self->count_uniq()
 Function: An alias for cardinality
 Returns : Integer
 Args    : N/A

=cut

sub count_uniq {
    return shift->cardinality;
}

#-----------------------------------------------------------------------------

=head2 category_counts

 Title   : category_counts
 Usage   : $a = $self->category_counts()
 Function: Return a hash(reference) with uniq elements as keys and element
	   counts as values.
 Returns : A hash(reference)
 Args    : N/A

=cut

sub category_counts {
    my $self = shift;
    my %hash = $self->_hash_list;
    return wantarray ? %hash : \%hash;
}

#-----------------------------------------------------------------------------

=head2 shuffle

 Title   : shuffle
 Usage   : $a = $self->shuffle()
 Function: Returns the elements of the list in random order
 Returns : An array/array reference
 Args    : N/A

=cut

sub shuffle {
  return wantarray ? List::Util::shuffle(shift->list) :
    [List::Util::shuffle(shift->list)];
}

#-----------------------------------------------------------------------------

=head2 uniq

 Title   : uniq
 Usage   : $a = $self->uniq()
 Function:
 Returns :
 Args    :

=cut

sub uniq {
  my $self = shift;
  my @uniq = List::MoreUtils::uniq($self->list);
  return wantarray ? @uniq : \@uniq;
}

#-----------------------------------------------------------------------------

=head2 random_pick

 Title   : random_pick
 Usage   : $a = $self->random_pick()
 Function:
 Returns :
 Args    :

=cut

sub random_pick {
    my $self = shift;

    my $random = int(rand($self->count));
    return $self->{list}[$random];
}

#-----------------------------------------------------------------------------

=head1 DIAGNOSTICS

=over

=item C<< list_or_reference_required >>

GAL::Interval::list require an array or a reference to any array be passed
as an argument, but you have passed something else.

Keep in mind that several of GAL::Interval's methods are provided by
List::Util, and errors not found here may be thrown by that module.

=back

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::Interval> requires no configuration files or environment variables.

=head1 DEPENDENCIES

<GAL::Base>
<List::Util>

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to:
barry.moore@genetics.utah.edu

=head1 AUTHOR

Barry Moore <barry.moore@genetics.utah.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2012, Barry Moore <barry.moore@genetics.utah.edu>.  All rights reserved.

    This module is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself (See LICENSE).

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
