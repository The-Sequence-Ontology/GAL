package GAL::List::Span;

use strict;
use vars qw($VERSION);


$VERSION = '0.01';
use base qw(GAL::List);
use Set::IntSpan::Fast;

=head1 NAME

GAL::List::Span - Provide functions for lists of genomic coordinates

=head1 VERSION

This document describes GAL::List::Span version 0.01

=head1 SYNOPSIS

     use GAL::List::Span;

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
#-------------------------------- Constructor --------------------------------
#-----------------------------------------------------------------------------

=head2 new

     Title   : new
     Usage   : GAL::List::Span->new()
     Function: Creates a List::Span object;
     Returns : A List::Span object
     Args    : list => \@list

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
#--------------------------------- Attributes --------------------------------
#-----------------------------------------------------------------------------

=head2 list

 Title   : list
 Usage   : $a = $self->list()
 Function: Get/Set the list of spans
 Returns : The list of spans as an array or reference
 Args    : An reference to an array of genomic coordinates.

=cut

sub list {
  my ($self, $list) = @_;
  if ($list) {
    if (ref $list ne 'ARRAY') {
      my $err_msg = ('GAL::List::Span requires a reference to an '   .
		     'array as the first argument, but you gave a  ' .
		     ref $list);
      $self->throw('invalid_arguments', $err_msg);
    }
    elsif ($list && ref $list->[0] ne 'ARRAY' || scalar @{$list->[0]} != 2) {
      my $err_msg = ('GAL::List::Span requires a reference to an ' .
		     'array as the first argument and that array ' .
		     'must contain references to two element '     .
		     'arrays, but you gave a  ' . ref $list->[0]   .
		     ' which has ' . scalar @{$list->[0]}          .
		     ' elements');
      $self->throw('invalid_arguments', $err_msg);
    }
    $self->{list} = $list;
  }
  $self->{list} ||= [];
  return wantarray ? @{$self->{list}} : $self->{list};
}

#-----------------------------------------------------------------------------
#
# =head2 attribute
#
#  Title   : attribute
#  Usage   : $a = $self->attribute()
#  Function: Get/Set the value of attribute.
#  Returns : The value of attribute.
#  Args    : A value to set attribute to.
#
# =cut
#
# sub attribute {
#   my ($self, $attribute) = @_;
#   $self->{attribute} = $attribute if $attribute;
#   return $self->{attribute};
# }
#
#-----------------------------------------------------------------------------
#---------------------------------- Methods ----------------------------------
#-----------------------------------------------------------------------------

=head2 set

 Title   : set
 Usage   : $a = $self->set()
 Function:
 Returns :
 Args    :

=cut

sub set {
  my $self = shift;
  if (! exists $self->{set}) {
      my $set = Set::IntSpan::Fast->new();
    DATUM:
      for my $datum ($self->list) {
	if (Scalar::Util::blessed($datum) &&
	    $datum->can('start')          &&
	    $datum->can('end')) {
	  $set->add_range($datum->start, $datum->end);
	}
	elsif ((ref $datum eq 'HASH') &&
		exists $datum->{start}  &&
		exists $datum->{end}) {
          $set->add_range($datum->{start}, $datum->{end});
        }
	elsif ((ref $datum eq 'ARRAY') &&
		defined $datum->[0]  &&
		defined $datum->[1]) {
          $set->add_range($datum->[0], $datum->[1]);
        }
	else {
	  self->warn('invalid_data_type',
		     'Need range data, but got' . ref $datum);
	  next DATUM;
	}
      }
      $self->{set} = $set;
    }
  return $self->{set};
}

#-----------------------------------------------------------------------------

=head2 footprint

 Title   : footprint
 Usage   : $footprint = $self->footprint
 Function: Returns the tiled footprint of all of the spans
 Returns : An integer
 Args    : None

=cut

sub footprint {
    my $self = shift;
    scalar $self->set->as_array;
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

=head1 DIAGNOSTICS

<GAL::List::Span> currently does not throw any warnings or errors.


=back

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::List::Span> requires no configuration files or environment variables.

=head1 DEPENDENCIES

<GAL::List>
<Set::IntSpan::Fast>

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

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
